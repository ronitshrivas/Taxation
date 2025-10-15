// lib/core/utils/validators.dart
import 'package:flutter/material.dart';

/// Utility class for form validation
class Validators {
  Validators._(); // Private constructor

  /// Validate email address
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email address';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validate password (minimum 8 characters, one uppercase, one lowercase, one number)
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    if (!RegExp(r'(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
      return 'Password must contain uppercase, lowercase, and number';
    }
    return null;
  }

  /// Validate name (minimum 2 characters, letters only)
  static String? validateName(String? value, {String fieldName = 'Name'}) {
    if (value == null || value.isEmpty) {
      return 'Please enter your $fieldName';
    }
    if (value.length < 2) {
      return '$fieldName must be at least 2 characters long';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return '$fieldName should only contain letters';
    }
    return null;
  }

  /// Validate phone number (Nepal format: 10 digits, starting with 98)
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }
    if (!RegExp(r'^98[0-9]{8}$').hasMatch(value)) {
      return 'Please enter a valid Nepal phone number (e.g., 9841234567)';
    }
    return null;
  }

  /// Validate PAN number (9 digits)
  static String? validatePAN(String? value) {
    if (value == null || value.isEmpty) {
      return null; // PAN is optional
    }
    if (!RegExp(r'^\d{9}$').hasMatch(value)) {
      return 'Please enter a valid 9-digit PAN number';
    }
    return null;
  }

  /// Validate amount (positive number)
  static String? validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an amount';
    }
    final numValue = double.tryParse(value.replaceAll(',', ''));
    if (numValue == null || numValue <= 0) {
      return 'Please enter a valid positive amount';
    }
    return null;
  }

  /// Validate confirm password matches password
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Validate required field
  static String? validateRequired(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $fieldName';
    }
    return null;
  }

  /// Validate description (optional, max 500 chars)
  static String? validateDescription(String? value) {
    if (value != null && value.length > 500) {
      return 'Description must not exceed 500 characters';
    }
    return null;
  }
}