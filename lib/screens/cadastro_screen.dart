import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../models/curriculo_model.dart';

class CadastroScreen extends StatefulWidget {
  final List<String> areasDeInteresse;

  const CadastroScreen({Key? key, required this.areasDeInteresse}) : super(key: key);

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _idadeController = TextEditingController();

  Uint8List? _fotoBytes;
  Uint8List? _pdfBytes;
  String? _pdfName;

  String? _areaDeInteresseSelecionada;
  String _setorSelecionado = 'Privado';

  Future<void> _selecionarFoto() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _fotoBytes = bytes;
      });
    }
  }

  Future<void> _selecionarPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );
    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _pdfBytes = result.files.single.bytes;
        _pdfName = result.files.single.name;
      });
    }
  }

  void _submeterFormulario() {
    if (_formKey.currentState!.validate()) {
      if (_fotoBytes == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, anexe uma foto.')),
        );
        return;
      }
      if (_pdfBytes == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, anexe seu currículo em PDF.')),
        );
        return;
      }

      final novoCurriculo = Curriculo(
        nome: _nomeController.text,
        idade: int.parse(_idadeController.text),
        genero: 'Não informado',
        areaDeInteresse: _areaDeInteresseSelecionada!,
        setor: _setorSelecionado,
        avatarUrl: '', // Vazio, pois usaremos os bytes
        fotoBytes: _fotoBytes,
      );

      Navigator.of(context).pop(novoCurriculo);
    }
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
        title: const Text('Cadastrar Currículo'),
        backgroundColor: const Color(0xFF0B671A),
      ),
      body: SingleChildScrollView(
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
                child: const Text('ENVIAR CURRÍCULO'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}