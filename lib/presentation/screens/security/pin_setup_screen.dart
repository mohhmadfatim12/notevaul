import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:notevault/core/constants/app_colors.dart';
import 'package:notevault/core/constants/app_dimensions.dart';
import 'package:notevault/presentation/providers/security_provider.dart';

class PinSetupScreen extends StatefulWidget {
  final bool isChangingPin;

  const PinSetupScreen({super.key, this.isChangingPin = false});

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  String _pin = '';
  String _firstPin = '';
  bool _isConfirming = false;
  String? _errorMessage;

  void _onKeyPress(String digit) {
    if (_pin.length >= 4) return;
    HapticFeedback.lightImpact();

    setState(() {
      _pin += digit;
      _errorMessage = null;
    });

    if (_pin.length == 4) {
      _handleStepCompletion();
    }
  }

  void _onBackspace() {
    if (_pin.isEmpty) return;
    HapticFeedback.selectionClick();
    setState(() {
      _pin = _pin.substring(0, _pin.length - 1);
      _errorMessage = null;
    });
  }

  Future<void> _handleStepCompletion() async {
    if (!_isConfirming) {
      setState(() {
        _firstPin = _pin;
        _pin = '';
        _isConfirming = true;
      });
    } else {
      if (_pin == _firstPin) {
        final security = Provider.of<SecurityProvider>(context, listen: false);
        await security.setPin(_pin);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.isChangingPin
                  ? 'PIN successfully changed.'
                  : 'PIN lock enabled successfully.'),
            ),
          );
          Navigator.of(context).pop(true);
        }
      } else {
        HapticFeedback.heavyImpact();
        setState(() {
          _errorMessage = 'PINs do not match. Please try again.';
          _pin = '';
          _firstPin = '';
          _isConfirming = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isChangingPin ? 'Change PIN' : 'Set Up App PIN'),
      ),
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
                _isConfirming ? Icons.check_circle_outline_rounded : Icons.lock_reset_rounded,
                size: 36,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: AppDimensions.p20),
            Text(
              _isConfirming ? 'Confirm your 4-digit PIN' : 'Enter a new 4-digit PIN',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppDimensions.p8),
            Text(
              _isConfirming
                  ? 'Re-enter your PIN to verify'
                  : 'This PIN will be required to open NoteVault',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: AppDimensions.p32),

            // PIN Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                final isFilled = index < _pin.length;
                return Container(
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
                      const SizedBox(width: 72, height: 72),
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
}
