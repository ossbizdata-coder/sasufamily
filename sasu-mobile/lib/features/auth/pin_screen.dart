import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/services/pin_service.dart';
import '../../core/theme/app_theme.dart';

/// PIN Entry Screen
///
/// Used for:
/// - Unlocking the app
/// - Setting up a new PIN
/// - Changing PIN
enum PinMode { unlock, setup, change }

class PinScreen extends StatefulWidget {
  final PinMode mode;
  final VoidCallback? onSuccess;
  final String? title;

  const PinScreen({
    Key? key,
    this.mode = PinMode.unlock,
    this.onSuccess,
    this.title,
  }) : super(key: key);

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> with SingleTickerProviderStateMixin {
  String _enteredPin = '';
  String _confirmPin = '';
  String _oldPin = '';
  bool _isConfirming = false;
  bool _isVerifyingOld = false;
  String? _errorMessage;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController);

    // For change mode, first verify old PIN
    if (widget.mode == PinMode.change) {
      _isVerifyingOld = true;
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  String get _title {
    if (widget.title != null) return widget.title!;

    switch (widget.mode) {
      case PinMode.unlock:
        return 'Enter PIN';
      case PinMode.setup:
        return _isConfirming ? 'Confirm PIN' : 'Set Up PIN';
      case PinMode.change:
        if (_isVerifyingOld) return 'Enter Current PIN';
        return _isConfirming ? 'Confirm New PIN' : 'Enter New PIN';
    }
  }

  String get _subtitle {
    switch (widget.mode) {
      case PinMode.unlock:
        return 'Enter your PIN to unlock';
      case PinMode.setup:
        return _isConfirming
            ? 'Re-enter your PIN to confirm'
            : 'Create a 4-digit PIN';
      case PinMode.change:
        if (_isVerifyingOld) return 'Verify your current PIN';
        return _isConfirming
            ? 'Re-enter new PIN to confirm'
            : 'Enter your new PIN';
    }
  }

  void _onNumberTap(String number) {
    if (_enteredPin.length >= 4) return;

    HapticFeedback.lightImpact();
    setState(() {
      _enteredPin += number;
      _errorMessage = null;
    });

    // Auto-submit when PIN reaches 4 digits
    if (_enteredPin.length == 4) {
      _checkAutoSubmit();
    }
  }

  void _onBackspace() {
    if (_enteredPin.isEmpty) return;

    HapticFeedback.lightImpact();
    setState(() {
      _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
      _errorMessage = null;
    });
  }

  void _checkAutoSubmit() {
    // Auto-verify when 4 digits entered
    if (_enteredPin.length == 4) {
      if (widget.mode == PinMode.unlock) {
        _verifyPin();
      } else {
        _submitPin();
      }
    }
  }

  Future<void> _verifyPin() async {
    final isValid = await PinService.verifyPin(_enteredPin);

    if (isValid) {
      widget.onSuccess?.call();
    } else {
      _showError('Incorrect PIN');
    }
  }

  Future<void> _submitPin() async {
    if (_enteredPin.length != 4) {
      _showError('PIN must be 4 digits');
      return;
    }

    switch (widget.mode) {
      case PinMode.unlock:
        await _verifyPin();
        break;

      case PinMode.setup:
        if (!_isConfirming) {
          // First entry, ask for confirmation
          setState(() {
            _confirmPin = _enteredPin;
            _enteredPin = '';
            _isConfirming = true;
          });
        } else {
          // Confirming
          if (_enteredPin == _confirmPin) {
            final success = await PinService.setPin(_enteredPin);
            if (success) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PIN set successfully')),
                );
              }
              widget.onSuccess?.call();
            } else {
              _showError('Failed to set PIN');
            }
          } else {
            _showError('PINs do not match');
            setState(() {
              _enteredPin = '';
              _confirmPin = '';
              _isConfirming = false;
            });
          }
        }
        break;

      case PinMode.change:
        if (_isVerifyingOld) {
          // Verify old PIN first
          final isValid = await PinService.verifyPin(_enteredPin);
          if (isValid) {
            setState(() {
              _oldPin = _enteredPin;
              _enteredPin = '';
              _isVerifyingOld = false;
            });
          } else {
            _showError('Incorrect current PIN');
          }
        } else if (!_isConfirming) {
          // First entry of new PIN
          setState(() {
            _confirmPin = _enteredPin;
            _enteredPin = '';
            _isConfirming = true;
          });
        } else {
          // Confirming new PIN
          if (_enteredPin == _confirmPin) {
            final success = await PinService.changePin(_oldPin, _enteredPin);
            if (success) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PIN changed successfully')),
                );
              }
              widget.onSuccess?.call();
            } else {
              _showError('Failed to change PIN');
            }
          } else {
            _showError('PINs do not match');
            setState(() {
              _enteredPin = '';
              _confirmPin = '';
              _isConfirming = false;
            });
          }
        }
        break;
    }
  }

  void _showError(String message) {
    setState(() {
      _errorMessage = message;
      _enteredPin = '';
    });
    _shakeController.forward().then((_) => _shakeController.reset());
    HapticFeedback.heavyImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBlue,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const SizedBox(height: 16),

                      const Spacer(flex: 1),

                      // Lock icon
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(20),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lock_outline,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Title
                      Text(
                        _title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Subtitle
                      Text(
                        _subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withAlpha(180),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // PIN dots
                      AnimatedBuilder(
                        animation: _shakeAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(_shakeAnimation.value, 0),
                            child: child,
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(4, (index) {
                            final isFilled = index < _enteredPin.length;
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isFilled ? Colors.white : Colors.transparent,
                                border: Border.all(
                                  color: Colors.white.withAlpha(isFilled ? 255 : 100),
                                  width: 2,
                                ),
                              ),
                            );
                          }),
                        ),
                      ),

                      // Error message
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 20,
                        child: _errorMessage != null
                            ? Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 14,
                                ),
                              )
                            : null,
                      ),

                      const Spacer(flex: 1),

                      // Number pad
                      _buildNumberPad(),

                      const SizedBox(height: 12),


                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNumberPad() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNumberButton('1'),
              _buildNumberButton('2'),
              _buildNumberButton('3'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNumberButton('4'),
              _buildNumberButton('5'),
              _buildNumberButton('6'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNumberButton('7'),
              _buildNumberButton('8'),
              _buildNumberButton('9'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Empty space or biometric button
              const SizedBox(width: 60, height: 60),
              _buildNumberButton('0'),
              _buildBackspaceButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNumberButton(String number) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onNumberTap(number),
        borderRadius: BorderRadius.circular(30),
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withAlpha(50),
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
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
        borderRadius: BorderRadius.circular(30),
        child: Container(
          width: 60,
          height: 60,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(
              Icons.backspace_outlined,
              size: 24,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

