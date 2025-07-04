// lib/models/profile.dart
class Profile {
  final String nomeCompleto;
  final String cpf;
  final String emailPrincipal;
  final String telefone;
  final String emailAlternativo;
  final String cep;
  final String logradouro;
  final String numero;
  final String complemento;
  final String bairro;
  final String cidade;
  final String estado;

  Profile({
    required this.nomeCompleto,
    required this.cpf,
    required this.emailPrincipal,
    required this.telefone,
    required this.emailAlternativo,
    required this.cep,
    required this.logradouro,
    required this.numero,
    required this.complemento,
    required this.bairro,
    required this.cidade,
    required this.estado,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      nomeCompleto: json['nome'] ?? '',
      cpf: json['cpf'] ?? '',
      emailPrincipal: json['email'] ?? '',
      telefone: json['telefone'] ?? '',
      emailAlternativo: json['email_alternativo'] ?? '',
      cep: json['cep'] ?? '',
      logradouro: json['logradouro'] ?? '',
      numero: json['numero'] ?? '',
      complemento: json['complemento'] ?? '',
      bairro: json['bairro'] ?? '',
      cidade: json['cidade'] ?? '',
      estado: json['estado'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nome': nomeCompleto,
      'cpf': cpf,
      'email': emailPrincipal,
      'telefone': telefone,
      'email_alternativo': emailAlternativo,
      'cep': cep,
      'logradouro': logradouro,
      'numero': numero,
      'complemento': complemento,
      'bairro': bairro,
      'cidade': cidade,
      'estado': estado,
    };
  }
}