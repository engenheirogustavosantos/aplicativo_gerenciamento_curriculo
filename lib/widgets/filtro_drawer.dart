import 'package:flutter/material.dart';

class FiltroDrawer extends StatefulWidget {
  final Function(Map<String, dynamic> filters) onApplyFilters;
  final List<String> areasDeInteresse; // Parâmetro adicionado

  const FiltroDrawer({
    Key? key,
    required this.onApplyFilters,
    required this.areasDeInteresse, // Parâmetro adicionado
  }) : super(key: key);

  @override
  State<FiltroDrawer> createState() => _FiltroDrawerState();
}

class _FiltroDrawerState extends State<FiltroDrawer> {
  String? _areaDeInteresse;
  String? _genero;
  RangeValues _idadeRange = const RangeValues(18, 24);
  String? _setor;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text('Filtros',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const Divider(thickness: 2),
          const SizedBox(height: 16),
          _buildDropdown(
              'Área de Interesse', _areaDeInteresse, widget.areasDeInteresse,
              (val) {
            setState(() => _areaDeInteresse = val);
          }),
          const SizedBox(height: 20),
          _buildRadioGroup('Gênero', ['Masculino', 'Feminino', 'Outro'], _genero,
              (val) {
            setState(() => _genero = val);
          }),
          const SizedBox(height: 20),
          _buildRangeSlider('Idade', _idadeRange, (values) {
            setState(() => _idadeRange = values);
          }),
          const SizedBox(height: 20),
          _buildRadioGroup('Setor', ['Público', 'Privado'], _setor, (val) {
            setState(() => _setor = val);
          }),
          const Divider(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(
                onPressed: _limparFiltros,
                child: const Text('Limpar'),
              ),
              ElevatedButton(
                onPressed: _aplicarFiltros,
                child: const Text('Aplicar'),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, String? currentValue, List<String> items,
      ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: currentValue,
      hint: Text(label),
      isExpanded: true,
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildRadioGroup(String label, List<String> options,
      String? groupValue, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: options
              .map((option) => Expanded(
                    child: RadioListTile<String>(
                      title: Text(option),
                      value: option,
                      groupValue: groupValue,
                      onChanged: onChanged,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildRangeSlider(String label, RangeValues currentRange,
      ValueChanged<RangeValues> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ${currentRange.start.round()} - ${currentRange.end.round()} anos',
            style: const TextStyle(fontWeight: FontWeight.w600)),
        RangeSlider(
          values: currentRange,
          min: 18,
          max: 24,
          divisions: 6,
          labels: RangeLabels(
            currentRange.start.round().toString(),
            currentRange.end.round().toString(),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }

  void _aplicarFiltros() {
    final filters = {
      'areaDeInteresse': _areaDeInteresse,
      'genero': _genero,
      'idadeRange': _idadeRange,
      'setor': _setor,
    };
    widget.onApplyFilters(filters);
    Navigator.of(context).pop();
  }

  void _limparFiltros() {
    setState(() {
      _areaDeInteresse = null;
      _genero = null;
      _idadeRange = const RangeValues(18, 24);
      _setor = null;
    });
    widget.onApplyFilters({});
    Navigator.of(context).pop();
  }
}