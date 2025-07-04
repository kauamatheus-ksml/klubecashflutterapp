// lib/models/transaction_history.dart
class TransactionHistory {
  final int id;
  final String lojaNome;
  final DateTime dataTransacao;
  final double valorTotal;
  // Alterado de 'valorCashback' para 'valorCashbackCliente'
  final double valorCashbackCliente; 
  final double valorUsado;
  final String status;

  TransactionHistory({
    required this.id,
    required this.lojaNome,
    required this.dataTransacao,
    required this.valorTotal,
    // Usar 'valorCashbackCliente' aqui
    required this.valorCashbackCliente, 
    required this.valorUsado,
    required this.status,
  });

  factory TransactionHistory.fromJson(Map<String, dynamic> json) {
    return TransactionHistory(
      id: json['id'] as int,
      lojaNome: json['loja_nome'] as String,
      dataTransacao: DateTime.parse(json['data_transacao'] as String),
      // Adicionado ?? 0.0 para garantir que não seja nulo e seja um double
      valorTotal: (json['valor_total'] ?? 0.0) as double, 
      // Mapear para o novo campo 'valorCashbackCliente'
      // O backend envia o valor do cliente sob a chave 'valor_cashback' para o Flutter
      valorCashbackCliente: (json['valor_cashback'] ?? 0.0) as double, 
      valorUsado: (json['valor_usado'] ?? 0.0) as double, 
      status: json['status'] as String,
    );
  }

  get valorCashback => null;
}