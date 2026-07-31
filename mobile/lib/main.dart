import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app/router/app_router.dart';
import 'core/network/api_client.dart';
import 'core/network/auth_interceptor.dart';
import 'core/storage/onboarding_storage.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/datasources/auth_local_data_source.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final ApiClient apiClient = ApiClient();

  final AuthRemoteDataSource authRemoteDataSource = AuthRemoteDataSource(
    apiClient: apiClient,
  );

  final AuthLocalDataSource authLocalDataSource = AuthLocalDataSource();

  final AuthRepository authRepository = AuthRepository(
    remoteDataSource: authRemoteDataSource,
    localDataSource: authLocalDataSource,
  );

  final AuthInterceptor authInterceptor = AuthInterceptor(
    apiClient: apiClient,
    authRepository: authRepository,
  );

  apiClient.addInterceptor(authInterceptor);

  final OnboardingStorage onboardingStorage = OnboardingStorage();

  final AppRouter appRouter = AppRouter(
    onboardingStorage: onboardingStorage,
    authRepository: authRepository,
  );

  runApp(SmartWalletApp(router: appRouter.router));
}

class SmartWalletApp extends StatelessWidget {
  const SmartWalletApp({required this.router, super.key});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SmartWallet',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}
