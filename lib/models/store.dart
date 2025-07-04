// lib/models/store.dart
class Store {
  final int id;
  final String nomeFantasia;
  final double porcentagemCashback;
  final String? logoUrl; // URL do logo da loja

  Store({
    required this.id,
    required this.nomeFantasia,
    required this.porcentagemCashback,
    this.logoUrl,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'] as int,
      nomeFantasia: json['nome_fantasia'] as String,
      porcentagemCashback: (json['porcentagem_cashback'] as num).toDouble(),
      logoUrl: json['logo'] as String?, // Pode ser null
    );
  }
}