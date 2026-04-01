import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valinor_ludoteca_desktop/db/services/product_service.dart';
import 'package:valinor_ludoteca_desktop/models/products.dart';
import 'package:valinor_ludoteca_desktop/providers/accounts_provider.dart';
import 'package:valinor_ludoteca_desktop/screens/sales/controller/sales_controller.dart';
import 'package:valinor_ludoteca_desktop/screens/sales/models/account.dart';
import 'package:valinor_ludoteca_desktop/screens/sales/widgets/account_card.dart';

class VentasScreen extends StatefulWidget {
  const VentasScreen({super.key});

  @override
  State<VentasScreen> createState() => _VentasScreenState();
}

class _VentasScreenState extends State<VentasScreen> {
  List<Product> _products = [];
  bool _loading = true;
  final ProductService _productService = ProductService();
  final SalesController _salesController = SalesController();

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _loading = true;
    });

    try {
      // Productos disponibles (>0)
      final available = await _productService.getAvailable();

      setState(() {
        _products = available;
        _loading = false;
      });
    } catch (e) {
      debugPrint("Error cargando productos: $e");
      setState(() {
        _loading = false;
      });
    }
  }

  Future<Map<String, dynamic>> _handleRegister(Account account) async {
    final result = await _salesController.registerSale(account);

    if (!mounted) return result;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result['message'])),
    );

    if (!result['hasError']) {
      await _loadProducts();
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final accountsProvider = Provider.of<AccountsProvider>(context);
    final accounts = accountsProvider.accounts;

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
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

                return AccountCard(
                  account: account,
                  index: index,
                  products: _products,
                  onRegister: _handleRegister,
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