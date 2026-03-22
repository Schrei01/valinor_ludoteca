import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valinor_ludoteca_desktop/providers/deudas_provider.dart';
import 'providers/cash_provider.dart';
import 'providers/nequi_provider.dart';
import 'providers/caja_provider.dart';
import 'providers/accounts_provider.dart';
import 'screens/inventario_screen.dart';
import 'screens/ventas_screen.dart';
import 'screens/reportes_screen.dart';
import 'screens/management/management_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Creamos el provider y cargamos valores desde BD
  final cashProvider = CashProvider();
  await cashProvider.cargarCaja();

  final nequiProvider = NequiProvider();
  await nequiProvider.cargarNequi();

  final cajaProvider = CajaMayorProvider();
  await cajaProvider.cargarTotal();

  final deudasProvider = DeudasProvider();
  await deudasProvider.cargarTotal();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AccountsProvider()),
        ChangeNotifierProvider.value(value: cashProvider),
        ChangeNotifierProvider.value(value: nequiProvider),
        ChangeNotifierProvider.value(value: cajaProvider),
        ChangeNotifierProvider.value(value: deudasProvider),
      ],
      child: const ValinorAppWrapper(),
    ),
  );
}

// Wrapper para aplicar MaterialApp con tema
class ValinorAppWrapper extends StatelessWidget {
  const ValinorAppWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Valinor Sanctum', // Nombre temático
      theme: ThemeData(
        primaryColor: const Color.fromARGB(255, 18, 17, 19),
        scaffoldBackgroundColor: Colors.grey.shade100,
        appBarTheme: AppBarTheme(
          backgroundColor: const Color.fromARGB(255, 0, 0, 0),
          elevation: 4,
          centerTitle: true,
        ),
        textTheme: Theme.of(context).textTheme,
      ),
      home: const ValinorApp(),
    );
  }
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
    ManagementScreen(),
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
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'assets/logo_valinor.png', // Ícono élfico opcional
            width: 200,   // Ancho deseado
            height: 200,  // Alto deseado
            fit: BoxFit.contain,
          ),
        ),
        title: const Text(
          'Valinor Sanctum',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: Colors.white,
          ),
        ),
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.deepPurple.shade700,
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

