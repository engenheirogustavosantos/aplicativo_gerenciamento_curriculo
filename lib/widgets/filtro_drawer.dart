import 'package:flutter/material.dart';

class FiltroDrawer extends StatefulWidget {
  final Function(Map<String, dynamic> filters) onApplyFilters;
  final List<String> areasDeInteresse;

  const FiltroDrawer({
    Key? key,
    required this.onApplyFilters,
    required this.areasDeInteresse,
  }) : super(key: key);

  @override
  State<FiltroDrawer> createState() => _FiltroDrawerState();
}

class _FiltroDrawerState extends State<FiltroDrawer> {
  String? _areaDeInteresse;
  String? _genero;
  RangeValues _idadeRange = const RangeValues(18, 24);
  String? _setor;

  // 1. NOVA VARIÁVEL DE CONTROLE: Rastreia se o slider foi tocado.
  bool _idadeSliderFoiTocado = false;

  void _aplicarFiltros() {
    final Map<String, dynamic> filters = {};

    if (_areaDeInteresse != null) {
      filters['areaDeInteresse'] = _areaDeInteresse;
    }
    if (_genero != null) {
      filters['genero'] = _genero;
    }
    if (_setor != null) {
      filters['setor'] = _setor;
    }
    // 2. LÓGICA ATUALIZADA: O filtro de idade só é incluído se o slider tiver sido tocado.
    if (_idadeSliderFoiTocado) {
      filters['idadeRange'] = _idadeRange;
    }

    widget.onApplyFilters(filters);
    Navigator.of(context).pop();
  }

  void _limparFiltros() {
    setState(() {
      _areaDeInteresse = null;
      _genero = null;
      _idadeRange = const RangeValues(18, 24);
      _setor = null;
      // 3. ATUALIZAÇÃO: Também reseta a variável de controle ao limpar.
      _idadeSliderFoiTocado = false;
    });
    widget.onApplyFilters({});
    Navigator.of(context).pop();
  }

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
          _buildRadioGroup('Gênero', ['Feminino', 'Masculino', 'Outro'], _genero,
              (val) {
            setState(() => _genero = val);
          }),
          const SizedBox(height: 20),
          // A chamada para o método de construção do slider permanece a mesma.
          // A mágica acontece dentro dele agora.
          _buildRangeSlider('Idade', _idadeRange, (values) {
            setState(() {
              _idadeRange = values;
            });
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

  Widget _buildRangeSlider(String label, RangeValues currentRange,
      ValueChanged<RangeValues> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ${currentRange.start.round()} - ${currentRange.end.round()} anos',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        RangeSlider(
          values: currentRange,
          min: 18,
          max: 24,
          divisions: 6, //24 - 18
          labels: RangeLabels(
            currentRange.start.round().toString(),
            currentRange.end.round().toString(),
          ),
          // 4. LÓGICA ATUALIZADA: A interação do usuário ativa o filtro.
          onChanged: (values) {
            // Primeiro, marcamos que o usuário interagiu com o slider.
            if (!_idadeSliderFoiTocado) {
              setState(() {
                _idadeSliderFoiTocado = true;
              });
            }
            // Em seguida, chamamos a função original para atualizar os valores.
            onChanged(values);
          },
        ),
      ],
    );
  }
  
  // Os métodos _buildDropdown e _buildRadioGroup permanecem inalterados
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
}