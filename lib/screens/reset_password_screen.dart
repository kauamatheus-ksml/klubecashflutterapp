import 'package:flutter/material.dart';
import 'package:klube_cash_app/services/auth_service.dart';
import 'package:klube_cash_app/screens/login_screen.dart'; // Para retornar à tela de login

class ResetPasswordScreen extends StatefulWidget {
  final String? token; // Token recebido via link de email

  const ResetPasswordScreen({Key? key, this.token}) : super(key: key);

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmNewPasswordController = TextEditingController();

  bool _isLoading = false;
  String? _message;
  bool _isSuccess = false;
  bool _obscureNewPassword = true;
  bool _obscureConfirmNewPassword = true;

  @override
  void initState() {
    super.initState();
    // Mensagem de erro inicial se o token não for válido ou não existir
    if (widget.token == null || widget.token!.isEmpty) {
      _message = 'Token de recuperação não fornecido. Por favor, solicite um novo link.';
      _isSuccess = false; // Indica que é um erro
    } else {
      // Se o token existe, a validação ocorrerá ao tentar redefinir a senha no backend
      // A mensagem "Token inválido ou expirado" será exibida APÓS a tentativa.
      // O protótipo PHP mostra essa mensagem ANTES, o que implicaria uma validação inicial no initState.
      // Para simplificar, vamos lidar com isso apenas na resposta do backend.
    }
  }

  Future<void> _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      if (widget.token == null || widget.token!.isEmpty) {
        setState(() {
          _message = 'Token de recuperação não fornecido. Por favor, solicite um novo link.';
          _isSuccess = false;
        });
        return;
      }

      setState(() {
        _isLoading = true;
        _message = null; // Limpa mensagens anteriores
        _isSuccess = false;
      });

      final String newPassword = _newPasswordController.text;

      try {
        await AuthService().resetPassword(widget.token!, newPassword);
        setState(() {
          _message = 'Sua senha foi atualizada com sucesso! Você já pode fazer login.';
          _isSuccess = true;
        });
        // Redirecionar para a tela de login após um breve atraso
        Future.delayed(Duration(seconds: 3), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
        });
      } catch (e) {
        setState(() {
          _message = e.toString().contains('Exception:') ? e.toString().replaceAll('Exception: ', '') : 'Erro inesperado: $e';
          _isSuccess = false;
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange, // Mantendo a cor principal do app
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'assets/images/logo_klubecash.png', // Substitua por 'logo-icon.png' se tiver
                height: 100,
              ),
              SizedBox(height: 20),
              // Ícone de cadeado como no recover-password.php para "reset"
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white,
                child: Icon(Icons.lock_outline, size: 40, color: Color(0xFFFF7A00)), // Ícone de cadeado
              ),
              SizedBox(height: 20),
              Text.rich(
                TextSpan(
                  text: 'Criar ',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'nova senha',
                      style: TextStyle(
                        color: Color(0xFFFF7A00),
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                'Sua nova senha deve ser segura e fácil de lembrar',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              SizedBox(height: 40),

              // Mensagens de feedback (sucesso/erro)
              if (_message != null)
                Container(
                  padding: EdgeInsets.all(15),
                  margin: EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: _isSuccess ? Colors.green[50] : Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _isSuccess ? Colors.green[300]! : Colors.red[300]!, width: 1),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isSuccess ? Icons.check_circle_outline : Icons.warning_amber_outlined,
                        color: _isSuccess ? Colors.green[700] : Colors.red[700],
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _message!,
                          style: TextStyle(color: _isSuccess ? Colors.green[700] : Colors.red[700], fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                ),

              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nova Senha',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _newPasswordController,
                      obscureText: _obscureNewPassword,
                      decoration: InputDecoration(
                        hintText: 'Digite sua nova senha',
                        hintStyle: TextStyle(color: Colors.grey[700]),
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(left: 10.0, right: 0.0),
                          child: Icon(Icons.lock_outline, color: Colors.grey[600]),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureNewPassword ? Icons.visibility : Icons.visibility_off,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureNewPassword = !_obscureNewPassword;
                            });
                          },
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 0),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, digite sua nova senha.';
                        }
                        if (value.length < 8) { // Mínimo 8 caracteres conforme constants.php
                          return 'A senha deve ter no mínimo 8 caracteres.';
                        }
                        if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).*$').hasMatch(value)) {
                            return 'Min. 1 maiúscula, 1 minúscula e 1 número.';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 15),
                    Text(
                      'Confirme a Nova Senha',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _confirmNewPasswordController,
                      obscureText: _obscureConfirmNewPassword,
                      decoration: InputDecoration(
                        hintText: 'Confirme sua nova senha',
                        hintStyle: TextStyle(color: Colors.grey[700]),
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(left: 10.0, right: 0.0),
                          child: Icon(Icons.lock_outline, color: Colors.grey[600]),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmNewPassword ? Icons.visibility : Icons.visibility_off,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmNewPassword = !_obscureConfirmNewPassword;
                            });
                          },
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 0),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, confirme sua nova senha.';
                        }
                        if (value != _newPasswordController.text) {
                          return 'As senhas não coincidem.';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 30),
                    _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFFF7A00),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              onPressed: _resetPassword,
                              child: Text(
                                'Alterar minha senha',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              // Link para "Fazer login" no final
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
                child: Text.rich(
                  TextSpan(
                    text: 'Lembrou da senha? ',
                    style: TextStyle(color: Colors.white70),
                    children: <TextSpan>[
                      TextSpan(
                        text: 'Fazer login',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 50),
              Text(
                '© 2025 Klube Cash. Todos os direitos reservados.',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}