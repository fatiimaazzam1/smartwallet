import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smartwallet_mobile/l10n/l10n.dart';

import 'app/router/app_router.dart';
import 'core/localization/app_locale_controller.dart';
import 'core/network/api_client.dart';
import 'core/network/auth_interceptor.dart';
import 'core/storage/onboarding_storage.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/datasources/auth_local_data_source.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/budgets/data/datasources/budget_remote_data_source.dart';
import 'features/budgets/data/repositories/budget_repository.dart';
import 'features/budgets/presentation/controllers/budget_controller.dart';
import 'features/dashboard/data/repositories/dashboard_repository.dart';
import 'features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'features/planned_expenses/data/datasources/planned_expense_remote_data_source.dart';
import 'features/planned_expenses/data/repositories/planned_expense_repository.dart';
import 'features/planned_expenses/presentation/controllers/planned_expense_controller.dart';
import 'features/categories/data/datasources/category_remote_data_source.dart';
import 'features/categories/data/repositories/category_repository.dart';
import 'features/categories/presentation/controllers/category_controller.dart';
import 'features/profile/data/datasources/profile_remote_data_source.dart';
import 'features/profile/data/repositories/profile_repository.dart';
import 'features/profile/presentation/controllers/profile_controller.dart';
import 'features/transactions/data/datasources/transaction_remote_data_source.dart';
import 'features/transactions/data/repositories/transaction_repository.dart';
import 'features/transactions/presentation/controllers/transaction_history_controller.dart';
import 'features/wallet/data/datasources/wallet_remote_data_source.dart';
import 'features/wallet/data/repositories/wallet_repository.dart';
import 'features/wallet/presentation/controllers/wallet_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final AppLocaleController localeController = AppLocaleController();
  final ApiClient apiClient = ApiClient();

  final AuthRemoteDataSource authRemoteDataSource = AuthRemoteDataSource(
    apiClient: apiClient,
  );
  final AuthLocalDataSource authLocalDataSource = AuthLocalDataSource();
  final AuthRepository authRepository = AuthRepository(
    remoteDataSource: authRemoteDataSource,
    localDataSource: authLocalDataSource,
  );

  apiClient.addInterceptor(
    AuthInterceptor(apiClient: apiClient, authRepository: authRepository),
  );

  final ProfileRepository profileRepository = ProfileRepository(
    remoteDataSource: ProfileRemoteDataSource(apiClient: apiClient),
  );
  final ProfileController profileController = ProfileController(
    profileRepository: profileRepository,
    authRepository: authRepository,
    localeController: localeController,
  );

  final CategoryRepository categoryRepository = CategoryRepository(
    remoteDataSource: CategoryRemoteDataSource(apiClient: apiClient),
  );
  final CategoryController categoryController = CategoryController(
    categoryRepository: categoryRepository,
  );

  final WalletController walletController = WalletController(
    walletRepository: WalletRepository(
      remoteDataSource: WalletRemoteDataSource(apiClient: apiClient),
    ),
  );

  final TransactionRepository transactionRepository = TransactionRepository(
    remoteDataSource: TransactionRemoteDataSource(apiClient: apiClient),
  );
  final TransactionHistoryController transactionHistoryController =
      TransactionHistoryController(transactionRepository: transactionRepository);

  final BudgetRepository budgetRepository = BudgetRepository(
    remoteDataSource: BudgetRemoteDataSource(apiClient: apiClient),
  );
  final BudgetController budgetController = BudgetController(
    repository: budgetRepository,
  );

  final PlannedExpenseRepository plannedExpenseRepository =
      PlannedExpenseRepository(
        remoteDataSource: PlannedExpenseRemoteDataSource(apiClient: apiClient),
      );
  final PlannedExpenseController plannedExpenseController =
      PlannedExpenseController(repository: plannedExpenseRepository);

  final DashboardController dashboardController = DashboardController(
    repository: DashboardRepository(apiClient: apiClient),
  );

  final AppRouter appRouter = AppRouter(
    onboardingStorage: OnboardingStorage(),
    authRepository: authRepository,
    profileController: profileController,
    walletController: walletController,
    categoryController: categoryController,
    transactionRepository: transactionRepository,
    transactionHistoryController: transactionHistoryController,
    budgetRepository: budgetRepository,
    budgetController: budgetController,
    plannedExpenseRepository: plannedExpenseRepository,
    plannedExpenseController: plannedExpenseController,
    dashboardController: dashboardController,
  );

  runApp(
    ChangeNotifierProvider<AppLocaleController>.value(
      value: localeController,
      child: SmartWalletApp(router: appRouter.router),
    ),
  );

  unawaited(localeController.loadSavedPreference());
}

class SmartWalletApp extends StatelessWidget {
  const SmartWalletApp({required this.router, super.key});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    final AppLocaleController localeController =
        context.watch<AppLocaleController>();

    return MaterialApp.router(
      onGenerateTitle: (BuildContext context) => context.l10n.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      locale: localeController.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeListResolutionCallback:
          (List<Locale>? locales, Iterable<Locale> supportedLocales) {
        return localeController.resolveLocale(locales);
      },
      routerConfig: router,
    );
  }
}
