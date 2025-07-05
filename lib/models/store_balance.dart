// lib/models/store_balance.dart
class StoreBalance {
  final int lojaId;
  final String lojaNome; // Nome da loja
  final double saldoDisponivel;
  final double totalCreditado;
  final double totalUsado;

  StoreBalance({
    required this.lojaId,
    required this.lojaNome,
    required this.saldoDisponivel,
    required this.totalCreditado,
    required this.totalUsado,
  });

  factory StoreBalance.fromJson(Map<String, dynamic> json) {
    return StoreBalance(
      lojaId: json['loja_id'] as int,
      lojaNome: json['loloja_nome'] as String, // Assume que o backend enviará o nome da loja
      saldoDisponivel: (json['saldo_disponivel'] ?? 0.0) as double,
      totalCreditado: (json['total_creditado'] ?? 0.0) as double,
      totalUsado: (json['total_usado'] ?? 0.0) as double,
    );
  }
}