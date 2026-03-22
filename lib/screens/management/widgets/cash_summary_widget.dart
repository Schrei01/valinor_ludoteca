import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valinor_ludoteca_desktop/providers/caja_provider.dart';
import 'package:valinor_ludoteca_desktop/providers/cash_provider.dart';
import 'package:valinor_ludoteca_desktop/providers/deudas_provider.dart';
import 'package:valinor_ludoteca_desktop/providers/nequi_provider.dart';
import 'package:valinor_ludoteca_desktop/screens/management/widgets/cash_card_widget.dart';

class CashSummary extends StatelessWidget {
  const CashSummary({super.key});

  @override
  Widget build(BuildContext context) {
    final caja = context.watch<CashProvider>().totalEnCaja;
    final nequi = context.watch<NequiProvider>().totalEnNequi;
    final cajaMayor = context.watch<CajaMayorProvider>().totalEnCajaMayor;
    final deudas = context.watch<DeudasProvider>().totalEnDeudas;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 4,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        CashCardWidget(
          title: "Caja",
          value: caja,
          color: Colors.green,
        ),
        CashCardWidget(
          title: "Nequi",
          value: nequi,
          color: Colors.purple,
        ),
        CashCardWidget(
          title: "Caja Mayor",
          value: cajaMayor,
          color: Colors.blue,
        ),
        CashCardWidget(
          title: "Deudas",
          value: deudas,
          color: Colors.red,
        ),
      ],
    );
  }
}