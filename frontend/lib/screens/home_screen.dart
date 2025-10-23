import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';
import 'vacas_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _fazerLogout(BuildContext context) {
    ApiService.clearToken();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('MilkFlow'),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => _fazerLogout(context),
              tooltip: 'Sair',
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.dashboard), text: 'Dashboard'),
              Tab(icon: Icon(Icons.agriculture), text: 'Vacas'),
            ],
          ),
        ),
        body: const TabBarView(children: [DashboardScreen(), VacasScreen()]),
      ),
    );
  }
}
