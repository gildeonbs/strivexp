class SignUpStateModel {
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? password;
  final DateTime? birthday;

  SignUpStateModel({
    this.firstName,
    this.lastName,
    this.email,
    this.password,
    this.birthday,
  });

  // Método copyWith para imutabilidade (padrão Riverpod)
  SignUpStateModel copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? password,
    DateTime? birthday,
  }) {
    return SignUpStateModel(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      password: password ?? this.password,
      birthday: birthday ?? this.birthday,
    );
  }
}

