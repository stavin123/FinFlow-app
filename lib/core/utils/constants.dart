abstract class AppConstants {
  // Hive box names
  static const String userBox = 'userBox';
  static const String transactionBox = 'transactionBox';
  static const String budgetBox = 'budgetBox';
  static const String settingsBox = 'settingsBox';

  // Hive type IDs
  static const int userModelTypeId = 0;
  static const int transactionModelTypeId = 1;
  static const int budgetModelTypeId = 2;

  // Settings keys
  static const String currentUserKey = 'currentUser';
  static const String isLoggedInKey = 'isLoggedIn';
  static const String themeModeKey = 'themeMode';

  // Transaction categories
  static const List<String> expenseCategories = [
    'Food & Dining',
    'Shopping',
    'Transportation',
    'Bills & Utilities',
    'Healthcare',
    'Entertainment',
    'Education',
    'Travel',
    'Personal Care',
    'Groceries',
    'Rent',
    'Other',
  ];

  static const List<String> incomeCategories = [
    'Salary',
    'Freelance',
    'Investment',
    'Business',
    'Gift',
    'Other',
  ];
}
