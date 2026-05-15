import 'package:crudflutter/telas/telaperfil.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import './login.dart';
import './telaperfil.dart';

final _supabase = Supabase.instance.client;

// select *
Future<List<dynamic>> _buscarcomentarios() async {
  final response = await _supabase.from('comentarios').select().order('nome');
  return response as List<dynamic>;
}

// insert - Updated for social network feed
Future<void> _novocomentario(String nome, String descricao, String foto) async {
  await _supabase.from('comentarios').insert({
    'nome': nome,
    'descricao': descricao,
    'foto': foto,
  });
}

// update - Updated to include valor
Future<void> _atualizarcomentario(
  int id,
  String nome,
  String descricao,
  String foto,
) async {
  await _supabase
      .from('comentarios')
      .update({'nome': nome, 'descricao': descricao, 'foto': foto})
      .eq('id', id);
}

// delete
Future<void> _deletarcomentario(int id) async {
  await _supabase.from('comentarios').delete().eq('id', id);
}

// like
Future<void> _curtirPost(int id, int likesAtuais) async {
  await _supabase
      .from('comentarios')
      .update({'likes': likesAtuais + 1})
      .eq('id', id);
}

class InventarioPagina extends StatefulWidget {
  const InventarioPagina({super.key});

  @override
  State<InventarioPagina> createState() => _InventarioPaginaState();
}

class _InventarioPaginaState extends State<InventarioPagina> {
  // Moved controllers inside the State for better memory management
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _fotoController = TextEditingController();

  //logout
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

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 1,
        shadowColor: const Color(0xFF8A2BE2).withOpacity(0.5),
        title: Row(
          children: [
            const Text(
              "Aura",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                letterSpacing: 1.5,
                color: Color(0xFF00F5FF),
                shadows: [Shadow(color: Color(0xFF00F5FF), blurRadius: 10.0)],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF8A2BE2)),
            onPressed: _fazerLogout,
          ),
          IconButton(
            icon: const Icon(Icons.person, color: Color(0xFF8A2BE2)),
            onPressed: () {
              //abrir tela de perfil
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TelaDePerfil()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Create Post Section
          Container(
            color: const Color(0xFF121212),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF8A2BE2).withOpacity(0.5),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const CircleAvatar(
                        backgroundColor: Color(0xFF8A2BE2),
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _nomeController,
                        style: const TextStyle(
                          color: Color.fromARGB(255, 245, 245, 245),
                        ),
                        decoration: const InputDecoration(
                          hintText: "Título do Post",
                          border: OutlineInputBorder(),
                          hintStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color.fromARGB(255, 245, 245, 245),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 52.0),
                  child: TextField(
                    controller: _descricaoController,
                    maxLines: null,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: "No que você está pensando?",
                      border: OutlineInputBorder(),
                      hintStyle: TextStyle(color: Colors.white54),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 52.0),
                  child: TextField(
                    controller: _fotoController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: "URL ou caminho da imagem",
                      border: OutlineInputBorder(),
                      hintStyle: TextStyle(color: Colors.white54),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () async {
                      final String nome = _nomeController.text;
                      final String descricao = _descricaoController.text;
                      final String foto = _fotoController.text;

                      if (nome.isNotEmpty &&
                          descricao.isNotEmpty &&
                          foto.isNotEmpty) {
                        await _novocomentario(nome, descricao, foto);
                        _nomeController.clear();
                        _descricaoController.clear();
                        _fotoController.clear();
                        setState(() {}); // Refresh the list
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Preencha todos os campos!"),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0A0A0A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: const BorderSide(
                          color: Color(0xFF8A2BE2),
                          width: 2,
                        ),
                      ),
                      shadowColor: const Color(0xFF8A2BE2),
                      elevation: 8,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      "Postar",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00F5FF),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Feed Section
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _buscarcomentarios(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF8A2BE2)),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'Nenhum post encontrado na sua rede.',
                      style: TextStyle(color: Colors.white54),
                    ),
                  );
                }

                final comentarios = snapshot.data!;
                return ListView.builder(
                  itemCount: comentarios.length,
                  itemBuilder: (context, index) {
                    final item = comentarios[index];
                    return Card(
                      color: const Color(0xFF121212),
                      margin: const EdgeInsets.only(bottom: 8.0),
                      elevation: 0,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            leading: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF00F5FF,
                                    ).withOpacity(0.3),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: const CircleAvatar(
                                backgroundColor: Color(0xFF0A0A0A),
                                child: Icon(
                                  Icons.person,
                                  color: Color(0xFF00F5FF),
                                ),
                              ),
                            ),
                            title: Text(
                              item['nome']?.toString() ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            trailing: PopupMenuButton<String>(
                              color: const Color(0xFF1A1A1A),
                              icon: const Icon(
                                Icons.more_vert,
                                color: Colors.white54,
                              ),
                              onSelected: (value) async {
                                if (value == 'edit') {
                                  await _atualizarcomentario(
                                    item['id'],
                                    item['nome']?.toString() ?? '',
                                    item['descricao']?.toString() ?? '',
                                    item['foto']?.toString() ?? '',
                                  );
                                  setState(() {});
                                } else if (value == 'delete') {
                                  await _deletarcomentario(item['id']);
                                  setState(() {});
                                }
                              },
                              itemBuilder: (BuildContext context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Text(
                                    'Editar Post',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text(
                                    'Excluir Post',
                                    style: TextStyle(color: Colors.redAccent),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (item['descricao'] != null &&
                              item['descricao'].toString().isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 4.0,
                              ),
                              child: Text(
                                item['descricao'].toString(),
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                          if (item['foto'] != null &&
                              item['foto'].toString().isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 12.0),
                              child: Image.network(
                                item['foto'].toString(),
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                    item['foto'].toString(),
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const SizedBox(),
                                  );
                                },
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 4.0,
                            ),
                            child: Row(
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        (item['likes'] ?? 0) > 0
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: const Color(0xFF8A2BE2),
                                      ),
                                      onPressed: () async {
                                        int likesAtuais =
                                            int.tryParse(
                                              item['likes']?.toString() ?? '0',
                                            ) ??
                                            0;
                                        await _curtirPost(
                                          item['id'],
                                          likesAtuais,
                                        );
                                        setState(() {});
                                      },
                                    ),
                                    if ((int.tryParse(
                                              item['likes']?.toString() ?? '0',
                                            ) ??
                                            0) >
                                        0)
                                      Text(
                                        '${item['likes']}',
                                        style: const TextStyle(
                                          color: Color(0xFF8A2BE2),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                  ],
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.chat_bubble_outline,
                                    color: Color(0xFF00F5FF),
                                  ),
                                  onPressed: () {},
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.share,
                                    color: Colors.white54,
                                  ),
                                  onPressed: () {},
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
