import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../models/curriculo_model.dart';
import 'home_screen.dart';

class CadastroScreen extends StatefulWidget {
  final List<String> areasDeInteresse;
  final Curriculo? curriculoParaEditar; // 1. NOVO PARÂMETRO OPCIONAL

  const CadastroScreen({
    Key? key,
    required this.areasDeInteresse,
    this.curriculoParaEditar, // Adicionado ao construtor
  }) : super(key: key);

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeController;
  late TextEditingController _idadeController;

  Uint8List? _fotoBytes;
  Uint8List? _pdfBytes;
  String? _pdfName;

  String? _areaDeInteresseSelecionada;
  late String _setorSelecionado;
  late String _generoSelecionado;

  @override
  void initState() {
    super.initState();

    // 2. PRÉ-PREENCHER O FORMULÁRIO SE ESTIVER EDITANDO
    final curriculo = widget.curriculoParaEditar;
    if (curriculo != null) {
      // Preenche os campos de texto
      _nomeController = TextEditingController(text: curriculo.nome);
      _idadeController = TextEditingController(text: curriculo.idade.toString());
      
      // Preenche os seletores
      _generoSelecionado = curriculo.genero;
      _areaDeInteresseSelecionada = curriculo.areaDeInteresse;
      _setorSelecionado = curriculo.setor;

      // Preenche os arquivos
      _fotoBytes = curriculo.fotoBytes;
      _pdfBytes = curriculo.pdfBytes;
      if (_pdfBytes != null) {
        _pdfName = 'curriculo_${curriculo.nome}.pdf';
      }

    } else {
      // Inicia os campos vazios se for um novo cadastro
      _nomeController = TextEditingController();
      _idadeController = TextEditingController();
      _generoSelecionado = 'Feminino';
      _setorSelecionado = 'Privado';
    }
  }

  // ... (funções _selecionarFoto e _selecionarPdf continuam as mesmas) ...
  Future<void> _selecionarFoto() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() { _fotoBytes = bytes; });
    }
  }

  Future<void> _selecionarPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom, allowedExtensions: ['pdf'], withData: true,
    );
    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _pdfBytes = result.files.single.bytes;
        _pdfName = result.files.single.name;
      });
    }
  }


  void _submeterFormulario() {
    if (!_formKey.currentState!.validate()) return;
    if (_fotoBytes == null || _pdfBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, anexe a foto e o PDF.')));
      return;
    }

    final curriculoAtualizado = Curriculo(
      nome: _nomeController.text,
      idade: int.parse(_idadeController.text),
      genero: _generoSelecionado,
      areaDeInteresse: _areaDeInteresseSelecionada!,
      setor: _setorSelecionado,
      avatarUrl: widget.curriculoParaEditar?.avatarUrl ?? '', // Mantém URL antiga se houver
      fotoBytes: _fotoBytes,
      pdfBytes: _pdfBytes,
    );

    Navigator.of(context).pop(curriculoAtualizado);
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _idadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // 3. TÍTULO DINÂMICO
        title: Text(widget.curriculoParaEditar == null
            ? 'Cadastrar Currículo'
            : 'Editar Currículo'),
        backgroundColor: const Color(0xFF0B671A),
        actions: [
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.share),
            label: const Text('Compartilhar Link'),
            
          )
        ],
      ),
      // O resto do body do formulário continua exatamente o mesmo
      // pois ele já lê os valores das variáveis de estado que agora são pré-preenchidas.
      body: SingleChildScrollView(
        // ... (código do formulário idêntico ao anterior)
         padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _selecionarFoto,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[300],
                    backgroundImage:
                        _fotoBytes != null ? MemoryImage(_fotoBytes!) : null,
                    child: _fotoBytes == null
                        ? const Icon(Icons.add_a_photo,
                            size: 50, color: Colors.grey)
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                    labelText: 'Nome Completo', border: OutlineInputBorder()),
                validator: (value) =>
                    value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _idadeController,
                decoration: const InputDecoration(
                    labelText: 'Idade', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              const Text('Gênero', style: TextStyle(fontSize: 16)),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Feminino'),
                      value: 'Feminino',
                      contentPadding: EdgeInsets.zero,
                      groupValue: _generoSelecionado,
                      onChanged: (value) {
                        if (value != null)
                          setState(() => _generoSelecionado = value);
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Masculino'),
                      value: 'Masculino',
                      contentPadding: EdgeInsets.zero,
                      groupValue: _generoSelecionado,
                      onChanged: (value) {
                        if (value != null)
                          setState(() => _generoSelecionado = value);
      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Outro'),
                      value: 'Outro',
                      contentPadding: EdgeInsets.zero,
                      groupValue: _generoSelecionado,
                      onChanged: (value) {
                        if (value != null)
                          setState(() => _generoSelecionado = value);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _areaDeInteresseSelecionada,
                hint: const Text('Área de Interesse'),
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: widget.areasDeInteresse.map((area) {
                  return DropdownMenuItem(value: area, child: Text(area));
                }).toList(),
                onChanged: (value) =>
                    setState(() => _areaDeInteresseSelecionada = value),
                validator: (value) =>
                    value == null ? 'Selecione uma área' : null,
              ),
              const SizedBox(height: 16),
              const Text('Setor Pretendido', style: TextStyle(fontSize: 16)),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Privado'),
                      value: 'Privado',
                      groupValue: _setorSelecionado,
                      onChanged: (value) {
                        if (value != null)
                          setState(() => _setorSelecionado = value);
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Público'),
                      value: 'Público',
                      groupValue: _setorSelecionado,
                      onChanged: (value) {
                        if (value != null)
                          setState(() => _setorSelecionado = value);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _selecionarPdf,
                icon: const Icon(Icons.attach_file),
                label: Text(_pdfName ?? 'Anexar Currículo (PDF)'),
                style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    textStyle: const TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submeterFormulario,
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B671A),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                child: const Text('SALVAR ALTERAÇÕES'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}