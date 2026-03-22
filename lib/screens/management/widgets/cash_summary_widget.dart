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

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12, // espacio horizontal
      runSpacing: 12, // espacio vertical
      children: [
        SizedBox(
          width: 250, // 👈 controlas ancho
          child: CashCardWidget(
            title: "Caja",
            value: caja,
            color: Colors.green,
          ),
        ),
        SizedBox(
          width: 250,
          child: CashCardWidget(
            title: "Nequi",
            value: nequi,
            color: Colors.purple,
          ),
        ),
        SizedBox(
          width: 250,
          child: CashCardWidget(
            title: "Caja Mayor",
            value: cajaMayor,
            color: Colors.blue,
          ),
        ),
        SizedBox(
          width: 250,
          child: CashCardWidget(
            title: "Deudas",
            value: deudas,
            color: Colors.red,
          ),
        ),
      ],
    );
  }
}