import '../repositories/dashboard_repository.dart';
import '../../data/models/dashboard_models.dart';

class GetDashboardUseCase {
  final DashboardRepository _repository;
  GetDashboardUseCase(this._repository);
  Future<DashboardModel> call() => _repository.getDashboard();
}

class CompleteChallengeUseCase {
  final DashboardRepository _repository;
  CompleteChallengeUseCase(this._repository);
  Future<void> call(String id) => _repository.completeChallenge(id);
}

class SkipChallengeUseCase {
  final DashboardRepository _repository;
  SkipChallengeUseCase(this._repository);
  Future<void> call(String id) => _repository.skipChallenge(id);
}