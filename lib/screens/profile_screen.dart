import 'package:flutter/material.dart';
import 'package:klube_cash_app/widgets/custom_app_bar.dart';
import 'package:klube_cash_app/services/auth_service.dart';
import 'package:klube_cash_app/models/profile.dart';
import 'package:klube_cash_app/widgets/custom_bottom_nav_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
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
            const SnackBar(
              content: Text('Informações pessoais atualizadas com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          _loadProfileData();
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar as informações pessoais: ${error.toString()}'),
            backgroundColor: Colors.red,
          ),
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
            const SnackBar(
              content: Text('Endereço atualizado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          _loadProfileData();
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar o endereço: ${error.toString()}'),
            backgroundColor: Colors.red,
          ),
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
          const SnackBar(
            content: Text('A confirmação de senha não confere.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      setState(() => _isLoading = true);
      
      try {
        final success = await AuthService().changePassword(
          _senhaAtualController.text, 
          _novaSenhaController.text
        );
        
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Senha alterada com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Limpar os campos após sucesso
          _senhaAtualController.clear();
          _novaSenhaController.clear();
          _confirmarNovaSenhaController.clear();
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao alterar a senha: ${error.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nomeCompletoController.dispose();
    _cpfController.dispose();
    _emailPrincipalController.dispose();
    _telefoneController.dispose();
    _emailAlternativoController.dispose();
    _cepController.dispose();
    _logradouroController.dispose();
    _numeroController.dispose();
    _complementoController.dispose();
    _bairroController.dispose();
    _cidadeController.dispose();
    _estadoController.dispose();
    _senhaAtualController.dispose();
    _novaSenhaController.dispose();
    _confirmarNovaSenhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        userInitial: _profileData?.nomeCompleto.isNotEmpty == true 
            ? _profileData!.nomeCompleto.substring(0, 1).toUpperCase() 
            : 'K'
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Erro: $_errorMessage',
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _loadProfileData,
                        child: const Text('Tentar Novamente'),
                      ),
                    ],
                  ),
                )
              : DefaultTabController(
                  length: 3,
                  child: Column(
                    children: [
                      const TabBar(
                        labelColor: Colors.orange,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: Colors.orange,
                        tabs: [
                          Tab(icon: Icon(Icons.person), text: 'Pessoal'),
                          Tab(icon: Icon(Icons.location_on), text: 'Endereço'),
                          Tab(icon: Icon(Icons.lock), text: 'Senha'),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _buildPersonalTab(),
                            _buildAddressTab(),
                            _buildPasswordTab(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 3),
    );
  }

  Widget _buildPersonalTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKeyPersonal,
        child: Column(
          children: [
            TextFormField(
              controller: _nomeCompletoController,
              decoration: const InputDecoration(
                labelText: 'Nome Completo',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, digite seu nome completo';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _cpfController,
              decoration: const InputDecoration(
                labelText: 'CPF',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.badge),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, digite seu CPF';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailPrincipalController,
              decoration: const InputDecoration(
                labelText: 'Email Principal',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, digite seu email';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return 'Por favor, digite um email válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _telefoneController,
              decoration: const InputDecoration(
                labelText: 'Telefone',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, digite seu telefone';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailAlternativoController,
              decoration: const InputDecoration(
                labelText: 'Email Alternativo (opcional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.alternate_email),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _savePersonalInformation,
                icon: const Icon(Icons.save),
                label: const Text('Salvar Informações Pessoais'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKeyAddress,
        child: Column(
          children: [
            TextFormField(
              controller: _cepController,
              decoration: const InputDecoration(
                labelText: 'CEP',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_pin),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, digite seu CEP';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _logradouroController,
              decoration: const InputDecoration(
                labelText: 'Logradouro',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, digite seu logradouro';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _numeroController,
                    decoration: const InputDecoration(
                      labelText: 'Número',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.numbers),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _complementoController,
                    decoration: const InputDecoration(
                      labelText: 'Complemento',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _bairroController,
              decoration: const InputDecoration(
                labelText: 'Bairro',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_city),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, digite seu bairro';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _cidadeController,
                    decoration: const InputDecoration(
                      labelText: 'Cidade',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_city),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, digite sua cidade';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    controller: _estadoController,
                    decoration: const InputDecoration(
                      labelText: 'UF',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Digite UF';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _saveAddress,
                icon: const Icon(Icons.save),
                label: const Text('Salvar Endereço'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKeyPassword,
        child: Column(
          children: [
            TextFormField(
              controller: _senhaAtualController,
              decoration: const InputDecoration(
                labelText: 'Senha Atual',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, digite sua senha atual';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _novaSenhaController,
              decoration: const InputDecoration(
                labelText: 'Nova Senha',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock_outline),
              ),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, digite sua nova senha';
                }
                if (value.length < 8) {
                  return 'A senha deve ter pelo menos 8 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmarNovaSenhaController,
              decoration: const InputDecoration(
                labelText: 'Confirmar Nova Senha',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock_outline),
              ),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, confirme sua nova senha';
                }
                if (value != _novaSenhaController.text) {
                  return 'As senhas não coincidem';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
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
    );
  }
}