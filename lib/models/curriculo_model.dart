// lib/models/curriculo_model.dart
import 'dart:typed_data';
class Curriculo {
  final String nome;
  final int idade;
  final String genero;
  final String areaDeInteresse;
  final String setor;
  final String avatarUrl; // Mantemos para os dados de mock antigos
  final Uint8List? fotoBytes; // NOVO CAMPO para fotos novas
  final Uint8List? pdfBytes; // <-- 1. NOVO CAMPO ADICIONADO

  Curriculo({
    required this.nome,
    required this.idade,
    required this.genero,
    required this.areaDeInteresse,
    required this.setor,
    required this.avatarUrl,
    this.fotoBytes, // NOVO CAMPO
    this.pdfBytes, // <-- 2. ADICIONADO AO CONSTRUTOR
  });
}


// Lista de dados Fictícios (Mock Data) para popular nosso app
final List<Curriculo> mockCurriculos = [
  Curriculo(nome: 'Ana Silva', idade: 28, genero: 'Feminino', areaDeInteresse: 'Tecnologia', setor: 'Privado', avatarUrl: 'https://i.pravatar.cc/150?img=1'),
  Curriculo(nome: 'Bruno Costa', idade: 35, genero: 'Masculino', areaDeInteresse: 'Marketing', setor: 'Privado', avatarUrl: 'https://i.pravatar.cc/150?img=2'),
  Curriculo(nome: 'Carla Dias', idade: 42, genero: 'Feminino', areaDeInteresse: 'Saúde', setor: 'Público', avatarUrl: 'https://i.pravatar.cc/150?img=3'),
  Curriculo(nome: 'Daniel Martins', idade: 22, genero: 'Masculino', areaDeInteresse: 'Educação', setor: 'Público', avatarUrl: 'https://i.pravatar.cc/150?img=4'),
  Curriculo(nome: 'Eduarda Farias', idade: 31, genero: 'Feminino', areaDeInteresse: 'Tecnologia', setor: 'Privado', avatarUrl: 'https://i.pravatar.cc/150?img=5'),
  Curriculo(nome: 'Felipe Souza', idade: 50, genero: 'Masculino', areaDeInteresse: 'Direito', setor: 'Público', avatarUrl: 'https://i.pravatar.cc/150?img=6'),
  Curriculo(nome: 'Gabriela Lima', idade: 25, genero: 'Feminino', areaDeInteresse: 'Marketing', setor: 'Privado', avatarUrl: 'https://i.pravatar.cc/150?img=7'),
];