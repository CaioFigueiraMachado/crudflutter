import 'package:crudflutter/telas/login.dart';
import 'package:crudflutter/telas/splashscreen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import './inventarioPagina.dart';

final _supabase = Supabase.instance.client;

Future<List<dynamic>> _buscarinfousuario() async {
  final response = await _supabase
      .from('usuarios')
      .select()
      .eq('email', _supabase.auth.currentUser!.email!);
  return response as List<dynamic>;
}

class TelaDePerfil extends StatefulWidget {
  const TelaDePerfil({Key? key}) : super(key: key);
  @override
  State<TelaDePerfil> createState() => _TelaDePerfilState();
}

class _TelaDePerfilState extends State<TelaDePerfil> {
  @override
  void initState() {
    super.initState();
    _buscarinfousuario();
  }

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  Future<void> _fazerLogout() async {
    try {
      await _supabase.auth.signOut();

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPagina()),
        );
      }
    } catch (e) {
      debugPrint("Erro ao deslogar: $e");
    }
  }

  Future<void> _atualizarinfousuario() async {
    await _supabase
        .from('usuarios')
        .update({
          'nome': _nomeController.text,
          'email': _emailController.text,
          'biografia': _bioController.text
        })
        .eq('email', _supabase.auth.currentUser!.email!);
  }

  Future<void> _homepage() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const InventarioPagina()),
    );
  }

  void _mostrarDialogoEdicao(Map<String, dynamic> userInfo) {
    _nomeController.text = userInfo['nome']?.toString() ?? '';
    _emailController.text = userInfo['email']?.toString() ?? '';
    _bioController.text = userInfo['biografia']?.toString() ?? '';

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF121212),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Editar Perfil",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF00F5FF)),
              ),
              const SizedBox(height: 20),
              _buildTextField(_nomeController, "Nome", Icons.person),
              const SizedBox(height: 12),
              _buildTextField(_emailController, "Email", Icons.email),
              const SizedBox(height: 12),
              _buildTextField(_bioController, "Biografia", Icons.info),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await _atualizarinfousuario();
                    if (mounted) {
                      Navigator.pop(context);
                      setState(() {}); // refresh
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8A2BE2),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Salvar", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        prefixIcon: Icon(icon, color: const Color(0xFF8A2BE2)),
        filled: true,
        fillColor: const Color(0xFF1A1A1A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF00F5FF), width: 2),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 1,
        shadowColor: const Color(0xFF8A2BE2).withOpacity(0.5),
        title: const Text(
          "Aura",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 1.5,
            color: Color(0xFF00F5FF),
            shadows: [Shadow(color: Color(0xFF00F5FF), blurRadius: 10.0)],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF8A2BE2)),
            onPressed: _fazerLogout,
          ),
          IconButton(
            icon: const Icon(Icons.home, color: Color(0xFF8A2BE2)),
            onPressed: _homepage,
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _buscarinfousuario(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF8A2BE2)),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Nenhum perfil encontrado.',
                style: TextStyle(color: Colors.white54),
              ),
            );
          }

          final userInfo = snapshot.data![0];
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00F5FF).withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const CircleAvatar(
                    radius: 50,
                    backgroundColor: Color(0xFF0A0A0A),
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: Color(0xFF00F5FF),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  userInfo['nome']?.toString() ?? 'Usuário',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  userInfo['email']?.toString() ?? '',
                  style: const TextStyle(fontSize: 16, color: Colors.white70),
                ),
                Text(
                  userInfo['biografia']?.toString() ?? '',
                  style: const TextStyle(fontSize: 16, color: Colors.white70),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => _mostrarDialogoEdicao(userInfo as Map<String, dynamic>),
                  icon: const Icon(Icons.edit, color: Color(0xFF00F5FF)),
                  label: const Text("Editar Perfil", style: TextStyle(color: Color(0xFF00F5FF), fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: const BorderSide(color: Color(0xFF8A2BE2), width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
