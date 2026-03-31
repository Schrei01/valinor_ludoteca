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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = (constraints.maxWidth - (12 * 4)) / 5;
      
          return Row(
            children: [
              SizedBox(
                width: itemWidth,
                child: CashCardWidget(
                  title: "Caja",
                  value: caja,
                  color: Colors.green,
                ),
              ),
              SizedBox(width: 12),
      
              SizedBox(
                width: itemWidth,
                child: CashCardWidget(
                  title: "Nequi",
                  value: nequi,
                  color: Colors.purple,
                ),
              ),
              SizedBox(width: 12),
      
              SizedBox(
                width: itemWidth,
                child: CashCardWidget(
                  title: "Caja Mayor",
                  value: cajaMayor,
                  color: Colors.blue,
                ),
              ),
              SizedBox(width: 12),
      
              SizedBox(
                width: itemWidth,
                child: CashCardWidget(
                  title: "Deudas",
                  value: deudas,
                  color: Colors.red,
                ),
              ),
              SizedBox(width: 12),
      
              SizedBox(
                width: itemWidth,
                child: CashCardWidget(
                  title: "Total",
                  value: caja + nequi + cajaMayor,
                  color: Colors.blue,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}