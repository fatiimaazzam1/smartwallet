abstract final class ApiEndpoints {
  ApiEndpoints._();

  static const String authBase = '/api/v1/auth';
  static const String usersBase = '/api/v1/users';
  static const String walletsBase = '/api/v1/wallets';
  static const String categoriesBase = '/api/v1/categories';
  static const String transactionsBase = '/api/v1/transactions';
  static const String budgetsBase = '/api/v1/budgets';
  static const String plannedExpensesBase = '/api/v1/planned-expenses';
  static const String dashboardBase = '/api/v1/dashboard';

  static const String register = '$authBase/register';
  static const String verifyEmail = '$authBase/verify-email';
  static const String resendVerificationCode =
      '$authBase/resend-verification-code';

  static const String login = '$authBase/login';
  static const String refresh = '$authBase/refresh';
  static const String logout = '$authBase/logout';

  static const String forgotPassword = '$authBase/forgot-password';

  static const String resendPasswordResetCode =
      '$authBase/resend-password-reset-code';

  static const String verifyPasswordResetCode =
      '$authBase/verify-password-reset-code';

  static const String resetPassword = '$authBase/reset-password';

  static const String currentUser = '$usersBase/me';
  static const String currentUserPreferences = '$currentUser/preferences';
  static const String currentWallet = '$walletsBase/me';
  static const String categories = categoriesBase;
  static const String transactions = transactionsBase;
  static const String budgets = budgetsBase;
  static const String plannedExpenses = plannedExpensesBase;
  static const String dashboard = dashboardBase;

  static String categoryById(int categoryId) => '$categoriesBase/$categoryId';
  static String transactionById(int transactionId) =>
      '$transactionsBase/$transactionId';
  static String budgetById(int budgetId) => '$budgetsBase/$budgetId';
  static String budgetExpenses(int budgetId) => '$budgetsBase/$budgetId/expenses';
  static String plannedExpenseById(int id) => '$plannedExpensesBase/$id';
  static String cancelPlannedExpense(int id) => '$plannedExpensesBase/$id/cancel';
  static String markPlannedExpensePaid(int id) => '$plannedExpensesBase/$id/mark-paid';
}
