import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:notevault/core/constants/app_colors.dart';
import 'package:notevault/core/constants/app_dimensions.dart';
import 'package:notevault/presentation/providers/security_provider.dart';

class PinUnlockScreen extends StatefulWidget {
  final VoidCallback onSuccess;

  const PinUnlockScreen({super.key, required this.onSuccess});

  @override
  State<PinUnlockScreen> createState() => _PinUnlockScreenState();
}

class _PinUnlockScreenState extends State<PinUnlockScreen>
    with SingleTickerProviderStateMixin {
  String _enteredPin = '';
  String? _errorMessage;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 12)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController);

    // Automatically try biometrics if enabled
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tryBiometrics();
    });
  }

  Future<void> _tryBiometrics() async {
    final securityProvider = Provider.of<SecurityProvider>(context, listen: false);
    if (securityProvider.isBiometricsAvailable) {
      final success = await securityProvider.unlockWithBiometrics();
      if (success && mounted) {
        widget.onSuccess();
      }
    }
  }

  void _onKeyPress(String digit) {
    if (_enteredPin.length >= 6) return;
    HapticFeedback.lightImpact();

    setState(() {
      _enteredPin += digit;
      _errorMessage = null;
    });

    if (_enteredPin.length >= 4) {
      _verify();
    }
  }

  void _onBackspace() {
    if (_enteredPin.isEmpty) return;
    HapticFeedback.selectionClick();
    setState(() {
      _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
      _errorMessage = null;
    });
  }

  void _verify() {
    final securityProvider = Provider.of<SecurityProvider>(context, listen: false);
    final valid = securityProvider.verifyPin(_enteredPin);
    if (valid) {
      HapticFeedback.mediumImpact();
      widget.onSuccess();
    } else {
      if (_enteredPin.length == 4 || _enteredPin.length == 6) {
        HapticFeedback.heavyImpact();
        _shakeController.forward(from: 0);
        setState(() {
          _errorMessage = 'Incorrect PIN. Please try again.';
          _enteredPin = '';
        });
      }
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_outline_rounded,
                size: 36,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: AppDimensions.p20),
            Text(
              'Enter PIN',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppDimensions.p8),
            Text(
              'NoteVault is locked to protect your data',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: AppDimensions.p32),

            // Animated PIN Dots
            AnimatedBuilder(
              animation: _shakeAnimation,
              builder: (ctx, child) {
                return Transform.translate(
                  offset: Offset(_shakeAnimation.value * (_shakeAnimation.status == AnimationStatus.forward ? 1 : -1), 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (index) {
                      final isFilled = index < _enteredPin.length;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isFilled
                              ? theme.colorScheme.primary
                              : Colors.transparent,
                          border: Border.all(
                            color: isFilled
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outlineVariant,
                            width: 2,
                          ),
                        ),
                      );
                    }),
                  ),
                );
              },
            ),

            if (_errorMessage != null) ...[
              const SizedBox(height: AppDimensions.p16),
              Text(
                _errorMessage!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],

            const Spacer(),

            // Keypad
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.p32),
              child: Column(
                children: [
                  _buildKeypadRow(['1', '2', '3']),
                  const SizedBox(height: AppDimensions.p16),
                  _buildKeypadRow(['4', '5', '6']),
                  const SizedBox(height: AppDimensions.p16),
                  _buildKeypadRow(['7', '8', '9']),
                  const SizedBox(height: AppDimensions.p16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildBiometricButton(),
                      _buildKeypadButton('0'),
                      _buildBackspaceButton(),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.p32),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypadRow(List<String> digits) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: digits.map(_buildKeypadButton).toList(),
    );
  }

  Widget _buildKeypadButton(String digit) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onKeyPress(digit),
        borderRadius: BorderRadius.circular(AppDimensions.rCircle),
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            border: Border.all(
              color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            digit,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _onBackspace,
        borderRadius: BorderRadius.circular(AppDimensions.rCircle),
        child: const SizedBox(
          width: 72,
          height: 72,
          child: Icon(Icons.backspace_outlined, size: 24),
        ),
      ),
    );
  }

  Widget _buildBiometricButton() {
    final security = Provider.of<SecurityProvider>(context, listen: false);
    if (!security.isBiometricsAvailable) {
      return const SizedBox(width: 72, height: 72);
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _tryBiometrics,
        borderRadius: BorderRadius.circular(AppDimensions.rCircle),
        child: Container(
          width: 72,
          height: 72,
          alignment: Alignment.center,
          child: Icon(
            Icons.fingerprint_rounded,
            size: 32,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
