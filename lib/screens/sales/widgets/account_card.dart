import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:valinor_ludoteca_desktop/models/products.dart';
import 'package:valinor_ludoteca_desktop/models/saleline.dart';
import 'package:valinor_ludoteca_desktop/providers/accounts_provider.dart';
import 'package:valinor_ludoteca_desktop/providers/cash_provider.dart';
import 'package:valinor_ludoteca_desktop/providers/nequi_provider.dart';
import 'package:valinor_ludoteca_desktop/screens/sales/models/account.dart';
import 'package:valinor_ludoteca_desktop/screens/sales/widgets/add_sale_button.dart';
import 'package:valinor_ludoteca_desktop/screens/sales/widgets/register_sales_button.dart';
import 'package:valinor_ludoteca_desktop/screens/sales/widgets/total_display.dart';
import 'package:valinor_ludoteca_desktop/widgets/sale_line_widget.dart';

class AccountCard extends StatelessWidget {
  final Account account;
  final int index;
  final List<Product> products;
  final Future<Map<String, dynamic>> Function(Account) onRegister;

  const AccountCard({
    super.key,
    required this.account,
    required this.index,
    required this.products,
    required this.onRegister,
  });

  @override
  Widget build(BuildContext context) {
    final accountsProvider = context.read<AccountsProvider>();
    final currencyFormat = NumberFormat("#,##0", "es_CO");

    return Card(
      key: ValueKey(account.id),
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Nombre + eliminar cuenta
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: account.nameController,
                    focusNode: account.nameFocusNode,
                    decoration: const InputDecoration(
                      hintText: "Nombre de la cuenta",
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    accountsProvider.removeAccount(index);
                  },
                ),
              ],
            ),

            const SizedBox(height: 12),

            // 🔹 Líneas de venta
            ...account.saleLines.asMap().entries.map((saleEntry) {
              int saleIndex = saleEntry.key;
              SaleLine line = saleEntry.value;

              return Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: SaleLineWidget(
                      line: line,
                      products: products,
                      onChanged: () {
                        accountsProvider.updateTotal(index);
                      },
                      onRemove: account.saleLines.length > 1
                          ? () {
                              accountsProvider.removeSaleLine(index, saleIndex);
                            }
                          : null,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "\$${currencyFormat.format(line.total)}",
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),

            const SizedBox(height: 12),

            // 🔹 Agregar línea
            AddSaleButton(
              onPressed: () {
                accountsProvider.addSaleLine(index);
              },
            ),

            const SizedBox(height: 20),

            // 🔹 Total + registrar
            Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TotalDisplay(total: account.total),
                  ),
                ),
                const SizedBox(width: 16),
                RegisterSaleButton(
                  onPressed: () async {
                    final result = await onRegister(account);
                    bool hasError = result['hasError'];
                    List<double> lineTotals = result['totals'];

                    if (!hasError) {
                      for (int i = 0; i < account.saleLines.length; i++) {
                        final line = account.saleLines[i];
                        final total = lineTotals[i];

                        if (line.paymentMethod == "Efectivo") {
                          context.read<CashProvider>().agregarVenta(total);
                        } else if (line.paymentMethod == "Nequi") {
                          context.read<NequiProvider>().agregarVenta(total);
                        }
                      }

                      accountsProvider.removeAccount(index);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}