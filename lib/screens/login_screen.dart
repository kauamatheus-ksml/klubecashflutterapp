import 'package:flutter/material.dart';
import 'package:klube_cash_app/screens/forgot_password_screen.dart';
import 'package:klube_cash_app/screens/register_screen.dart';
import 'package:klube_cash_app/services/auth_service.dart';
import 'package:klube_cash_app/screens/home_screen.dart'; // Supondo uma tela de início após o login

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true; // Estado para controlar a visibilidade da senha

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final String email = _emailController.text;
      final String password = _passwordController.text;

      try {
        final user = await AuthService().login(email, password);
        if (user != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else {
          setState(() {
            _errorMessage = 'Email ou senha incorretos.';
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = e.toString();
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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  'assets/images/logo_klubecash.png',
                  height: 120,
                ),
                const SizedBox(height: 30),
                const Text(
                  'Bem-vindo de volta!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Text(
                  'Entre na sua conta e continue transformando suas compras em dinheiro de volta.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 40),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Campo de E-mail
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'E-mail',
                          hintStyle: TextStyle(color: Colors.grey[700]),
                          fillColor: Colors.white, // Fundo branco
                          filled: true, // Preenchimento ativado
                          border: OutlineInputBorder(
                            // Borda arredondada
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none, // Sem borda visível
                          ),
                          prefixIcon: Padding( // Ícone de prefixo
                            padding: const EdgeInsets.only(left: 10.0, right: 0.0), // Ajustar padding do ícone
                            child: Icon(Icons.email_outlined, color: Colors.grey[600]), // Ícone de email
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 0), // Ajustar padding do conteúdo
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, digite seu e-mail';
                          }
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return 'E-mail inválido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      // Campo de Senha
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          hintText: 'Senha',
                          hintStyle: TextStyle(color: Colors.grey[700]),
                          fillColor: Colors.white, // Fundo branco
                          filled: true, // Preenchimento ativado
                          border: OutlineInputBorder(
                            // Borda arredondada
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none, // Sem borda visível
                          ),
                          prefixIcon: Padding( // Ícone de prefixo
                            padding: const EdgeInsets.only(left: 10.0, right: 0.0), // Ajustar padding do ícone
                            child: Icon(Icons.lock_outline, color: Colors.grey[600]), // Ícone de cadeado
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 0), // Ajustar padding do conteúdo
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, digite sua senha';
                          }
                          return null;
                        },
                      ),
                       Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // Navegar para a tela de recuperação de senha
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
                            );
                          },
                          child: const Text(
                            'Esqueci minha senha',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (_errorMessage != null)
                        Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      const SizedBox(height: 10),
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF7A00),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                onPressed: _login,
                                child: const Text(
                                  'Entrar',
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
                const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Não tem conta?',
                        style: TextStyle(color: Colors.white70),
                      ),
                      TextButton(
                        onPressed: () {
                          // Navegar para a tela de cadastro
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => RegisterScreen()),
                          );
                        },
                        child: const Text(
                          'Cadastre-se grátis',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 40),
                Image.asset(
                  'assets/images/mascote_klubecash.png',
                  height: 150,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}