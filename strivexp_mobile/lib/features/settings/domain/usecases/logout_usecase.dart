import '../repositories/settings_repository.dart';

class LogoutUseCase {
  final SettingsRepository _repository;
  LogoutUseCase(this._repository);

  Future<void> call() async {
    await _repository.logout();
  }
}