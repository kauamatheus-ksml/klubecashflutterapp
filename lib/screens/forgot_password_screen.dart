import 'package:flutter/material.dart';
import 'package:klube_cash_app/services/auth_service.dart';
import 'package:klube_cash_app/screens/login_screen.dart'; // Para retornar à tela de login

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _message; // Para sucesso ou erro
  bool _isSuccess = false; // Para mudar a cor da mensagem

  Future<void> _sendInstructions() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _message = null;
        _isSuccess = false;
      });

      final String email = _emailController.text;

      try {
        await AuthService().requestPasswordReset(email);
        setState(() {
          _message = 'Se o e-mail estiver cadastrado, as instruções foram enviadas.'; // Mensagem de sucesso como no PHP
          _isSuccess = true;
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
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'assets/images/logo_klubecash.png',
                height: 100,
              ),
              SizedBox(height: 20),
              // Ícone da chave (recuperar senha)
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white,
                child: Icon(Icons.vpn_key_outlined, size: 40, color: Color(0xFFF86F21)),
              ),
              SizedBox(height: 20),
              Text.rich(
                TextSpan(
                  text: 'Recuperar ',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'senha',
                      style: TextStyle(
                        color: Color(0xFFF86F21),
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                'Não se preocupe! Vamos ajudar você a recuperar o acesso à sua conta.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              SizedBox(height: 40),

              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Email da sua conta',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'Digite o email da sua conta',
                        hintStyle: TextStyle(color: Colors.grey[700]),
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(left: 10.0, right: 0.0),
                          child: Icon(Icons.email_outlined, color: Colors.grey[600]),
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 0),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, digite seu e-mail.';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'E-mail inválido.';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    if (_message != null)
                      Container( // Usar Container para estilizar a mensagem de feedback
                        padding: EdgeInsets.all(15),
                        margin: EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: _isSuccess ? Colors.green[50] : Colors.red[50], // Cores diferentes para sucesso/erro
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
                    SizedBox(height: 10),
                    _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFF86F21),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              onPressed: _sendInstructions,
                              child: Text(
                                'Enviar instruções',
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
              SizedBox(height: 30),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Como funciona?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 15),
              _buildHowItWorksStep('1', 'Digite o email da sua conta.'),
              _buildHowItWorksStep('2', 'Receba o link de recuperação por email.'),
              _buildHowItWorksStep('3', 'Crie uma nova senha segura.'),
              _buildHowItWorksStep('4', 'Faça login com sua nova senha.'),
              SizedBox(height: 30),
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Color(0xFFF0F9FF),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Color(0xFF3B82F6), width: 1.5),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: Color(0xFF3B82F6)),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'O link de recuperação expira em 2 horas por segurança. Se não receber o email, verifique sua caixa de spam.',
                        style: TextStyle(color: Color(0xFF1E40AF), fontSize: 14),
                      ),
                    ),
                  ],
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

  Widget _buildHowItWorksStep(String stepNumber, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              stepNumber,
              style: TextStyle(
                color: Color(0xFFF86F21),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              description,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}