import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/curriculo_model.dart';
import '../widgets/filtro_drawer.dart';
import 'cadastro_screen.dart';
import 'detalhes_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Curriculo> _todosOsCurriculos = mockCurriculos;
  late List<Curriculo> _curriculosFiltrados;

  final List<String> _areasDeInteresse = [
    'Administração', 'Comunicação', 'Design', 'Direito', 'Educação',
    'Engenharia', 'Marketing', 'Saúde', 'Tecnologia',
  ];

  @override
  void initState() {
    super.initState();
    _curriculosFiltrados = _todosOsCurriculos;
  }

  void _abrirTelaDeCadastro() async {
    final novoCurriculo = await Navigator.of(context).push<Curriculo>(
      MaterialPageRoute(
        builder: (context) =>
            CadastroScreen(areasDeInteresse: _areasDeInteresse),
      ),
    );

    if (novoCurriculo != null) {
      setState(() {
        _todosOsCurriculos.insert(0, novoCurriculo);
        _aplicarFiltros({});
      });
    }
  }

  void atualizarCurriculo(Curriculo curriculoAtualizado, Curriculo curriculoAntigo) {
    final index = _todosOsCurriculos.indexOf(curriculoAntigo);
    if (index != -1) {
      setState(() {
        _todosOsCurriculos[index] = curriculoAtualizado;
        _aplicarFiltros({});
      });
    }
  }

  // MÉTODO QUE ESTAVA FALTANDO
  void _deletarCurriculo(Curriculo curriculoParaDeletar) {
    setState(() {
      _todosOsCurriculos.remove(curriculoParaDeletar);
      _aplicarFiltros({});
    });
  }

  void _aplicarFiltros(Map<String, dynamic> filters) {
    List<Curriculo> listaTemporaria = List.from(_todosOsCurriculos);

    if (filters['areaDeInteresse'] != null) {
      listaTemporaria = listaTemporaria
          .where((c) => c.areaDeInteresse == filters['areaDeInteresse'])
          .toList();
    }
    if (filters['genero'] != null) {
      listaTemporaria = listaTemporaria
          .where((c) => c.genero == filters['genero'])
          .toList();
    }
    if (filters.containsKey('idadeRange')) {
      final RangeValues range = filters['idadeRange'];
      listaTemporaria = listaTemporaria
          .where((c) => c.idade >= range.start && c.idade <= range.end)
          .toList();
    }
    if (filters['setor'] != null) {
      listaTemporaria =
          listaTemporaria.where((c) => c.setor == filters['setor']).toList();
    }

    setState(() {
      _curriculosFiltrados = listaTemporaria;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciador de Currículos'),
        backgroundColor: const Color(0xFF0B671A),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
      endDrawer: FiltroDrawer(
        onApplyFilters: _aplicarFiltros,
        areasDeInteresse: _areasDeInteresse,
      ),
      body: _curriculosFiltrados.isEmpty
          ? const Center(
              child: Text(
                'Nenhum currículo encontrado.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: _curriculosFiltrados.length,
              itemBuilder: (context, index) {
                final curriculo = _curriculosFiltrados[index];
                return CurriculoCard(
                  curriculo: curriculo,
                  onDataChanged: (curriculoAtualizado) {
                    atualizarCurriculo(curriculoAtualizado, curriculo);
                  },
                  // A chamada para a função de deletar agora encontrará a função correspondente
                  onDelete: () {
                    _deletarCurriculo(curriculo);
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirTelaDeCadastro,
        backgroundColor: const Color(0xFF0B671A),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class CurriculoCard extends StatelessWidget {
  final Curriculo curriculo;
  final Function(Curriculo) onDataChanged;
  final VoidCallback onDelete;

  const CurriculoCard({
    Key? key,
    required this.curriculo,
    required this.onDataChanged,
    required this.onDelete,
  }) : super(key: key);

  ImageProvider _getImage(Curriculo curriculo) {
    if (curriculo.fotoBytes != null) {
      return MemoryImage(curriculo.fotoBytes!);
    }
    final path = curriculo.avatarUrl;
    if (path.startsWith('http')) {
      return NetworkImage(path);
    } else if (path.startsWith('assets/')) {
      return AssetImage(path);
    } else {
      return FileImage(File(path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: ListTile(
        leading: Hero(
          tag: curriculo.nome + curriculo.idade.toString(),
          child: CircleAvatar(
            radius: 30,
            backgroundImage: _getImage(curriculo),
            backgroundColor: Colors.grey[200],
          ),
        ),
        title: Text(
          curriculo.nome,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4.0),
            Text('Idade: ${curriculo.idade} anos'),
            Text('Gênero: ${curriculo.genero}'),
            Text('Área: ${curriculo.areaDeInteresse}'),
            Text('Setor: ${curriculo.setor}'),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () async {
          final resultado = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => DetalhesScreen(curriculo: curriculo),
            ),
          );

          if (resultado == 'DELETE') {
            onDelete();
          } else if (resultado is Curriculo) {
            onDataChanged(resultado);
          }
        },
      ),
    );
  }
}