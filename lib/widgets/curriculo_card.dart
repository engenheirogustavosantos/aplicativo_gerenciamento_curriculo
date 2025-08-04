// lib/widgets/curriculo_card.dart

import 'package:flutter/material.dart';
import '../models/curriculo_model.dart';

class CurriculoCard extends StatelessWidget {
  final Curriculo curriculo;

  const CurriculoCard({Key? key, required this.curriculo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: ListTile(
        leading: CircleAvatar(
          radius: 30,
          backgroundImage: NetworkImage(curriculo.avatarUrl),
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
          // Ação ao clicar no card (ex: abrir tela de detalhes)
          // Por enquanto, podemos deixar um print
          print('Clicou em ${curriculo.nome}');
        },
      ),
    );
  }
}