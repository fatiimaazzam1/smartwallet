abstract final class AppRoutes {
  AppRoutes._();

  static const String startupName = 'startup';
  static const String startupPath = '/';

  static const String getStartedName = 'getStarted';
  static const String getStartedPath = '/get-started';

  static const String registerName = 'register';
  static const String registerPath = '/register';

  static const String verifyEmailName = 'verifyEmail';
  static const String verifyEmailPath = '/verify-email';

  static const String loginName = 'login';
  static const String loginPath = '/login';

  static const String forgotPasswordName = 'forgotPassword';
  static const String forgotPasswordPath = '/forgot-password';

  static const String verifyResetCodeName = 'verifyResetCode';
  static const String verifyResetCodePath = '/verify-reset-code';

  static const String resetPasswordName = 'resetPassword';
  static const String resetPasswordPath = '/reset-password';

  static const String homeName = 'home';
  static const String homePath = '/home';

  static const String editProfileName = 'editProfile';
  static const String editProfilePath = '/profile/edit';

  static const String preferencesName = 'preferences';
  static const String preferencesPath = '/profile/preferences';

  static const String categoriesName = 'categories';
  static const String categoriesPath = '/profile/categories';

  static const String addIncomeTransactionName = 'addIncomeTransaction';
  static const String addIncomeTransactionPath = '/transactions/income/add';

  static const String addExpenseTransactionName = 'addExpenseTransaction';
  static const String addExpenseTransactionPath = '/transactions/expense/add';

  static const String transactionDetailsName = 'transactionDetails';
  static const String transactionDetailsPath = '/transactions/:transactionId';

  static const String editTransactionName = 'editTransaction';
  static const String editTransactionPath =
      '/transactions/:transactionId/edit';

  static const String createBudgetName = 'createBudget';
  static const String createBudgetPath = '/budgets/add';

  static const String budgetDetailsName = 'budgetDetails';
  static const String budgetDetailsPath = '/budgets/:budgetId';

  static const String editBudgetName = 'editBudget';
  static const String editBudgetPath = '/budgets/:budgetId/edit';

  static const String createPlannedExpenseName = 'createPlannedExpense';
  static const String createPlannedExpensePath = '/planned-expenses/add';

  static const String plannedExpenseDetailsName = 'plannedExpenseDetails';
  static const String plannedExpenseDetailsPath = '/planned-expenses/:plannedExpenseId';

  static const String editPlannedExpenseName = 'editPlannedExpense';
  static const String editPlannedExpensePath = '/planned-expenses/:plannedExpenseId/edit';
}
