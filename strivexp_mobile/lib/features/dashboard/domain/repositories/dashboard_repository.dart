import '../../data/models/dashboard_models.dart';

abstract class DashboardRepository {
  Future<DashboardModel> getDashboard();
  Future<void> completeChallenge(String id);
  Future<void> skipChallenge(String id);
}