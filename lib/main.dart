import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valinor_ludoteca_desktop/providers/accounts_provider.dart';
import 'package:valinor_ludoteca_desktop/providers/cash_provider.dart';
import 'package:valinor_ludoteca_desktop/screens/administracion_screen.dart';
import 'package:valinor_ludoteca_desktop/screens/reportes_screen.dart';
import 'screens/inventario_screen.dart';
import 'screens/ventas_screen.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  // Creamos el provider
  final cashProvider = CashProvider();
  await cashProvider.cargarCaja(); // 👈 carga el valor de BD

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AccountsProvider()),
        ChangeNotifierProvider.value(value: cashProvider), // 👈 usamos el inicializado
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Valinor Ludoteca',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const ValinorApp(),
      ),
    ),
  );
}

class ValinorApp extends StatefulWidget {
  const ValinorApp({super.key});

  @override
  State<ValinorApp> createState() => _ValinorAppState();
}

class _ValinorAppState extends State<ValinorApp> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    InventarioScreen(),
    VentasScreen(),
    ReportesScreen(),
    AdministracionScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Valinor Ludoteca"),
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Inventario',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.point_of_sale),
            label: 'Ventas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Reportes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.admin_panel_settings),
            label: 'Administración',
          ),
        ],
        onTap: _onItemTapped,
      ),
    );
  }

}
