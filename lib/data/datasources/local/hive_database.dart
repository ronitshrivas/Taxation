import 'package:hive_flutter/hive_flutter.dart';
import '../../models/user_model.dart';
import '../../models/income_model.dart';
import '../../models/expense_model.dart';

/// Central Hive database manager
class HiveDatabase {
  static final HiveDatabase _instance = HiveDatabase._internal();
  factory HiveDatabase() => _instance;
  HiveDatabase._internal();

  // Box names
  static const String userBox = 'users';
  static const String incomeBox = 'incomes';
  static const String expenseBox = 'expenses';
  static const String settingsBox = 'settings';
  static const String cacheBox = 'cache';
  static const String receiptBox = 'receipts';

  // Box references
  Box<User>? _userBox;
  Box<Income>? _incomeBox;
  Box<Expense>? _expenseBox;
  Box? _settingsBox;
  Box? _cacheBox;

  /// Initialize Hive and open all boxes
  Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(IncomeAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(ExpenseAdapter());
    }

    // Open boxes
    await openBoxes();
  }

  /// Open all boxes
  Future<void> openBoxes() async {
    _userBox = await Hive.openBox<User>(userBox);
    _incomeBox = await Hive.openBox<Income>(incomeBox);
    _expenseBox = await Hive.openBox<Expense>(expenseBox);
    _settingsBox = await Hive.openBox(settingsBox);
    _cacheBox = await Hive.openBox(cacheBox);
  }

  /// Close all boxes
  Future<void> closeBoxes() async {
    await _userBox?.close();
    await _incomeBox?.close();
    await _expenseBox?.close();
    await _settingsBox?.close();
    await _cacheBox?.close();
  }

  /// Clear all data (for logout or reset)
  Future<void> clearAllData() async {
    await _userBox?.clear();
    await _incomeBox?.clear();
    await _expenseBox?.clear();
    await _settingsBox?.clear();
    await _cacheBox?.clear();
  }

  /// Delete all boxes (complete reset)
  Future<void> deleteAllBoxes() async {
    await Hive.deleteBoxFromDisk(userBox);
    await Hive.deleteBoxFromDisk(incomeBox);
    await Hive.deleteBoxFromDisk(expenseBox);
    await Hive.deleteBoxFromDisk(settingsBox);
    await Hive.deleteBoxFromDisk(cacheBox);
  }

  // Getters for boxes
  Box<User> get users => _userBox!;
  Box<Income> get incomes => _incomeBox!;
  Box<Expense> get expenses => _expenseBox!;
  Box get settings => _settingsBox!;
  Box get cache => _cacheBox!;

  /// Check if boxes are open
  bool get isInitialized => 
      _userBox != null && 
      _incomeBox != null && 
      _expenseBox != null &&
      _settingsBox != null &&
      _cacheBox != null;

  /// Get database size in bytes
  Future<int> getDatabaseSize() async {
    int totalSize = 0;
    
    if (_userBox != null) {
      totalSize += await _getBoxSize(_userBox!);
    }
    if (_incomeBox != null) {
      totalSize += await _getBoxSize(_incomeBox!);
    }
    if (_expenseBox != null) {
      totalSize += await _getBoxSize(_expenseBox!);
    }
    
    return totalSize;
  }

  /// Get box size
  Future<int> _getBoxSize(Box box) async {
    try {
      // Approximate size based on entry count
      return box.length * 1024; // Rough estimate
    } catch (e) {
      return 0;
    }
  }

  /// Compact all boxes (reduce file size)
  Future<void> compactAllBoxes() async {
    await _userBox?.compact();
    await _incomeBox?.compact();
    await _expenseBox?.compact();
    await _settingsBox?.compact();
    await _cacheBox?.compact();
  }

  /// Export all data to JSON
  Map<String, dynamic> exportAllData() {
    return {
      'users': _userBox?.values.map((e) => e.toJson()).toList() ?? [],
      'incomes': _incomeBox?.values.map((e) => e.toJson()).toList() ?? [],
      'expenses': _expenseBox?.values.map((e) => e.toJson()).toList() ?? [],
      'settings': _settingsBox?.toMap() ?? {},
      'exportDate': DateTime.now().toIso8601String(),
      'version': '1.0.0',
    };
  }

  /// Import data from JSON
  Future<void> importData(Map<String, dynamic> data) async {
    // Clear existing data
    await clearAllData();

    // Import users
    if (data['users'] != null) {
      for (var userData in data['users']) {
        final user = User.fromJson(userData);
        await _userBox?.add(user);
      }
    }

    // Import incomes
    if (data['incomes'] != null) {
      for (var incomeData in data['incomes']) {
        final income = Income.fromJson(incomeData);
        await _incomeBox?.add(income);
      }
    }

    // Import expenses
    if (data['expenses'] != null) {
      for (var expenseData in data['expenses']) {
        final expense = Expense.fromJson(expenseData);
        await _expenseBox?.add(expense);
      }
    }

    // Import settings
    if (data['settings'] != null) {
      await _settingsBox?.putAll(Map<String, dynamic>.from(data['settings']));
    }
  }

  /// Get statistics
  Map<String, int> getStatistics() {
    return {
      'users': _userBox?.length ?? 0,
      'incomes': _incomeBox?.length ?? 0,
      'expenses': _expenseBox?.length ?? 0,
      'settings': _settingsBox?.length ?? 0,
    };
  }
}