import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:season_app/core/services/dio_client.dart';
import 'package:season_app/features/profile/controllers/profile_controller.dart';
import 'package:season_app/features/profile/data/datasources/profile_datasource.dart';
import 'package:season_app/features/profile/data/repositories/profile_repository.dart';

// Datasource Provider
final profileDataSourceProvider = Provider<ProfileRemoteDataSource>((ref) {
  return ProfileRemoteDataSource(DioHelper.instance.dio);
});

// Repository Provider
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final dataSource = ref.watch(profileDataSourceProvider);
  return ProfileRepository(dataSource);
});

// Controller Provider
final profileControllerProvider =
    NotifierProvider<ProfileController, ProfileState>(() {
  return ProfileController();
});

