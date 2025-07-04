import 'package:flutter/material.dart';
import 'package:klube_cash_app/screens/home_screen.dart'; // Importe suas telas
import 'package:klube_cash_app/screens/my_balance_screen.dart'; // Você precisará criar esta
import 'package:klube_cash_app/screens/statement_screen.dart'; // Você precisará criar esta
import 'package:klube_cash_app/screens/profile_screen.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex; // Índice da aba ativa
  final ValueChanged<int>? onItemSelected; // Callback para quando um item é selecionado

  const CustomBottomNavBar({
    Key? key,
    required this.currentIndex,
    this.onItemSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: 'Início',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_balance_wallet_outlined), // Ícone de carteira para "Meu Saldo"
          label: 'Meu Saldo',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_outlined), // Ícone de recibo/extrato
          label: 'Extrato',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outlined),
          label: 'Perfil',
        ),
      ],
      currentIndex: currentIndex,
      selectedItemColor: const Color(0xFFFF7A00), // Cor laranja do protótipo para o item selecionado
      unselectedItemColor: Colors.grey[700], // Cor cinza para itens não selecionados
      showUnselectedLabels: true, // Garante que labels de não selecionados apareçam
      type: BottomNavigationBarType.fixed, // Impede que os ícones se expandam
      onTap: (index) {
        // Lógica de navegação baseada no índice selecionado
        if (onItemSelected != null) {
          onItemSelected!(index);
        } else {
          // Navegação padrão se nenhum onItemSelected for fornecido
          _navigateToScreen(context, index);
        }
      },
    );
  }

  void _navigateToScreen(BuildContext context, int index) {
    switch (index) {
      case 0:
        // Se já estiver na Home, não faz nada ou popUntil para a rota principal
        if (ModalRoute.of(context)?.settings.name != '/') {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (Route<dynamic> route) => false, // Remove todas as rotas anteriores
          );
        }
        break;
      case 1:
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MyBalanceScreen()),
          (Route<dynamic> route) => route.isFirst, // Mantém apenas a rota raiz (Home)
        );
        break;
      case 2:
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const StatementScreen()),
          (Route<dynamic> route) => route.isFirst,
        );
        break;
      case 3:
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => ProfileScreen()),
          (Route<dynamic> route) => route.isFirst,
        );
        break;
    }
  }
}