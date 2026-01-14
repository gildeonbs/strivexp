import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/sign_up_state_model.dart';

class SignUpNotifier extends StateNotifier<SignUpStateModel> {
  SignUpNotifier() : super(SignUpStateModel());

  void setBirthday(DateTime date) {
    state = state.copyWith(birthday: date);
  }

  void setName(String firstName, String lastName) {
    state = state.copyWith(firstName: firstName, lastName: lastName);
  }

  void setEmail(String email) {
    state = state.copyWith(email: email);
  }
}

// Provider global para o fluxo de cadastro
final signUpProvider = StateNotifierProvider<SignUpNotifier, SignUpStateModel>((ref) {
  return SignUpNotifier();
});

