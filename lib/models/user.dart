class User {
  final int id;
  final String nome;
  final String email;
  final String tipo;

  User({
    required this.id,
    required this.nome,
    required this.email,
    required this.tipo,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      nome: json['nome'],
      email: json['email'],
      tipo: json['tipo'],
    );
  }
}