import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:klube_cash_app/models/user.dart';
import 'package:klube_cash_app/models/profile.dart';
import 'package:klube_cash_app/models/transaction_history.dart';
import 'package:klube_cash_app/models/user_balance.dart';
import 'package:klube_cash_app/models/store.dart';
import 'package:klube_cash_app/models/store_balance.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String _baseUrl = 'https://klubecash.com/api';
  final bool _enableMockMode = true; // Habilitar modo mock para desenvolvimento

  // Método de Login com múltiplas tentativas e fallback
  Future<User?> login(String email, String password) async {
    // Lista de endpoints para tentar
    final loginEndpoints = [
      'users.php?action=login',
      'login.php',
      'auth.php?action=login',
      'api.php?action=login',
    ];

    for (String endpoint in loginEndpoints) {
      try {
        print('Tentando login em: $_baseUrl/$endpoint');
        
        final response = await http.post(
          Uri.parse('$_baseUrl/$endpoint'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'User-Agent': 'KlubeCashApp/1.0',
            'Access-Control-Allow-Origin': '*',
          },
          body: json.encode({
            'email': email,
            'senha': password,
            'password': password, // Tentar ambos os campos
          }),
        ).timeout(const Duration(seconds: 15));

        print('Response Status: ${response.statusCode}');
        print('Response Headers: ${response.headers}');
        print('Response Body: ${response.body}');

        if (response.statusCode == 200) {
          try {
            final Map<String, dynamic> data = json.decode(response.body);
            
            if (data['status'] == true || data['success'] == true) {
              // Salvar token se existir
              final token = data['token'] ?? data['access_token'] ?? data['jwt'];
              if (token != null) {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('authToken', token);
                await prefs.setString('userEmail', email);
              }

              // Criar objeto User
              final userData = data['user'] ?? data['data'] ?? {
                'id': 1,
                'nome': email.split('@')[0],
                'email': email,
                'tipo': 'cliente'
              };

              return User.fromJson(userData);
            } else {
              print('Login failed: ${data['message'] ?? 'Status false'}');
              if (endpoint == loginEndpoints.last) {
                throw Exception(data['message'] ?? 'Email ou senha incorretos.');
              }
              continue; // Tentar próximo endpoint
            }
          } catch (jsonError) {
            print('JSON Parse Error: $jsonError');
            if (endpoint == loginEndpoints.last) {
              throw Exception('Resposta inválida do servidor.');
            }
            continue;
          }
        } else if (response.statusCode == 404) {
          print('Endpoint $endpoint não encontrado, tentando próximo...');
          continue;
        } else {
          print('HTTP Error ${response.statusCode}: ${response.body}');
          if (endpoint == loginEndpoints.last) {
            throw Exception('Erro no servidor. Código: ${response.statusCode}');
          }
          continue;
        }
      } on SocketException catch (e) {
        print('Network Error: $e');
        if (endpoint == loginEndpoints.last) {
          // Se é o último endpoint e temos modo mock, usar dados mock
          if (_enableMockMode && _isValidTestCredential(email, password)) {
            return _getMockUser(email);
          }
          throw Exception('Sem conexão com a internet. Verifique sua conexão.');
        }
        continue;
      } on http.ClientException catch (e) {
        print('Client Error: $e');
        if (endpoint == loginEndpoints.last) {
          if (_enableMockMode && _isValidTestCredential(email, password)) {
            return _getMockUser(email);
          }
          throw Exception('Erro de conexão. Verifique sua internet.');
        }
        continue;
      } catch (e) {
        print('Unexpected Error: $e');
        if (endpoint == loginEndpoints.last) {
          if (_enableMockMode && _isValidTestCredential(email, password)) {
            return _getMockUser(email);
          }
          throw Exception('Erro inesperado: ${e.toString()}');
        }
        continue;
      }
    }

    // Se chegou aqui, nenhum endpoint funcionou
    if (_enableMockMode && _isValidTestCredential(email, password)) {
      return _getMockUser(email);
    }
    
    throw Exception('Não foi possível conectar ao servidor. Tente novamente.');
  }

  // Verificar se são credenciais de teste válidas
  bool _isValidTestCredential(String email, String password) {
    final validCredentials = [
      {'email': 'kauamatheus920@gmail.com', 'password': '123456'},
      {'email': 'teste@klubecash.com', 'password': '123456'},
      {'email': 'admin@klubecash.com', 'password': 'admin123'},
      {'email': 'user@test.com', 'password': 'password'},
    ];

    return validCredentials.any((cred) => 
      cred['email'] == email && cred['password'] == password);
  }

  // Criar usuário mock para desenvolvimento
  User _getMockUser(String email) {
    return User(
      id: 1,
      nome: email.split('@')[0].replaceAll(RegExp(r'[0-9]'), ''),
      email: email,
      tipo: 'cliente',
    );
  }

  // Método de Registro com fallback
  Future<bool> register({
    required String nome,
    required String email,
    required String telefone,
    required String senha,
  }) async {
    final registerEndpoints = [
      'users.php?action=register',
      'register.php',
      'auth.php?action=register',
    ];

    for (String endpoint in registerEndpoints) {
      try {
        print('Tentando registro em: $_baseUrl/$endpoint');
        
        final response = await http.post(
          Uri.parse('$_baseUrl/$endpoint'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'User-Agent': 'KlubeCashApp/1.0',
          },
          body: json.encode({
            'nome': nome,
            'email': email,
            'telefone': telefone,
            'senha': senha,
            'password': senha, // Fallback
            'tipo': 'cliente',
          }),
        ).timeout(const Duration(seconds: 15));

        print('Register Response: ${response.statusCode} - ${response.body}');

        if (response.statusCode == 200 || response.statusCode == 201) {
          final data = json.decode(response.body);
          if (data['status'] == true || data['success'] == true) {
            return true;
          }
        }
        
        if (response.statusCode != 404) {
          final data = json.decode(response.body);
          throw Exception(data['message'] ?? 'Erro ao registrar usuário.');
        }
      } catch (e) {
        print('Register Error on $endpoint: $e');
        if (endpoint == registerEndpoints.last) {
          if (_enableMockMode) {
            return true; // Simular sucesso no modo mock
          }
          throw Exception('Erro ao registrar: ${e.toString()}');
        }
      }
    }

    return _enableMockMode; // Retornar true se mock habilitado
  }

  // Método para obter saldo com valores mock como fallback
  Future<UserBalance> getUserBalance() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('authToken');

      if (token == null && !_enableMockMode) {
        throw Exception('Token de autenticação não encontrado.');
      }

      // Tentar diferentes endpoints
      final balanceEndpoints = [
        'users.php?action=balance',
        'balance.php',
        'user-balance.php',
      ];

      for (String endpoint in balanceEndpoints) {
        try {
          final response = await http.get(
            Uri.parse('$_baseUrl/$endpoint'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              if (token != null) 'Authorization': 'Bearer $token',
              'User-Agent': 'KlubeCashApp/1.0',
            },
          ).timeout(const Duration(seconds: 10));

          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            if (data['status'] == true) {
              return UserBalance.fromJson(data['data'] ?? data['balance']);
            }
          }
        } catch (e) {
          print('Balance Error on $endpoint: $e');
        }
      }
    } catch (e) {
      print('Balance Error: $e');
    }

    // Retornar dados mock como fallback
    return UserBalance(
      saldoDisponivel: 21.75,
      totalCreditado: 26.75,
      totalUsado: 5.00,
      saldoPendente: 15.00,
    );
  }

  // Método para obter transações com dados mock como fallback
  Future<List<TransactionHistory>> getTransactionsHistory({int limit = 5, int offset = 0}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('authToken');

      if (token != null) {
        final response = await http.get(
          Uri.parse('$_baseUrl/users.php?action=transactions&limit=$limit&offset=$offset'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ).timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['status'] == true) {
            final List<dynamic> transactionsJson = data['data'] ?? [];
            return transactionsJson.map((json) => TransactionHistory.fromJson(json)).toList();
          }
        }
      }
    } catch (e) {
      print('Transactions Error: $e');
    }

    // Retornar dados mock como fallback
    if (_enableMockMode) {
      return [
        TransactionHistory(
          id: 1,
          lojaNome: 'Loja Exemplo',
          dataTransacao: DateTime.now().subtract(const Duration(days: 1)),
          valorTotal: 100.00,
          valorCashbackCliente: 5.00,
          valorUsado: 0.00,
          status: 'aguardando',
        ),
        TransactionHistory(
          id: 2,
          lojaNome: 'Mercado Central',
          dataTransacao: DateTime.now().subtract(const Duration(days: 3)),
          valorTotal: 80.00,
          valorCashbackCliente: 4.00,
          valorUsado: 0.00,
          status: 'liberado',
        ),
      ];
    }

    return [];
  }

  // Método para obter lojas populares
  Future<List<Store>> getPopularStores({int limit = 5}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/stores.php?action=popular&limit=$limit'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          final List<dynamic> storesJson = data['data'] ?? data['stores'] ?? [];
          return storesJson.map((json) => Store.fromJson(json)).toList();
        }
      }
    } catch (e) {
      print('Stores Error: $e');
    }

    // Retornar dados mock como fallback
    if (_enableMockMode) {
      return [
        Store(
          id: 1,
          nomeFantasia: 'Loja Exemplo',
          porcentagemCashback: 5.0,
          logoUrl: null,
        ),
        Store(
          id: 2,
          nomeFantasia: 'Mercado Central',
          porcentagemCashback: 3.0,
          logoUrl: null,
        ),
      ];
    }

    return [];
  }

  // Método para obter saldos por loja
  Future<List<StoreBalance>> getStoreBalances() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('authToken');

      if (token != null) {
        final response = await http.get(
          Uri.parse('$_baseUrl/users.php?action=store_balances'),
          headers: {
            'Authorization': 'Bearer $token',
          },
        ).timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['status'] == true) {
            final List<dynamic> balancesJson = data['data'] ?? [];
            return balancesJson.map((json) => StoreBalance.fromJson(json)).toList();
          }
        }
      }
    } catch (e) {
      print('Store Balances Error: $e');
    }

    // Retornar dados mock como fallback
    if (_enableMockMode) {
      return [
        StoreBalance(
          storeId: 1,
          storeName: 'Loja Exemplo',
          saldoDisponivel: 21.75,
          totalCreditado: 26.75,
          totalUsado: 5.00,
          totalTransacoes: 12,
        ),
      ];
    }

    return [];
  }

  // Métodos básicos sem implementação de rede por enquanto
  Future<bool> requestPasswordReset(String email) async {
    if (_enableMockMode) {
      await Future.delayed(const Duration(seconds: 1));
      return true;
    }
    throw Exception('Funcionalidade não disponível no momento.');
  }

  Future<bool> resetPassword(String token, String newPassword) async {
    if (_enableMockMode) {
      await Future.delayed(const Duration(seconds: 1));
      return true;
    }
    throw Exception('Funcionalidade não disponível no momento.');
  }

  Future<Profile> getProfile() async {
    if (_enableMockMode) {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('userEmail') ?? 'usuario@teste.com';
      
      return Profile(
        nomeCompleto: 'Kaua Matheus da Silva Lopes',
        cpf: '123.456.789-00',
        emailPrincipal: email,
        telefone: '(11) 99999-9999',
        emailAlternativo: '',
        cep: '01234-567',
        logradouro: 'Rua Exemplo, 123',
        numero: '123',
        complemento: 'Apto 45',
        bairro: 'Centro',
        cidade: 'São Paulo',
        estado: 'SP',
      );
    }
    throw Exception('Funcionalidade não disponível no momento.');
  }

  Future<bool> updateProfile(Profile profile) async {
    if (_enableMockMode) {
      await Future.delayed(const Duration(seconds: 1));
      return true;
    }
    throw Exception('Funcionalidade não disponível no momento.');
  }

  Future<bool> changePassword(String currentPassword, String newPassword) async {
    if (_enableMockMode) {
      await Future.delayed(const Duration(seconds: 1));
      return true;
    }
    throw Exception('Funcionalidade não disponível no momento.');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
    await prefs.remove('userEmail');
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken') != null || _enableMockMode;
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }
}