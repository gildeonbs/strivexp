import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_datasource.dart';
import '../models/dashboard_models.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepositoryImpl(ref.read(dashboardRemoteDataSourceProvider));
});

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource _dataSource;

  DashboardRepositoryImpl(this._dataSource);

  @override
  Future<DashboardModel> getDashboard() => _dataSource.getDashboard();

  @override
  Future<void> completeChallenge(String id) => _dataSource.completeChallenge(id);

  @override
  Future<void> skipChallenge(String id) => _dataSource.skipChallenge(id);
}