import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

/// Notification service for managing all app notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// Initialize notification service
  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone
    tz.initializeTimeZones();

    // Android initialization settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions
    await _requestPermissions();

    _initialized = true;
  }

  /// Request notification permissions
  Future<bool> _requestPermissions() async {
    final androidImplementation = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    final granted = await androidImplementation?.requestNotificationsPermission();
    return granted ?? false;
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap based on payload
    final payload = response.payload;
    if (payload != null) {
      // Navigate to appropriate screen based on payload
      // TODO: Implement navigation
    }
  }

  // ============================================================================
  // INSTANT NOTIFICATIONS
  // ============================================================================

  /// Show instant notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'taxsathi_channel',
      'TaxSathi Notifications',
      channelDescription: 'General notifications from TaxSathi',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(id, title, body, details, payload: payload);
  }

  /// Show success notification
  Future<void> showSuccess(String message) async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: '✅ Success',
      body: message,
    );
  }

  /// Show error notification
  Future<void> showError(String message) async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: '❌ Error',
      body: message,
    );
  }

  /// Show warning notification
  Future<void> showWarning(String message) async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: '⚠️ Warning',
      body: message,
    );
  }

  // ============================================================================
  // SCHEDULED NOTIFICATIONS
  // ============================================================================

  /// Schedule notification
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'taxsathi_reminders',
      'Tax Reminders',
      channelDescription: 'Scheduled reminders for tax deadlines',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  /// Schedule daily notification
  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'taxsathi_daily',
      'Daily Reminders',
      channelDescription: 'Daily expense tracking reminders',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfTime(hour, minute),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  // ============================================================================
  // TAX-SPECIFIC NOTIFICATIONS
  // ============================================================================

  /// Schedule tax deadline reminder
  Future<void> scheduleTaxDeadlineReminder({
    required String deadlineName,
    required DateTime deadline,
    int daysBeforeDeadline = 7,
  }) async {
    final reminderDate = deadline.subtract(Duration(days: daysBeforeDeadline));

    await scheduleNotification(
      id: deadline.hashCode,
      title: '📅 Tax Deadline Approaching',
      body: '$deadlineName is due on ${deadline.day}/${deadline.month}/${deadline.year}',
      scheduledTime: reminderDate,
      payload: 'tax_deadline',
    );
  }

  /// Schedule monthly expense tracking reminder
  Future<void> scheduleMonthlyExpenseReminder() async {
    await scheduleDailyNotification(
      id: 1001,
      title: '💰 Track Your Expenses',
      body: 'Don\'t forget to log today\'s expenses!',
      hour: 20,
      minute: 0, // 8 PM
    );
  }

  /// Schedule receipt scanning reminder
  Future<void> scheduleReceiptReminder() async {
    await scheduleDailyNotification(
      id: 1002,
      title: '📸 Scan Your Receipts',
      body: 'Keep your receipts organized for tax deductions',
      hour: 21,
      minute: 0, // 9 PM
    );
  }

  /// Schedule weekly summary notification
  Future<void> scheduleWeeklySummary() async {
    final now = DateTime.now();
    final nextSunday = now.add(Duration(days: (7 - now.weekday) % 7));
    final scheduledTime = DateTime(
      nextSunday.year,
      nextSunday.month,
      nextSunday.day,
      18, // 6 PM
      0,
    );

    await scheduleNotification(
      id: 1003,
      title: '📊 Weekly Financial Summary',
      body: 'Check your income and expense summary for this week',
      scheduledTime: scheduledTime,
      payload: 'weekly_summary',
    );
  }

  /// Schedule missing receipt alert
  Future<void> scheduleMissingReceiptAlert(int count) async {
    if (count > 0) {
      await showNotification(
        id: 2001,
        title: '⚠️ Missing Receipts',
        body: 'You have $count expenses without receipts. Add them for tax deductions!',
        payload: 'missing_receipts',
      );
    }
  }

  /// Schedule large expense alert
  Future<void> scheduleLargeExpenseAlert(double amount) async {
    await showNotification(
      id: 2002,
      title: '💸 Large Expense Detected',
      body: 'NPR ${amount.toStringAsFixed(0)} expense recorded. Make sure to keep the receipt!',
      payload: 'large_expense',
    );
  }

  /// Schedule tax optimization suggestion
  Future<void> scheduleOptimizationSuggestion(double potentialSavings) async {
    await showNotification(
      id: 2003,
      title: '💡 Tax Optimization Opportunity',
      body: 'You could save NPR ${potentialSavings.toStringAsFixed(0)} with smart deductions!',
      payload: 'optimization',
    );
  }

  /// Schedule approaching tax bracket warning
  Future<void> scheduleApproachingBracketWarning(
    double currentIncome,
    double nextBracket,
    double remainingAmount,
  ) async {
    await showNotification(
      id: 2004,
      title: '📈 Tax Bracket Alert',
      body: 'You\'re NPR ${remainingAmount.toStringAsFixed(0)} away from the next tax bracket!',
      payload: 'tax_bracket',
    );
  }

  // ============================================================================
  // NEPAL-SPECIFIC TAX DEADLINES
  // ============================================================================

  /// Schedule all Nepal tax deadlines
  Future<void> scheduleNepalTaxDeadlines() async {
    final now = DateTime.now();
    final currentYear = now.year;

    // Annual Income Tax (Magh end - approximately Feb 13-14)
    final annualTaxDeadline = DateTime(currentYear, 2, 13);
    if (annualTaxDeadline.isAfter(now)) {
      await scheduleTaxDeadlineReminder(
        deadlineName: 'Annual Income Tax Filing',
        deadline: annualTaxDeadline,
        daysBeforeDeadline: 30,
      );
      await scheduleTaxDeadlineReminder(
        deadlineName: 'Annual Income Tax Filing',
        deadline: annualTaxDeadline,
        daysBeforeDeadline: 7,
      );
    }

    // Monthly TDS deadlines (25th of every month)
    for (int month = now.month; month <= 12; month++) {
      final tdsDeadline = DateTime(currentYear, month, 25);
      if (tdsDeadline.isAfter(now)) {
        await scheduleTaxDeadlineReminder(
          deadlineName: 'Monthly TDS Payment',
          deadline: tdsDeadline,
          daysBeforeDeadline: 3,
        );
      }
    }

    // Quarterly VAT deadlines
    final vatDeadlines = [
      DateTime(currentYear, 11, 25), // Q1 - Kartik 25
      DateTime(currentYear + 1, 2, 25), // Q2 - Magh 25
      DateTime(currentYear + 1, 6, 25), // Q3 - Ashadh 25
    ];

    for (final deadline in vatDeadlines) {
      if (deadline.isAfter(now)) {
        await scheduleTaxDeadlineReminder(
          deadlineName: 'Quarterly VAT Filing',
          deadline: deadline,
          daysBeforeDeadline: 7,
        );
      }
    }
  }

  // ============================================================================
  // NOTIFICATION MANAGEMENT
  // ============================================================================

  /// Cancel specific notification
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  /// Get active notifications
  Future<List<ActiveNotification>> getActiveNotifications() async {
    final androidImplementation = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    return await androidImplementation?.getActiveNotifications() ?? [];
  }

  // ============================================================================
  // NOTIFICATION CHANNELS (Android)
  // ============================================================================

  /// Create notification channels
  Future<void> createNotificationChannels() async {
    final androidImplementation = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation == null) return;

    // General notifications channel
    const generalChannel = AndroidNotificationChannel(
      'taxsathi_channel',
      'TaxSathi Notifications',
      description: 'General notifications from TaxSathi',
      importance: Importance.high,
    );

    // Tax reminders channel
    const remindersChannel = AndroidNotificationChannel(
      'taxsathi_reminders',
      'Tax Reminders',
      description: 'Scheduled reminders for tax deadlines',
      importance: Importance.high,
    );

    // Daily reminders channel
    const dailyChannel = AndroidNotificationChannel(
      'taxsathi_daily',
      'Daily Reminders',
      description: 'Daily expense tracking reminders',
      importance: Importance.defaultImportance,
    );

    // Create channels
    await androidImplementation.createNotificationChannel(generalChannel);
    await androidImplementation.createNotificationChannel(remindersChannel);
    await androidImplementation.createNotificationChannel(dailyChannel);
  }
}

