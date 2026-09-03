class ValidationHelper {
  // BASIC CHECKS

  static String? validateStringLength({
    required String? value,
    required int minLength,
    required int maxLength,
    required String attributeName,
    required bool nullsAllowed,
  }) {
    // Null / empty check
    if (!nullsAllowed &&
        (value == null || value.isEmpty || value.trim().isEmpty)) {
      return '$attributeName cannot be empty!';
    }

    // Null is allowed
    if (nullsAllowed && value == null) {
      return null;
    }

    final trimmedValue = value!.trim();

    if (trimmedValue.length < minLength || trimmedValue.length > maxLength) {
      return '$attributeName cannot be less than $minLength characters '
          'or exceed $maxLength characters!';
    }

    return null;
  }

  static String? validateAmount({
    required int? amount,
    required int minValue,
    required int maxValue,
    required String attributeName,
    required bool nullsAllowed,
  }) {
    if (!nullsAllowed && amount == null) {
      return '$attributeName cannot be empty!';
    }

    if (nullsAllowed && amount == null) {
      return null;
    }

    if (amount! < minValue || amount > maxValue) {
      return '$attributeName amount must be between '
          '$minValue and $maxValue!';
    }

    return null;
  }

  static String? validateDate({
    required DateTime? dateToCheck,
    required DateTime minDate,
    required DateTime maxDate,
    required String attributeName,
    required bool nullsAllowed,
  }) {
    if (!nullsAllowed && dateToCheck == null) {
      return '$attributeName cannot be empty!';
    }

    if (nullsAllowed && dateToCheck == null) {
      return null;
    }

    if (dateToCheck!.isBefore(minDate) || dateToCheck.isAfter(maxDate)) {
      return 'Date cannot be before ${_formatDate(minDate)} '
          'or after ${_formatDate(maxDate)}';
    }

    return null;
  }

  static String? validatePrice({
    required double? price,
    required String attributeName,
    required bool nullsAllowed,
  }) {
    if (!nullsAllowed && price == null) {
      return '$attributeName cannot be empty!';
    }

    if (nullsAllowed && price == null) {
      return null;
    }

    if (price! <= 0) {
      return '$attributeName must not be less than 0!';
    }

    return null;
  }

  // REGEX CHECKS

  static String? validatePhoneRegex({
    required String? value,
    required int minLength,
    required int maxLength,
    required String attributeName,
    required bool nullsAllowed,
  }) {
    final lengthError = validateStringLength(
      value: value,
      minLength: minLength,
      maxLength: maxLength,
      attributeName: attributeName,
      nullsAllowed: nullsAllowed,
    );

    if (lengthError != null) {
      return lengthError;
    }

    final trimmedValue = value!.trim();

    final phoneRegex = RegExp(r'^\+?[0-9\s\-\(\)]{6,20}$');

    if (!phoneRegex.hasMatch(trimmedValue)) {
      return '$attributeName is not a valid phone number pattern!';
    }

    return null;
  }

  static String? validatePasswordRegex({
    required String? value,
    required int minLength,
    required int maxLength,
    required String attributeName,
    required bool nullsAllowed,
  }) {
    final lengthError = validateStringLength(
      value: value,
      minLength: minLength,
      maxLength: maxLength,
      attributeName: attributeName,
      nullsAllowed: nullsAllowed,
    );

    if (lengthError != null) {
      return lengthError;
    }

    final passwordRegex = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{8,}$',
    );

    if (!passwordRegex.hasMatch(value!.trim())) {
      return '$attributeName must contain at least '
          '8 characters, one uppercase letter, one lowercase letter, '
          'one number, and one special character!';
    }

    return null;
  }

  static String? validatePasswordMatch({
    required String? password,
    required String? repeatedPassword,
  }) {
    if (password != repeatedPassword) {
      return 'Passwords do not match';
    }

    return null;
  }

  static String? validateEmailRegex({
    required String? value,
    required String attributeName,
    required bool nullsAllowed,
  }) {
    if (nullsAllowed && value == null) {
      return null;
    }

    if (!nullsAllowed &&
        (value == null || value.isEmpty || value.trim().isEmpty)) {
      return '$attributeName cannot be null!';
    }

    final trimmedValue = value!.trim();

    final emailRegex = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
      caseSensitive: false,
    );

    if (!emailRegex.hasMatch(trimmedValue)) {
      return '$attributeName is not a valid email address pattern!';
    }

    return null;
  }

  // HELPERS

  static String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day.$month.$year';
  }
}
