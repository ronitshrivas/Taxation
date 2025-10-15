import 'package:hive/hive.dart';

part 'user_model.g.dart'; // Generated file for Hive

/// User model with Hive annotations for local storage
@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String email;

  @HiveField(2)
  String name;

  @HiveField(3)
  String? phoneNumber;

  @HiveField(4)
  String? panNumber;

  @HiveField(5)
  String? profileImageUrl;

  @HiveField(6)
  bool isMarried;

  @HiveField(7)
  String? address;

  @HiveField(8)
  String? city;

  @HiveField(9)
  String? occupation;

  @HiveField(10)
  String? employerName;

  @HiveField(11)
  DateTime? dateOfBirth;

  @HiveField(12)
  String currentFiscalYear; // 2081/82

  @HiveField(13)
  DateTime createdAt;

  @HiveField(14)
  DateTime updatedAt;

  @HiveField(15)
  bool biometricEnabled;

  @HiveField(16)
  String? preferredLanguage; // 'en' or 'ne'

  @HiveField(17)
  String? preferredDateFormat; // 'BS' or 'AD'

  @HiveField(18)
  bool notificationsEnabled;

  @HiveField(19)
  bool darkModeEnabled;

  @HiveField(20)
  String? remoteAreaCategory; // For remote area allowance

  @HiveField(21)
  double? basicSalary; // Monthly basic salary

  @HiveField(22)
  Map<String, dynamic>? taxSettings; // Custom tax settings

  @HiveField(23)
  Map<String, dynamic>? preferences; // User preferences

  User({
    required this.id,
    required this.email,
    required this.name,
    this.phoneNumber,
    this.panNumber,
    this.profileImageUrl,
    this.isMarried = false,
    this.address,
    this.city,
    this.occupation,
    this.employerName,
    this.dateOfBirth,
    this.currentFiscalYear = '2081/82',
    required this.createdAt,
    required this.updatedAt,
    this.biometricEnabled = false,
    this.preferredLanguage = 'en',
    this.preferredDateFormat = 'AD',
    this.notificationsEnabled = true,
    this.darkModeEnabled = false,
    this.remoteAreaCategory,
    this.basicSalary,
    this.taxSettings,
    this.preferences,
  });

  /// Create a copy with modified fields
  User copyWith({
    String? id,
    String? email,
    String? name,
    String? phoneNumber,
    String? panNumber,
    String? profileImageUrl,
    bool? isMarried,
    String? address,
    String? city,
    String? occupation,
    String? employerName,
    DateTime? dateOfBirth,
    String? currentFiscalYear,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? biometricEnabled,
    String? preferredLanguage,
    String? preferredDateFormat,
    bool? notificationsEnabled,
    bool? darkModeEnabled,
    String? remoteAreaCategory,
    double? basicSalary,
    Map<String, dynamic>? taxSettings,
    Map<String, dynamic>? preferences,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      panNumber: panNumber ?? this.panNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isMarried: isMarried ?? this.isMarried,
      address: address ?? this.address,
      city: city ?? this.city,
      occupation: occupation ?? this.occupation,
      employerName: employerName ?? this.employerName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      currentFiscalYear: currentFiscalYear ?? this.currentFiscalYear,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      preferredDateFormat: preferredDateFormat ?? this.preferredDateFormat,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      remoteAreaCategory: remoteAreaCategory ?? this.remoteAreaCategory,
      basicSalary: basicSalary ?? this.basicSalary,
      taxSettings: taxSettings ?? this.taxSettings,
      preferences: preferences ?? this.preferences,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phoneNumber': phoneNumber,
      'panNumber': panNumber,
      'profileImageUrl': profileImageUrl,
      'isMarried': isMarried,
      'address': address,
      'city': city,
      'occupation': occupation,
      'employerName': employerName,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'currentFiscalYear': currentFiscalYear,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'biometricEnabled': biometricEnabled,
      'preferredLanguage': preferredLanguage,
      'preferredDateFormat': preferredDateFormat,
      'notificationsEnabled': notificationsEnabled,
      'darkModeEnabled': darkModeEnabled,
      'remoteAreaCategory': remoteAreaCategory,
      'basicSalary': basicSalary,
      'taxSettings': taxSettings,
      'preferences': preferences,
    };
  }

  /// Create from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      panNumber: json['panNumber'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
      isMarried: json['isMarried'] as bool? ?? false,
      address: json['address'] as String?,
      city: json['city'] as String?,
      occupation: json['occupation'] as String?,
      employerName: json['employerName'] as String?,
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'] as String)
          : null,
      currentFiscalYear: json['currentFiscalYear'] as String? ?? '2081/82',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      biometricEnabled: json['biometricEnabled'] as bool? ?? false,
      preferredLanguage: json['preferredLanguage'] as String? ?? 'en',
      preferredDateFormat: json['preferredDateFormat'] as String? ?? 'AD',
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      darkModeEnabled: json['darkModeEnabled'] as bool? ?? false,
      remoteAreaCategory: json['remoteAreaCategory'] as String?,
      basicSalary: (json['basicSalary'] as num?)?.toDouble(),
      taxSettings: json['taxSettings'] as Map<String, dynamic>?,
      preferences: json['preferences'] as Map<String, dynamic>?,
    );
  }

  /// Get user's age
  int? get age {
    if (dateOfBirth == null) return null;
    final today = DateTime.now();
    int age = today.year - dateOfBirth!.year;
    if (today.month < dateOfBirth!.month ||
        (today.month == dateOfBirth!.month && today.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  /// Get user initials (for avatar)
  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 2).toUpperCase();
  }

  /// Check if profile is complete
  bool get isProfileComplete {
    return panNumber != null &&
        phoneNumber != null &&
        address != null &&
        occupation != null;
  }

  /// Get profile completion percentage
  int get profileCompletionPercentage {
    int completed = 0;
    const int total = 8;

    if (panNumber != null) completed++;
    if (phoneNumber != null) completed++;
    if (address != null) completed++;
    if (city != null) completed++;
    if (occupation != null) completed++;
    if (employerName != null) completed++;
    if (dateOfBirth != null) completed++;
    if (basicSalary != null) completed++;

    return ((completed / total) * 100).round();
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email)';
  }
}

/// User settings helper
class UserSettings {
  static const String languageEnglish = 'en';
  static const String languageNepali = 'ne';

  static const String dateFormatAD = 'AD';
  static const String dateFormatBS = 'BS';

  static const List<String> languages = [languageEnglish, languageNepali];
  static const List<String> dateFormats = [dateFormatAD, dateFormatBS];

  static String getLanguageName(String code) {
    switch (code) {
      case languageEnglish:
        return 'English';
      case languageNepali:
        return 'नेपाली';
      default:
        return code;
    }
  }

  static String getDateFormatName(String format) {
    switch (format) {
      case dateFormatAD:
        return 'AD (Gregorian)';
      case dateFormatBS:
        return 'BS (Bikram Sambat)';
      default:
        return format;
    }
  }
}