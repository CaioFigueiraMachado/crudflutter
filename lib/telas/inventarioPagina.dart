import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import './login.dart';

final _supabase = Supabase.instance.client;

// select *
Future<List<dynamic>> _buscarprodutos() async {
  final response = await _supabase.from('produtos').select().order('nome');
  return response as List<dynamic>;
}

// insert - Updated to accept 3 arguments
Future<void> _novoproduto(String nome, int quantidade, double preco) async {
  await _supabase.from('produtos').insert({
    'nome': nome,
    'quantidade': quantidade,
    'preco': preco, // Now saving the value
  });
}

// update - Updated to include valor
Future<void> _atualizarprodutos(
  int id,
  String nome,
  int quantidade,
  double preco,
) async {
  await _supabase
      .from('produtos')
      .update({'nome': nome, 'quantidade': quantidade, 'preco': preco})
      .eq('id', id);
}

// delete
Future<void> _deletarprodutos(int id) async {
  await _supabase.from('produtos').delete().eq('id', id);
}

class InventarioPagina extends StatefulWidget {
  const InventarioPagina({super.key});

  @override
  State<InventarioPagina> createState() => _InventarioPaginaState();
}

class _InventarioPaginaState extends State<InventarioPagina> {
  // Moved controllers inside the State for better memory management
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _quantidadeController = TextEditingController();
  final TextEditingController _valorController = TextEditingController();

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Inventário"),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _fazerLogout),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(
                labelText: "Nome do Produto",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _quantidadeController,
              decoration: const InputDecoration(
                labelText: "Quantidade",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _valorController,
              decoration: const InputDecoration(
                labelText: "Valor",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final String nome = _nomeController.text;
                final int? qtd = int.tryParse(_quantidadeController.text);
                final double? preco = double.tryParse(_valorController.text);

                if (nome.isNotEmpty && qtd != null && preco != null) {
                  await _novoproduto(nome, qtd, preco);
                  _nomeController.clear();
                  _quantidadeController.clear();
                  _valorController.clear();
                  setState(() {}); // Refresh the list
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Preencha todos os campos corretamente!"),
                    ),
                  );
                }
              },
              child: const Text("Adicionar Produto"),
            ),
            const Divider(height: 40),
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: _buscarprodutos(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Nenhum dado encontrado'));
                  }

                  final produtos = snapshot.data!;
                  return ListView.builder(
                    itemCount: produtos.length,
                    itemBuilder: (context, index) {
                      final item = produtos[index];
                      return ListTile(
                        leading: const Icon(Icons.inventory),
                        title: Text(item['nome']),
                        subtitle: Text(
                          "Qtd: ${item['quantidade']} | Valor: R\$ ${item['preco']}",
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                await _deletarprodutos(item['id']);
                                setState(() {});
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              color: Colors.blue,
                              onPressed: () async {
                                _atualizarprodutos(
                                  item['id'],
                                  "${item['nome']}",
                                  int.tryParse("${item['quantidade']}") ?? 0,
                                  double.tryParse("${item['preco']}") ?? 0,
                                );
                                setState(() {});
                              },
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
      ),
    );
  }
}
