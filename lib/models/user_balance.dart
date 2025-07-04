// lib/models/user_balance.dart
class UserBalance {
  final double saldoDisponivel;
  final double totalCreditado;
  final double totalUsado;
  final double saldoPendente; // NOVO CAMPO: Saldo pendente do usuário

  UserBalance({
    required this.saldoDisponivel,
    required this.totalCreditado,
    required this.totalUsado,
    required this.saldoPendente, // Adicionado ao construtor
  });

  factory UserBalance.fromJson(Map<String, dynamic> json) {
    return UserBalance(
      saldoDisponivel: (json['saldo_disponivel'] ?? 0.0) as double,
      totalCreditado: (json['total_creditado'] ?? 0.0) as double,
      totalUsado: (json['total_usado'] ?? 0.0) as double,
      saldoPendente: (json['saldo_pendente'] ?? 0.0) as double, // Mapeado do JSON
    );
  }
}