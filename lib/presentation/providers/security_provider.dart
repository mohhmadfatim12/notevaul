import 'package:flutter/material.dart';
import 'package:notevault/services/security_service.dart';

class SecurityProvider extends ChangeNotifier {
  final SecurityService _securityService;

  SecurityProvider(this._securityService);

  bool get isLocked => _securityService.isLocked;
  bool get isPinConfigured =>
      _securityService.preferenceService.isPinLockEnabled();
  bool get isBiometricsAvailable =>
      _securityService.preferenceService.isBiometricEnabled();

  void lock() {
    _securityService.lockApp();
    notifyListeners();
  }

  void unlock() {
    _securityService.unlockApp();
    notifyListeners();
  }

  bool verifyPin(String pin) {
    final valid = _securityService.verifyPin(pin);
    if (valid) {
      _securityService.unlockApp();
      notifyListeners();
    }
    return valid;
  }

  Future<bool> unlockWithBiometrics() async {
    final success = await _securityService.authenticateWithBiometrics();
    if (success) {
      _securityService.unlockApp();
      notifyListeners();
    }
    return success;
  }

  Future<void> setPin(String pin) async {
    await _securityService.savePin(pin);
    notifyListeners();
  }

  Future<void> removePin() async {
    await _securityService.disablePinLock();
    notifyListeners();
  }

  void onAppPaused() {
    _securityService.onAppPaused();
  }

  void onAppResumed() {
    _securityService.onAppResumed();
    notifyListeners();
  }
}
