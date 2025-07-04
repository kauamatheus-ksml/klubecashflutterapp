import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:klube_cash_app/models/user.dart';
import 'package:klube_cash_app/models/profile.dart'; // Importa o modelo de Perfil
import 'package:klube_cash_app/models/transaction_history.dart'; // Importa o modelo de TransactionHistory
import 'package:klube_cash_app/models/user_balance.dart'; // Importa o modelo de UserBalance
import 'package:klube_cash_app/models/store.dart'; // Importa o modelo de Store (para lojas populares)
import 'package:shared_preferences/shared_preferences.dart'; // Para obter e salvar o token

class AuthService {
  // A URL base do seu backend.
  // **A PORTA ESTÁ MANTIDA COMO 3001, CONFORME SOLICITADO.**
  // Certifique-se que este IP seja o do seu computador na rede local ou o domínio do servidor.
  final String _baseUrl = 'http://192.168.100.53:3001';

  // Método de Login
  Future<User?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'senha': password}),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      
      // Salva o token (se existir na resposta)
      if (data['token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('authToken', data['token']);
      }

      return User.fromJson(data['user']);
    } else {
      final Map<String, dynamic> errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Email ou senha incorretos.');
    }
  }

  // Método de Registro
  Future<bool> register({
    required String nome,
    required String email,
    required String telefone,
    required String senha,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'nome': nome,
        'email': email,
        'telefone': telefone,
        'senha': senha,
        'tipo': 'cliente',
      }),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      final Map<String, dynamic> errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Falha ao registrar usuário.');
    }
  }

  // Método para solicitar a recuperação de senha
  Future<void> requestPasswordReset(String email) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/request-password-reset'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email}),
    );

    if (response.statusCode == 200) {
      // Sucesso.
    } else {
      final Map<String, dynamic> errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Erro ao solicitar recuperação de senha.');
    }
  }

  // Método para redefinir a senha usando o token
  Future<void> resetPassword(String token, String newPassword) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'token': token,
        'newPassword': newPassword,
      }),
    );

    if (response.statusCode == 200) {
      // Sucesso
    } else {
      final Map<String, dynamic> errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Erro ao redefinir senha.');
    }
  }

  // Método para obter os dados do perfil do usuário
  Future<Profile> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('authToken'); // Obtém o token armazenado

    if (token == null) {
      throw Exception('Token de autenticação não encontrado. Por favor, faça login novamente.');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/api/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Envia o token no cabeçalho
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return Profile.fromJson(data['user']); // Assume que o backend retorna os dados do perfil dentro de 'user'
    } else {
      final Map<String, dynamic> errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Falha ao carregar os dados do perfil.');
    }
  }

  // Método para atualizar os dados do perfil do usuário
  Future<bool> updateProfile(Profile profile) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('authToken');

    if (token == null) {
      throw Exception('Token de autenticação não encontrado. Por favor, faça login novamente.');
    }

    final response = await http.put(
      Uri.parse('$_baseUrl/api/profile/update'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(profile.toJson()), // Converte o objeto Profile para JSON
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      final Map<String, dynamic> errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Falha ao atualizar o perfil.');
    }
  }

  // Método para alterar a senha
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('authToken');

    if (token == null) {
      throw Exception('Token de autenticação não encontrado. Por favor, faça login novamente.');
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/api/change-password'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else if (response.statusCode == 401) {
      // Mensagem específica para senha atual incorreta
      throw Exception('Senha atual incorreta.');
    } else {
      final Map<String, dynamic> errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Falha ao alterar a senha.');
    }
  }

  // Método para obter o histórico de transações
  Future<List<TransactionHistory>> getTransactionsHistory({int limit = 5, int offset = 0}) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('authToken');

    if (token == null) {
      throw Exception('Token de autenticação não encontrado. Por favor, faça login novamente.');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/api/transactions?limit=$limit&offset=$offset'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> transactionsJson = data['transactions']; // Assumindo que o backend retorna 'transactions'
      
      return transactionsJson.map((json) => TransactionHistory.fromJson(json)).toList();
    } else {
      final Map<String, dynamic> errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Falha ao carregar o histórico de transações.');
    }
  }

  // Método para obter o saldo do usuário
  Future<UserBalance> getUserBalance() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('authToken');

    if (token == null) {
      throw Exception('Token de autenticação não encontrado. Por favor, faça login novamente.');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/api/user-balance'), // Novo endpoint
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return UserBalance.fromJson(data['balance']); // Assumindo que o backend retorna 'balance'
    } else {
      final Map<String, dynamic> errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Falha ao carregar o saldo do usuário.');
    }
  }

  // Método para obter lojas populares
  Future<List<Store>> getPopularStores({int limit = 5}) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('authToken');

    if (token == null) {
      throw Exception('Token de autenticação não encontrado. Por favor, faça login novamente.');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/api/popular-stores?limit=$limit'), // Novo endpoint
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> storesJson = data['stores']; // Assumindo que o backend retorna 'stores'
      
      return storesJson.map((json) => Store.fromJson(json)).toList();
    } else {
      final Map<String, dynamic> errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Falha ao carregar lojas populares.');
    }
  }
}