/// Notification types enum
enum NotificationType {
  taxDeadline,
  expenseReminder,
  receiptReminder,
  weeklySummary,
  missingReceipt,
  largeExpense,
  optimization,
  taxBracket,
}

/// Notification helper class
class NotificationHelper {
  /// Setup all default notifications
  static Future<void> setupDefaultNotifications() async {
    final service = NotificationService();
    await service.initialize();
    await service.createNotificationChannels();
    
    // Schedule recurring reminders
    await service.scheduleMonthlyExpenseReminder();
    await service.scheduleWeeklySummary();
    
    // Schedule tax deadlines
    await service.scheduleNepalTaxDeadlines();
  }

  /// Test notification
  static Future<void> sendTestNotification() async {
    final service = NotificationService();
    await service.showNotification(
      id: 9999,
      title: '🧪 Test Notification',
      body: 'TaxSathi notifications are working perfectly!',
    );
  }

  /// Check if notifications are enabled
  static Future<bool> areNotificationsEnabled() async {
    final service = NotificationService();
    final pending = await service.getPendingNotifications();
    return pending.isNotEmpty;
  }

  /// Get notification statistics
  static Future<Map<String, int>> getNotificationStats() async {
    final service = NotificationService();
    final pending = await service.getPendingNotifications();
    final active = await service.getActiveNotifications();

    return {
      'pending': pending.length,
      'active': active.length,
      'total': pending.length + active.length,
    };
  }
}