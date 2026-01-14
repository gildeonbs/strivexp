import '../../data/models/auth_models.dart';
import '../repositories/auth_repository.dart';


class RegisterUseCase {
  final AuthRepository _repository;

  RegisterUseCase(this._repository);

  Future<void> call(RegisterRequestModel request) async {
    return await _repository.register(request);
  }
}

