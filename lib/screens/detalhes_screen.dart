import 'package:flutter/material.dart';
import 'package:file_saver/file_saver.dart';
import '../models/curriculo_model.dart';
import 'cadastro_screen.dart';

class DetalhesScreen extends StatefulWidget {
  final Curriculo curriculo;

  const DetalhesScreen({Key? key, required this.curriculo}) : super(key: key);

  @override
  State<DetalhesScreen> createState() => _DetalhesScreenState();
}

class _DetalhesScreenState extends State<DetalhesScreen> {
  late Curriculo _curriculo;

  @override
  void initState() {
    super.initState();
    _curriculo = widget.curriculo;
  }

  // Função para navegar para a edição (continua a mesma)
  Future<void> _navegarParaEdicao() async {
    final curriculoAtualizado = await Navigator.of(context).push<Curriculo>(
      MaterialPageRoute(
        builder: (_) => CadastroScreen(
          areasDeInteresse: const [
            'Administração', 'Comunicação', 'Design', 'Direito', 'Educação',
            'Engenharia', 'Marketing', 'Saúde', 'Tecnologia',
          ],
          curriculoParaEditar: _curriculo,
        ),
      ),
    );

    if (curriculoAtualizado != null) {
      setState(() {
        _curriculo = curriculoAtualizado;
      });
    }
  }

  // 1. NOVA FUNÇÃO PARA CONFIRMAR E EXECUTAR A DELEÇÃO
  Future<void> _confirmarDelecao(BuildContext context) async {
    // Exibe um diálogo de confirmação
    final bool? confirmado = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: const Text('Tem certeza que deseja excluir este currículo? Esta ação não pode ser desfeita.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Retorna 'false' se cancelar
              child: const Text('CANCELAR'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // Retorna 'true' se confirmar
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('EXCLUIR'),
            ),
          ],
        );
      },
    );

    // Se o usuário confirmou (retornou true), então pop a tela com um sinal para deletar
    if (confirmado == true) {
      Navigator.of(context).pop('DELETE');
    }
  }

  // Função de download do PDF (continua a mesma)
  Future<void> _baixarPDF(BuildContext context) async {
    // ...
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_curriculo.nome),
        backgroundColor: const Color(0xFF0B671A),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _navegarParaEdicao,
          ),
          // 2. BOTÃO DE DELETAR ADICIONADO
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmarDelecao(context),
          ),
        ],
      ),
      // O WillPopScope garante que, ao voltar, a tela anterior receba o currículo atualizado
      body: WillPopScope(
        onWillPop: () async {
          Navigator.of(context).pop(_curriculo);
          return false;
        },
        child: SingleChildScrollView(
          // ... (código do body da tela de detalhes idêntico ao anterior)
           padding: const EdgeInsets.all(24.0),
          child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Center(
              child: Hero( 
                tag: _curriculo.nome + _curriculo.idade.toString(),
                child: CircleAvatar(
                  radius: 80,
                  backgroundImage: _curriculo.fotoBytes != null
                      ? MemoryImage(_curriculo.fotoBytes!)
                      : NetworkImage(_curriculo.avatarUrl) as ImageProvider,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Center(child: Text(_curriculo.nome, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold))),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 16),
            _buildInfoRow('Idade:', '${_curriculo.idade} anos'),
            _buildInfoRow('Gênero:', _curriculo.genero),
            _buildInfoRow('Área de Interesse:', _curriculo.areaDeInteresse),
            _buildInfoRow('Setor Pretendido:', _curriculo.setor),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton.icon(
                onPressed: () => _baixarPDF(context),
                icon: const Icon(Icons.download_for_offline),
                label: const Text('BAIXAR CURRÍCULO (PDF)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey[700],
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
     return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}