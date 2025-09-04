import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:valinor_ludoteca_desktop/models/products.dart';
import 'package:valinor_ludoteca_desktop/models/saleline.dart';
import 'package:valinor_ludoteca_desktop/providers/accounts_provider.dart';
import 'package:valinor_ludoteca_desktop/providers/cash_provider.dart';
import 'package:valinor_ludoteca_desktop/providers/nequi_provider.dart';
import 'package:valinor_ludoteca_desktop/widgets/sale_line_widget.dart';
import '../db/database_helper.dart';
import 'package:uuid/uuid.dart';

class VentasScreen extends StatefulWidget {
  const VentasScreen({super.key});

  @override
  State<VentasScreen> createState() => _VentasScreenState();
}

class _VentasScreenState extends State<VentasScreen> {
  List<Product> _products = [];

  bool _loading = true;
  final List<SaleLine> _saleLines = [];


  @override
  void initState() {
    super.initState();
    _loadProducts();
    _saleLines.add(SaleLine());
  }


  Future<void> _loadProducts() async {
    final products = await DatabaseHelper.instance.getAvailableProducts();
    setState(() {
      _products = products;
      _loading = false;
      
    });
  }

  Future<Map<String, dynamic>> _registerSaleForAccount(Account account) async {
    bool hasError = false;

    for (var line in account.saleLines) {
      final quantity = int.tryParse(line.quantityController.text.trim());
      final product = line.product;
      final paymentMethod = line.paymentMethod;

      if (product == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecciona un producto en todas las líneas')),
        );
        hasError = true;
        break;
      }

      if (quantity == null || quantity <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cantidad inválida en alguna línea')),
        );
        hasError = true;
        break;
      }

      if (quantity > product.quantity) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cantidad mayor al stock disponible en ${product.name}')),
        );
        hasError = true;
        break;
      }

      if (paymentMethod == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Selecciona un medio de pago en todas las lineas')),
        );
        hasError = true;
        break;
      }
    }

    if (hasError) return {'hasError': true, 'totals': []};

    final now = DateTime.now().toIso8601String();

    // Guardar totales antes de limpiar
    List<double> lineTotals = [];

    for (var line in account.saleLines) {
      final quantity = int.parse(line.quantityController.text.trim());
      final product = line.product!;
      final totalLine = quantity * product.price;
      lineTotals.add(totalLine);

      await DatabaseHelper.instance.insertSale(product.id!, quantity, now);
    }

    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Venta registrada correctamente')),
    );

    // Limpiar la cuenta después
    for (var line in account.saleLines) {
      line.quantityController.clear();
      line.product = null;
    }
    account.total = 0;
    setState(() {});

    await _loadProducts();

    return {'hasError': false, 'totals': lineTotals};
  }

  

  @override
  Widget build(BuildContext context) {
    final accountsProvider = Provider.of<AccountsProvider>(context);
    final accounts = accountsProvider.accounts;

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text('Ventas', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),

              const SizedBox(height: 16),

              // Render de cada cuenta
              ...accounts.asMap().entries.map((entry) {
                final index = entry.key;
                final account = entry.value;

                return Card(
                  key: ValueKey(account.id),
                  margin: const EdgeInsets.only(bottom: 20),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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

                        // Lista de líneas de venta
                        ...account.saleLines.asMap().entries.map((saleEntry) {
                          int saleIndex = saleEntry.key;
                          SaleLine line = saleEntry.value;

                          double lineTotal = 0;
                          final quantity = int.tryParse(line.quantityController.text) ?? 0;
                          final price = line.product?.price ?? 0;
                          lineTotal = quantity * price;
                          final NumberFormat currencyFormat = NumberFormat("#,##0", "es_CO");

                          return Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: SaleLineWidget(
                                  line: line,
                                  products: _products,
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

                              // Cuarta casilla: monto de la línea
                              Expanded(
                                flex: 1,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    "\$${currencyFormat.format(lineTotal)}", // formato sin decimales
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

                        // Botón para agregar venta
                        AddSaleButton(
                          onPressed: () {
                            accountsProvider.addSaleLine(index);
                          },
                        ),

                        const SizedBox(height: 20),

                        // Total + botón registrar
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
                                final result = await _registerSaleForAccount(account);
                                bool hasError = result['hasError'];
                                List<double> lineTotals = result['totals'];

                                if (!hasError) {
                                  for (int i = 0; i < account.saleLines.length; i++) {
                                    final line = account.saleLines[i];
                                    final total = lineTotals[i];

                                    if (line.paymentMethod == "Efectivo") {
                                      // ignore: use_build_context_synchronously
                                      context.read<CashProvider>().agregarVenta(total);
                                    } else if (line.paymentMethod == "Nequi") {
                                      // ignore: use_build_context_synchronously
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
              }),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          accountsProvider.addAccount();
        },
        icon: const Icon(Icons.add),
        label: const Text("Nueva cuenta"),
      ),
    );
  }
}

class TotalDisplay extends StatelessWidget {
  final double total;
  final NumberFormat _currencyFormat = NumberFormat("#,##0", "es_CO");

  TotalDisplay({super.key, required this.total});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Total: \$${_currencyFormat.format(total)}',
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }
}

class AddSaleButton extends StatelessWidget {
  final VoidCallback onPressed;

  const AddSaleButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.add),
      label: const Text('Agregar venta'),
    );
  }
}

class RegisterSaleButton extends StatelessWidget {
  final VoidCallback onPressed;

  const RegisterSaleButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.purple,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
      ),
      child: const Text(
        'Registrar Venta',
        style: TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
  }
}



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

