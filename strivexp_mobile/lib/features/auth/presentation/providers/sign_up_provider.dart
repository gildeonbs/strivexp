import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/sign_up_state_model.dart';

class SignUpNotifier extends StateNotifier<SignUpStateModel> {
  SignUpNotifier() : super(SignUpStateModel());

  void setBirthday(DateTime date) {
    state = state.copyWith(birthday: date);
  }

  // Futuros métodos:
  // void setName(String first, String last) { ... }
  // void setCredentials(String email, String pass) { ... }
}

// Provider global para o fluxo de cadastro
final signUpProvider = StateNotifierProvider<SignUpNotifier, SignUpStateModel>((ref) {
  return SignUpNotifier();
});

