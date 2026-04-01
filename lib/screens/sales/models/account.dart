import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:valinor_ludoteca_desktop/models/saleline.dart';

class Account {
  final String id;
  final TextEditingController nameController;
  final FocusNode nameFocusNode;
  List<SaleLine> saleLines;
  double total;

  Account({String? name})
      : id = const Uuid().v4(),
        nameController = TextEditingController(text: name ?? "Cuenta"),
        nameFocusNode = FocusNode(),
        saleLines = [SaleLine()],
        total = 0.0 {
    // 🔹 Selecciona todo el texto automáticamente al recibir el foco
    nameFocusNode.addListener(() {
      if (nameFocusNode.hasFocus) {
        nameController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: nameController.text.length,
        );
      }
    });
  }

  void dispose() {
    nameController.dispose();
    nameFocusNode.dispose();
  }
}