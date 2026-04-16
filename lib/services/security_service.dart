import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:local_auth/local_auth.dart';
import 'preference_service.dart';

class SecurityService {
  final PreferenceService preferenceService;
  final LocalAuthentication _localAuth;

  bool _isCurrentlyLocked = false;
  DateTime? _backgroundTimestamp;

  SecurityService(
    this.preferenceService, {
    LocalAuthentication? localAuth,
  }) : _localAuth = localAuth ?? LocalAuthentication() {
    _isCurrentlyLocked = preferenceService.isPinLockEnabled();
  }

  bool get isLocked => _isCurrentlyLocked;

  void lockApp() {
    if (preferenceService.isPinLockEnabled()) {
      _isCurrentlyLocked = true;
    }
  }

  void unlockApp() {
    _isCurrentlyLocked = false;
    _backgroundTimestamp = null;
  }

  /// Hashes a plain-text PIN using SHA-256 for secure local storage.
  static String hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Verifies entered PIN against stored SHA-256 hash.
  bool verifyPin(String enteredPin) {
    final storedHash = preferenceService.getHashedPin();
    if (storedHash == null) return true;
    return hashPin(enteredPin) == storedHash;
  }

  /// Saves a new PIN (hashes it automatically).
  Future<void> savePin(String pin) async {
    final hash = hashPin(pin);
    await preferenceService.setHashedPin(hash);
    await preferenceService.setPinLockEnabled(true);
    _isCurrentlyLocked = false;
  }

  /// Disables PIN lock and cleans up stored hash.
  Future<void> disablePinLock() async {
    await preferenceService.setHashedPin(null);
    await preferenceService.setPinLockEnabled(false);
    await preferenceService.setBiometricEnabled(false);
    _isCurrentlyLocked = false;
  }

  /// Checks if hardware biometrics are supported on device.
  Future<bool> isBiometricsAvailable() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();
      return canCheck && isSupported;
    } catch (_) {
      return false;
    }
  }

  /// Authenticates user with biometric sensor (fingerprint/face).
  Future<bool> authenticateWithBiometrics() async {
    try {
      if (!await isBiometricsAvailable()) return false;
      return await _localAuth.authenticate(
        localizedReason: 'Scan your biometric credential to unlock NoteVault',
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
    } catch (_) {
      return false;
    }
  }

  /// Tracks app lifecycle entering background.
  void onAppPaused() {
    if (preferenceService.isPinLockEnabled()) {
      _backgroundTimestamp = DateTime.now();
    }
  }

  /// Tracks app lifecycle returning to foreground and enforces lock timeout.
  void onAppResumed() {
    if (!preferenceService.isPinLockEnabled()) {
      _isCurrentlyLocked = false;
      return;
    }

    if (_backgroundTimestamp == null) {
      _isCurrentlyLocked = true;
      return;
    }

    final timeoutMinutes = preferenceService.getAutoLockTimeoutMinutes();
    if (timeoutMinutes == 0) {
      _isCurrentlyLocked = true;
    } else {
      final elapsed = DateTime.now().difference(_backgroundTimestamp!);
      if (elapsed.inMinutes >= timeoutMinutes) {
        _isCurrentlyLocked = true;
      }
    }
  }
}
