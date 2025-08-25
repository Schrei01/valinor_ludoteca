import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import 'package:intl/intl.dart';

class ReportesScreen extends StatefulWidget {
  const ReportesScreen({Key? key}) : super(key: key);

  @override
  State<ReportesScreen> createState() => _ReportesScreenState();
}

class _ReportesScreenState extends State<ReportesScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  List<Map<String, dynamic>> _reportData = [];
  double _totalGeneral = 0;
  double _totalGanancias = 0;
  bool _loading = false;

  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd HH:mm');
  final NumberFormat _currencyFormat = NumberFormat("#,##0", "es_CO");

  Future<void> _selectDateTime(BuildContext context, bool isStart) async {
    final initialDate = isStart ? (_startDate ?? DateTime.now()) : (_endDate ?? DateTime.now());

    // Primero selecciona fecha
    final newDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (newDate != null) {
      // Después selecciona hora
      final newTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate),
      );

      if (newTime != null) {
        final fullDateTime = DateTime(
          newDate.year,
          newDate.month,
          newDate.day,
          newTime.hour,
          newTime.minute,
        );

        setState(() {
          if (isStart) {
            _startDate = fullDateTime;
            if (_endDate != null && _endDate!.isBefore(fullDateTime)) {
              _endDate = fullDateTime;
            }
          } else {
            _endDate = fullDateTime;
            if (_startDate != null && _startDate!.isAfter(fullDateTime)) {
              _startDate = fullDateTime;
            }
          }
        });
      }
    }
  }

  Future<void> _loadReport() async {
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona ambas fechas')),
      );
      return;
    }

    setState(() {
      _loading = true;
    });

    final data = await DatabaseHelper.instance.getSalesReport(_startDate!, _endDate!);

    setState(() {
      _reportData = List<Map<String, dynamic>>.from(data['report']);
      _totalGeneral = data['totalGeneral'];
      _totalGanancias = data['totalGanancias'];
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text('Reporte de Ventas',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => _selectDateTime(context, true),
                child: Text(
                  _startDate == null ? 'Fecha inicio' : _dateFormat.format(_startDate!),
                ),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: () => _selectDateTime(context, false),
                child: Text(
                  _endDate == null ? 'Fecha fin' : _dateFormat.format(_endDate!),
                ),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: _loadReport,
                child: const Text('Generar'),
              ),
            ],
          ),

          const SizedBox(height: 20),

          if (_loading) const CircularProgressIndicator(),

          if (!_loading && _reportData.isEmpty)
            const Text('No hay datos para el rango seleccionado'),

          if (!_loading && _reportData.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: _reportData.length,
                itemBuilder: (context, index) {
                  final item = _reportData[index];
                  return ListTile(
                    title: Text(item['name']),
                    subtitle: Text('Cantidad vendida: ${item['total_quantity']}'),
                    trailing:
                        Text('Total: \$${_currencyFormat.format(item['total_sales'])}'),
                  );
                },
              ),
            ),
          const SizedBox(height: 16),

          Text(
            'Total general: \$${_currencyFormat.format(_totalGeneral)}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 40),
          Text(
            'Total ganancias: \$${_currencyFormat.format(_totalGanancias)}',
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
          ),
        ],
      ),
    );
  }
}
