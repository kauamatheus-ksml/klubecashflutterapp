import 'package:flutter/material.dart';
import 'package:klube_cash_app/widgets/custom_app_bar.dart';
import 'package:klube_cash_app/services/auth_service.dart';
import 'package:klube_cash_app/models/profile.dart';
import 'package:klube_cash_app/widgets/custom_bottom_nav_bar.dart'; // Importe a nova nav bar

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKeyPersonal = GlobalKey<FormState>();
  final _formKeyAddress = GlobalKey<FormState>();
  final _formKeyPassword = GlobalKey<FormState>();

  final TextEditingController _nomeCompletoController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _emailPrincipalController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _emailAlternativoController = TextEditingController();
  final TextEditingController _cepController = TextEditingController();
  final TextEditingController _logradouroController = TextEditingController();
  final TextEditingController _numeroController = TextEditingController();
  final TextEditingController _complementoController = TextEditingController();
  final TextEditingController _bairroController = TextEditingController();
  final TextEditingController _cidadeController = TextEditingController();
  final TextEditingController _estadoController = TextEditingController();
  final TextEditingController _senhaAtualController = TextEditingController();
  final TextEditingController _novaSenhaController = TextEditingController();
  final TextEditingController _confirmarNovaSenhaController = TextEditingController();

  Profile? _profileData;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isProfileComplete = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final profile = await AuthService().getProfile();
      setState(() {
        _profileData = profile;
        _nomeCompletoController.text = profile.nomeCompleto;
        _cpfController.text = profile.cpf;
        _emailPrincipalController.text = profile.emailPrincipal;
        _telefoneController.text = profile.telefone;
        _emailAlternativoController.text = profile.emailAlternativo;
        _cepController.text = profile.cep;
        _logradouroController.text = profile.logradouro;
        _numeroController.text = profile.numero;
        _complementoController.text = profile.complemento;
        _bairroController.text = profile.bairro;
        _cidadeController.text = profile.cidade;
        _estadoController.text = profile.estado;
        _isLoading = false;
        _isProfileComplete = _checkProfileCompletion(profile);
      });
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  bool _checkProfileCompletion(Profile profile) {
    return profile.nomeCompleto.isNotEmpty &&
        profile.cpf.isNotEmpty &&
        profile.emailPrincipal.isNotEmpty &&
        profile.telefone.isNotEmpty &&
        profile.cep.isNotEmpty &&
        profile.logradouro.isNotEmpty &&
        profile.numero.isNotEmpty &&
        profile.bairro.isNotEmpty &&
        profile.cidade.isNotEmpty &&
        profile.estado.isNotEmpty;
  }

  Future<void> _savePersonalInformation() async {
    if (_formKeyPersonal.currentState!.validate()) {
      setState(() => _isLoading = true);
      final updatedProfile = Profile(
        nomeCompleto: _nomeCompletoController.text,
        cpf: _cpfController.text,
        emailPrincipal: _emailPrincipalController.text,
        telefone: _telefoneController.text,
        emailAlternativo: _emailAlternativoController.text,
        cep: _profileData?.cep ?? '',
        logradouro: _profileData?.logradouro ?? '',
        numero: _profileData?.numero ?? '',
        complemento: _profileData?.complemento ?? '',
        bairro: _profileData?.bairro ?? '',
        cidade: _profileData?.cidade ?? '',
        estado: _profileData?.estado ?? '',
      );
      try {
        final success = await AuthService().updateProfile(updatedProfile);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Informações pessoais atualizadas com sucesso!')),
          );
          _loadProfileData();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro ao atualizar as informações pessoais.')),
          );
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar: ${error.toString()}')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveAddress() async {
    if (_formKeyAddress.currentState!.validate()) {
      setState(() => _isLoading = true);
      final updatedProfile = Profile(
        nomeCompleto: _profileData?.nomeCompleto ?? '',
        cpf: _profileData?.cpf ?? '',
        emailPrincipal: _profileData?.emailPrincipal ?? '',
        telefone: _profileData?.telefone ?? '',
        emailAlternativo: _profileData?.emailAlternativo ?? '',
        cep: _cepController.text,
        logradouro: _logradouroController.text,
        numero: _numeroController.text,
        complemento: _complementoController.text,
        bairro: _bairroController.text,
        cidade: _cidadeController.text,
        estado: _estadoController.text,
      );
      try {
        final success = await AuthService().updateProfile(updatedProfile);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Endereço atualizado com sucesso!')),
          );
          _loadProfileData();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro ao atualizar o endereço.')),
          );
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar: ${error.toString()}')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _changePassword() async {
    if (_formKeyPassword.currentState!.validate()) {
      if (_novaSenhaController.text != _confirmarNovaSenhaController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('As novas senhas não coincidem.')),
        );
        return;
      }
      setState(() => _isLoading = true);
      try {
        final success = await AuthService().changePassword(_senhaAtualController.text, _novaSenhaController.text);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Senha alterada com sucesso!')),
          );
          _senhaAtualController.clear();
          _novaSenhaController.clear();
          _confirmarNovaSenhaController.clear();
        } else {
          // A mensagem de erro específica (senha atual incorreta) será tratada na AuthService
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao alterar a senha: ${error.toString()}')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(userInitial: _profileData?.nomeCompleto.isNotEmpty == true ? _profileData!.nomeCompleto.substring(0, 1).toUpperCase() : 'K'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text('Erro ao carregar os dados: $_errorMessage'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileCompletion(),
                      const SizedBox(height: 20),
                      _buildPersonalInformationForm(),
                      const SizedBox(height: 20),
                      _buildAddressForm(),
                      const SizedBox(height: 20),
                      _buildAccountSecurityForm(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
      bottomNavigationBar: const CustomBottomNavBar(
        currentIndex: 3, // Marca "Perfil" como ativo
      ),
    );
  }

  Widget _buildProfileCompletion() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Complete seu Perfil', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: _isProfileComplete ? 1.0 : 0.8, // Ajuste conforme sua lógica de completude
                      child: Container(
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text('${_isProfileComplete ? '100' : '80'}%', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
            ],
          ),
          const SizedBox(height: 8),
          if (_isProfileComplete)
            const Text.rich(
              TextSpan(
                children: [
                  WidgetSpan(
                    child: Padding(
                      padding: EdgeInsets.only(right: 4.0),
                      child: Icon(Icons.check_circle, color: Colors.green, size: 16),
                    ),
                  ),
                  TextSpan(text: 'Parabéns! Seu perfil está completo', style: TextStyle(color: Colors.green)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPersonalInformationForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Informações Pessoais', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 10),
        Form(
          key: _formKeyPersonal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nomeCompletoController,
                decoration: const InputDecoration(labelText: 'Nome Completo *'),
                validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
              ),
              TextFormField(
                controller: _cpfController,
                decoration: const InputDecoration(
                  labelText: 'CPF',
                  suffixIcon: Icon(Icons.check_circle, color: Colors.green), // Ícone diretamente no InputDecoration
                ),
                readOnly: true, // Como no protótipo
              ),
              TextFormField(
                controller: _emailPrincipalController,
                decoration: const InputDecoration(
                  labelText: 'E-mail Principal *',
                  suffixIcon: Icon(Icons.check_circle, color: Colors.green), // Ícone diretamente no InputDecoration
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
                readOnly: true, // Como no protótipo
              ),
              TextFormField(
                controller: _telefoneController,
                decoration: const InputDecoration(labelText: 'Telefone'),
              ),
              TextFormField(
                controller: _emailAlternativoController,
                decoration: const InputDecoration(labelText: 'E-mail Alternativo'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _savePersonalInformation,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Salvar Informações'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddressForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Endereço', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 10),
        Form(
          key: _formKeyAddress,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _cepController,
                decoration: const InputDecoration(labelText: 'CEP'),
                validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _logradouroController,
                      decoration: const InputDecoration(labelText: 'Logradouro'),
                      validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 80,
                    child: TextFormField(
                      controller: _numeroController,
                      decoration: const InputDecoration(labelText: 'Número'),
                      validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
                    ),
                  ),
                ],
              ),
              TextFormField(
                controller: _complementoController,
                decoration: const InputDecoration(labelText: 'Complemento'),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _bairroController,
                      decoration: const InputDecoration(labelText: 'Bairro'),
                      validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _cidadeController,
                      decoration: const InputDecoration(labelText: 'Cidade'),
                      validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 60,
                    child: TextFormField(
                      controller: _estadoController,
                      decoration: const InputDecoration(labelText: 'Estado'),
                      validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _saveAddress,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Salvar Endereço'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccountSecurityForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Segurança da Conta', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 10),
        Form(
          key: _formKeyPassword,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _senhaAtualController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Senha Atual *'),
                validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
              ),
              TextFormField(
                controller: _novaSenhaController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Nova Senha *', hintText: 'Mínimo de 8 caracteres'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo obrigatório';
                  // Verificação de comprimento mínimo (8 caracteres)
                  if (value.length < 8) return 'A senha deve ter no mínimo 8 caracteres.';
                  // Verificação de maiúscula, minúscula, e número
                  if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).*$').hasMatch(value)) {
                      return 'A senha deve conter pelo menos uma letra maiúscula, uma minúscula e um número.';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _confirmarNovaSenhaController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Confirmar Nova Senha *'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo obrigatório';
                  if (value != _novaSenhaController.text) return 'As senhas não coincidem';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _changePassword,
                  icon: const Icon(Icons.lock_outline),
                  label: const Text('Alterar Senha'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}