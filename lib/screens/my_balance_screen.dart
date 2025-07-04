import 'package:flutter/material.dart';
import 'package:klube_cash_app/widgets/custom_app_bar.dart';
import 'package:klube_cash_app/widgets/custom_bottom_nav_bar.dart';

class MyBalanceScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(userInitial: 'K'), // Use seu CustomAppBar
      body: Center(
        child: Text(
          'Página Meu Saldo',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 1, // Marca "Meu Saldo" como ativo
      ),
    );
  }
}