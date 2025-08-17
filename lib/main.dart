import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valinor_ludoteca_desktop/providers/accounts_provider.dart';
import 'package:valinor_ludoteca_desktop/screens/reportes_screen.dart';
import 'screens/inventario_screen.dart';
import 'screens/ventas_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AccountsProvider()),
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
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<String> _titles = [
    'Inventario',
    'Ventas',
    'Reportes',
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Valinor Ludoteca',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Scaffold(
        appBar: AppBar(
          title: Text(_titles[_selectedIndex]),
        ),
        body: _screens[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
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
          ],
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
