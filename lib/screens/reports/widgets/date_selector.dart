import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:valinor_ludoteca_desktop/screens/reports/controller/report_controller.dart';

class DateSelector extends StatelessWidget {
  final ReportsController controller;

  const DateSelector({super.key, required this.controller});

  Future<void> _selectDateTime(
      BuildContext context, bool isStart) async {

    final initialDate = isStart
        ? (controller.startDate ?? DateTime.now())
        : (controller.endDate ?? DateTime.now());

    final newDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (newDate == null) return;

    if (!context.mounted) return; // ✅ protección

    final newTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );

    if (newTime == null) return;

    if (!context.mounted) return; // ✅ protección otra vez

    final fullDateTime = DateTime(
      newDate.year,
      newDate.month,
      newDate.day,
      newTime.hour,
      newTime.minute,
    );

    if (isStart) {
      controller.setStartDate(fullDateTime);
    } else {
      controller.setEndDate(fullDateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    final format = DateFormat('yyyy-MM-dd HH:mm');

    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () => _selectDateTime(context, true),
            child: Text(
              controller.startDate == null
                ? 'Fecha inicio'
                : format.format(controller.startDate!),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () => _selectDateTime(context, false),
            child: Text(
              controller.endDate == null
                ? 'Fecha fin'
                : format.format(controller.endDate!),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}