// lib/widgets/custom_app_bar.dart
import 'package:flutter/material.dart';
import 'package:klube_cash_app/screens/login_screen.dart';
import 'package:klube_cash_app/screens/profile_screen.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int notificationCount;
  final String userInitial;
  final VoidCallback? onNotificationPressed;
  final VoidCallback? onUserAvatarPressed;

  const CustomAppBar({
    Key? key,
    this.notificationCount = 0,
    this.userInitial = 'K',
    this.onNotificationPressed,
    this.onUserAvatarPressed,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      // Remove o padding horizontal padrão do AppBar
      titleSpacing: 0, 

      title: Row(
        // Use mainAxisAlignment.spaceBetween para empurrar o logo para a esquerda
        // e os ícones para a direita.
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        // mainAxisSize.max faz a Row ocupar toda a largura disponível do título
        mainAxisSize: MainAxisSize.max, 
        children: [
          // Logo Klube Cash
          Padding(
            padding: const EdgeInsets.only(left: 16.0), // Padding fixo à esquerda
            child: Image.asset(
              'assets/images/logo_klubecash1.png', // Verifique este nome de arquivo
              height: 30, // Tamanho fixo do logo
            ),
          ),
          
          // Este Spacer flexível empurrará o grupo de ícones da direita
          const Spacer(), 

          // Grupo de Ícones da Direita (Notificações, Avatar, Dropdown)
          // Esta Row interna usará `mainAxisSize.min` para ocupar apenas o espaço necessário pelos seus filhos
          // e o `Spacer` acima controlará o espaçamento.
          Row(
            mainAxisSize: MainAxisSize.min, // ESSENCIAL: Faz com que esta Row não tente se expandir além do necessário
            children: [
              // Ícone de Notificações com Contador
              Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none, color: Colors.grey, size: 28),
                    onPressed: onNotificationPressed ?? () { debugPrint('Notificações padrão'); },
                  ),
                  if (notificationCount > 0)
                    Positioned(
                      right: 8, // Posição do contador
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF7A00),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          '$notificationCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                ],
              ),
              const SizedBox(width: 8), // Espaçamento entre sino e avatar

              // Avatar do Usuário
              GestureDetector(
                onTap: onUserAvatarPressed ?? () { debugPrint('Avatar padrão'); },
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFFFF7A00),
                  child: Text(
                    userInitial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4), // Espaçamento entre avatar e dropdown

              // Ícone de Dropdown (menu suspenso)
              PopupMenuButton<String>(
                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey, size: 28),
                onSelected: (String result) {
                  if (result == 'profile') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProfileScreen()),
                    );
                  } else if (result == 'logout') {
                    debugPrint('Usuário deslogado!');
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                      (Route<dynamic> route) => false,
                    );
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'profile',
                    child: Row(
                      children: [
                        Icon(Icons.person_outline, color: Colors.black54),
                        SizedBox(width: 8),
                        Text('Meu Perfil'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.black54),
                        SizedBox(width: 8),
                        Text('Logout'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8), // Padding à direita final do grupo de ícones
            ],
          ),
        ],
      ),
    );
  }
}