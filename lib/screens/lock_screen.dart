import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

import '../app_state.dart';

/// Screen individual de Pantalla de Bloqueo (Pin Lock / Biometrics) para IDEON.
/// Diseñada con estética Dark Premium / Midnight Black, acentos Electric Blue & Indigo,
/// sin estética bancaria y enfocada en seguridad moderna.
class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  String _pin = '';
  final int _pinLength = 4;
  bool _isError = false;
  final LocalAuthentication _auth = LocalAuthentication();

  void _onKeyPress(String value) {
    if (_pin.length < _pinLength) {
      setState(() {
        _pin += value;
        _isError = false;
      });

      // Simulación de verificación cuando se completan los 4 dígitos
      if (_pin.length == _pinLength) {
        _verifyPin();
      }
    }
  }

  void _onDelete() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
        _isError = false;
      });
    }
  }

  void _verifyPin() {
    if (_pin == AppState.instance.appPin) {
      // Éxito: Desbloquear app o navegar
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      } else {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } else {
      // Error
      setState(() {
        _isError = true;
      });
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _pin = '';
            _isError = false;
          });
        }
      });
    }
  }

  Future<void> _triggerBiometrics() async {
    try {
      final available =
          await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
      if (!available) {
        throw Exception('Este dispositivo no tiene biometría configurada.');
      }
      final authenticated = await _auth.authenticate(
        localizedReason: 'Confirma tu identidad para abrir Ideon',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
      if (!mounted) return;
      if (authenticated) {
        AppState.instance.skipNextLockAfterBiometric = true;
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        } else {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo usar la biometría: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor, // Midnight Black
      body: Stack(
        children: [
          // Sutil resplandor ambiental superior de fondo (Indigo Glow)
          Positioned(
            top: -120,
            left: MediaQuery.of(context).size.width / 2 - 120,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF6366F1).withValues(alpha: 0.12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.12),
                    blurRadius: 150,
                  ),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),

                // 1. CENTRO: BRANDING & WELCOME
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.4),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withValues(alpha: 0.2),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.grid_view_rounded,
                    color: Color(0xFF6366F1),
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'IDEON',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Bienvenido de nuevo.',
                  style: TextStyle(
                    color: Color(0xFF8E9BAE),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),

                const Spacer(flex: 2),

                // 2. PIN INDICATOR
                Text(
                  'Ingresa tu código',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_pinLength, (index) {
                    final bool isFilled = index < _pin.length;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isFilled
                            ? (_isError
                                  ? const Color(
                                      0xFFFFB74D,
                                    ) // Indicador suave de error (evitando rojo)
                                  : const Color(
                                      0xFF00F0FF,
                                    )) // Electric Blue activo
                            : const Color(0xFF1A202C),
                        border: Border.all(
                          color: isFilled
                              ? const Color(0xFF00F0FF)
                              : const Color(0xFF2A3142),
                          width: 1.5,
                        ),
                        boxShadow: isFilled
                            ? [
                                BoxShadow(
                                  color: const Color(
                                    0xFF00F0FF,
                                  ).withValues(alpha: 0.5),
                                  blurRadius: 8,
                                ),
                              ]
                            : [],
                      ),
                    );
                  }),
                ),

                const Spacer(flex: 3),

                // 3. KEYPAD NUMÉRICO ELEGANTE
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildKeypadButton('1'),
                          _buildKeypadButton('2'),
                          _buildKeypadButton('3'),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildKeypadButton('4'),
                          _buildKeypadButton('5'),
                          _buildKeypadButton('6'),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildKeypadButton('7'),
                          _buildKeypadButton('8'),
                          _buildKeypadButton('9'),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Botón biométrico integrado en el teclado
                          _buildIconButton(
                            icon: Icons.fingerprint_rounded,
                            iconColor: const Color(0xFF00F0FF),
                            onTap: _triggerBiometrics,
                          ),
                          _buildKeypadButton('0'),
                          // Botón borrar
                          _buildIconButton(
                            icon: Icons.backspace_outlined,
                            iconColor: const Color(0xFF64748B),
                            onTap: _onDelete,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 2),

                // 4. BOTTOM ACCION BIOMÉTRICA
                InkWell(
                  onTap: _triggerBiometrics,
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.fingerprint_rounded,
                          color: Color(0xFF6366F1),
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Usar autenticación biométrica',
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Botón numérico del teclado
  Widget _buildKeypadButton(String number) {
    return InkWell(
      onTap: () => _onKeyPress(number),
      borderRadius: BorderRadius.circular(36),
      child: Container(
        width: 68,
        height: 68,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).cardColor,
          border: Border.all(color: const Color(0xFF1E2638), width: 1),
        ),
        child: Center(
          child: Text(
            number,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // Botón de icono para acciones auxiliares del teclado (Biometría / Borrar)
  Widget _buildIconButton({
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(36),
      child: Container(
        width: 68,
        height: 68,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent,
        ),
        child: Center(child: Icon(icon, color: iconColor, size: 22)),
      ),
    );
  }
}
