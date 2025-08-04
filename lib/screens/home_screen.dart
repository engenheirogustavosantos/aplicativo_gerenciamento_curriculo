import 'dart:io';
import 'package:flutter/material.dart';
import '../models/curriculo_model.dart';
import '../widgets/filtro_drawer.dart';
import 'cadastro_screen.dart';

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
        builder: (context) => CadastroScreen(areasDeInteresse: _areasDeInteresse),
      ),
    );

    if (novoCurriculo != null) {
      setState(() {
        _todosOsCurriculos.insert(0, novoCurriculo);
        _aplicarFiltros({});
      });
    }
  }

  void _aplicarFiltros(Map<String, dynamic> filters) {
    List<Curriculo> listaTemporaria = List.from(_todosOsCurriculos);

    if (filters['areaDeInteresse'] != null) {
      listaTemporaria = listaTemporaria.where((c) => c.areaDeInteresse == filters['areaDeInteresse']).toList();
    }

    if (filters['genero'] != null) {
      listaTemporaria = listaTemporaria.where((c) => c.genero == filters['genero']).toList();
    }

    if (filters['idadeRange'] != null) {
      final RangeValues range = filters['idadeRange'];
      listaTemporaria = listaTemporaria.where((c) => c.idade >= range.start && c.idade <= range.end).toList();
    }
    
    if (filters['setor'] != null) {
      listaTemporaria = listaTemporaria.where((c) => c.setor == filters['setor']).toList();
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
                return CurriculoCard(curriculo: curriculo);
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

  const CurriculoCard({Key? key, required this.curriculo}) : super(key: key);

  ImageProvider _getImage(Curriculo curriculo) {
  // 1. Se tivermos os bytes da foto (novos currículos), use-os.
  if (curriculo.fotoBytes != null) {
    return MemoryImage(curriculo.fotoBytes!);
  }
  
  // 2. Senão, use a lógica antiga para os currículos de mock.
  final path = curriculo.avatarUrl;
  if (path.startsWith('http')) {
    return NetworkImage(path);
  } else if (path.startsWith('assets/')) {
    return AssetImage(path);
  } else {
    // Para compatibilidade com arquivos locais no mobile (caso ainda use)
    return FileImage(File(path));
  }
}

@override
Widget build(BuildContext context) {
  return Card(
    // ...
    child: ListTile(
      leading: CircleAvatar(
        radius: 30,
        // Passe o objeto curriculo inteiro para a função
        backgroundImage: _getImage(curriculo),
        backgroundColor: Colors.grey[200],
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
            Text('Área: ${curriculo.areaDeInteresse}'),
            Text('Setor: ${curriculo.setor}'),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          print('Clicou em ${curriculo.nome}');
        },
      ),
    );
  }
}