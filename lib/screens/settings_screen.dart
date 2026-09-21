import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:local_auth/local_auth.dart';

import '../app_state.dart';
import '../widgets/ideon_modal.dart';

/// Screen individual de Configuración (Settings) para IDEON.
/// Diseñada con estética Dark Premium, agrupaciones claras y controles interactivos.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Estado de Apariencia
  // Estado de Seguridad
  bool get _appLockEnabled => AppState.instance.appLockEnabled;
  bool get _biometricEnabled => AppState.instance.biometricEnabled;
  final LocalAuthentication _auth = LocalAuthentication();

  int get _selectedThemeIndex => AppState.instance.themeIndex;

  @override
  Widget build(BuildContext context) {
    final isLightTheme = Theme.of(context).brightness == Brightness.light;
    final isSystemTheme = AppState.instance.themeIndex == 2;
    final backgroundColor = isLightTheme
        ? const Color(0xFFF5F7FB)
        : isSystemTheme
        ? const Color(0xFF071417)
        : const Color(0xFF090B10);
    final panelColor = isLightTheme
        ? Colors.white
        : isSystemTheme
        ? const Color(0xFF102326)
        : const Color(0xFF131722);
    final borderColor = isLightTheme
        ? const Color(0xFFDCE3EF)
        : isSystemTheme
        ? const Color(0xFF214248)
        : const Color(0xFF1E2638);
    final primaryText = isLightTheme
        ? const Color(0xFF172033)
        : Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Sutil resplandor ambiental de fondo (Glow)
          Positioned(
            top: -100,
            left: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF6366F1).withValues(alpha: 0.10),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.10),
                    blurRadius: 140,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            right: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00F0FF).withValues(alpha: 0.06),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00F0FF).withValues(alpha: 0.06),
                    blurRadius: 120,
                  ),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. HEADER
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () =>
                            Navigator.of(context).pushReplacementNamed('/home'),
                        icon: Icon(Icons.arrow_back_rounded),
                        color: isLightTheme
                            ? const Color(0xFF52627A)
                            : const Color(0xFF94A3B8),
                        tooltip: 'Volver',
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Configuración',
                            style: TextStyle(
                              color: primaryText,
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Personaliza tu espacio de trabajo.',
                            style: TextStyle(
                              color: isLightTheme
                                  ? const Color(0xFF64748B)
                                  : const Color(0xFF8E9BAE),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: panelColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: borderColor, width: 1),
                        ),
                        child: Icon(
                          Icons.settings_outlined,
                          color: Color(0xFF6366F1),
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),

                // 2. MAIN CONTENT SCROLLABLE
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      const SizedBox(height: 8),

                      // APPEARANCE SECTION
                      _buildSectionHeader('APARIENCIA'),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: panelColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: borderColor, width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Modo de tema',
                              style: TextStyle(
                                color: primaryText,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                _buildThemeOption(
                                  0,
                                  'Oscuro',
                                  Icons.dark_mode_outlined,
                                ),
                                const SizedBox(width: 8),
                                _buildThemeOption(
                                  1,
                                  'Claro',
                                  Icons.light_mode_outlined,
                                ),
                                const SizedBox(width: 8),
                                _buildThemeOption(
                                  2,
                                  'Sistema',
                                  Icons.settings_suggest_outlined,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // SECURITY SECTION
                      _buildSectionHeader('SEGURIDAD'),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: panelColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: borderColor, width: 1),
                        ),
                        child: Column(
                          children: [
                            _buildSwitchTile(
                              icon: Icons.lock_outline_rounded,
                              iconColor: const Color(0xFFFFB74D),
                              title: 'Bloqueo de la app',
                              subtitle: 'Requiere código para abrir la app',
                              value: _appLockEnabled,
                              onChanged: (val) {
                                if (val) {
                                  _configurePin();
                                } else {
                                  AppState.instance.updatePreferences(
                                    appLockEnabled: false,
                                  );
                                }
                              },
                            ),
                            Divider(color: borderColor, height: 1),
                            _buildSwitchTile(
                              icon: Icons.fingerprint_rounded,
                              iconColor: const Color(0xFF10B981),
                              title: 'Autenticación biométrica',
                              subtitle: 'Desbloquea con rostro o huella',
                              value: _biometricEnabled,
                              onChanged: (val) {
                                _toggleBiometrics(val);
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // DATA SECTION
                      _buildSectionHeader('GESTIÓN DE DATOS'),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: panelColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: borderColor, width: 1),
                        ),
                        child: Column(
                          children: [
                            _buildActionTile(
                              icon: Icons.upload_file_rounded,
                              title: 'Exportar datos',
                              subtitle: 'Archivo de respaldo JSON o CSV',
                              onTap: _exportData,
                            ),
                            Divider(color: borderColor, height: 1),
                            _buildActionTile(
                              icon: Icons.download_rounded,
                              title: 'Importar datos',
                              subtitle: 'Restaura el espacio desde un archivo',
                              onTap: _importData,
                            ),
                            Divider(color: borderColor, height: 1),
                            _buildActionTile(
                              icon: Icons.cloud_upload_outlined,
                              title: 'Crear respaldo',
                              subtitle: 'Sincroniza una copia segura',
                              onTap: _createBackup,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // ABOUT SECTION
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF6366F1,
                                ).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(
                                    0xFF6366F1,
                                  ).withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                Icons.grid_view_rounded,
                                color: Color(0xFF6366F1),
                                size: 24,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'IDEON',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Version 1.0.0',
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Ideas que vale la pena construir.',
                              style: TextStyle(
                                color: Color(0xFF8E9BAE),
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _configurePin() async {
    final pinController = TextEditingController();
    final confirmationController = TextEditingController();
    var pinVisible = false;
    var confirmationVisible = false;
    final values = await showDialog<List<String>>(
      context: context,
      builder: (context) => MediaQuery.removeViewInsets(
        context: context,
        removeBottom: true,
        child: StatefulBuilder(
          builder: (context, setModalState) => IdeonModal(
            icon: Icons.lock_outline_rounded,
            eyebrow: 'Seguridad',
            title: 'Configurar código',
            actions: [
              ideonSecondaryButton(
                label: 'Cancelar',
                onPressed: () => Navigator.pop(context),
              ),
              ideonPrimaryButton(
                label: 'Guardar código',
                icon: Icons.check_rounded,
                onPressed: () => Navigator.pop(context, [
                  pinController.text,
                  confirmationController.text,
                ]),
              ),
            ],
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Crea un código para proteger tu espacio personal.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: pinController,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  obscureText: !pinVisible,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    letterSpacing: 5,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration:
                      ideonInputDecoration(
                        label: 'Nuevo código',
                        icon: Icons.password_rounded,
                        hint: '4 dígitos',
                      ).copyWith(
                        counterText: '',
                        suffixIcon: IconButton(
                          onPressed: () =>
                              setModalState(() => pinVisible = !pinVisible),
                          icon: Icon(
                            pinVisible
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                        ),
                      ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: confirmationController,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  obscureText: !confirmationVisible,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    letterSpacing: 5,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration:
                      ideonInputDecoration(
                        label: 'Confirmar código',
                        icon: Icons.verified_user_outlined,
                        hint: 'Repite los 4 dígitos',
                      ).copyWith(
                        counterText: '',
                        suffixIcon: IconButton(
                          onPressed: () => setModalState(
                            () => confirmationVisible = !confirmationVisible,
                          ),
                          icon: Icon(
                            confirmationVisible
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                        ),
                      ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Lo necesitarás cada vez que regreses a la aplicación.',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 350));
    pinController.dispose();
    confirmationController.dispose();
    if (!mounted || values == null) return;
    final pin = values[0];
    if (pin != values[1]) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Los códigos no coinciden.')),
      );
      return;
    }
    try {
      await AppState.instance.setAppPin(pin);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Código de bloqueo configurado.')),
        );
      }
    } on FormatException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    }
  }

  Future<void> _toggleBiometrics(bool enabled) async {
    if (!enabled) {
      AppState.instance.updatePreferences(biometricEnabled: false);
      return;
    }
    if (!AppState.instance.appPinConfigured) {
      await _configurePin();
      if (!mounted || !AppState.instance.appPinConfigured) return;
    }
    try {
      final supported = await _auth.isDeviceSupported();
      final enrolled = await _auth.getAvailableBiometrics();
      if (!supported || enrolled.isEmpty) {
        throw Exception(
          'Configura primero una huella o rostro en los ajustes del dispositivo.',
        );
      }
      final authenticated = await _auth.authenticate(
        localizedReason: 'Confirma la biometría para proteger Ideon',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
      if (!authenticated) return;
      AppState.instance.updatePreferences(
        biometricEnabled: true,
        appLockEnabled: true,
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo activar la biometría: $error')),
      );
      return;
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Biometría activada. Configúrala en los ajustes de seguridad del dispositivo.',
          ),
        ),
      );
    }
  }

  // Encabezado de Sección
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        color: const Color(0xFF52627A),
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.0,
      ),
    );
  }

  Future<void> _exportData() async {
    try {
      final bytes = Uint8List.fromList(
        utf8.encode(AppState.instance.exportDataJson()),
      );
      await FileSaver.instance.saveFile(
        name: 'ideon-respaldo-${DateTime.now().millisecondsSinceEpoch}',
        bytes: bytes,
        ext: 'json',
        mimeType: MimeType.json,
      );
      if (mounted) _showDataMessage('Datos exportados correctamente.');
    } catch (error) {
      if (mounted) _showDataMessage('No se pudo exportar: $error');
    }
  }

  Future<void> _importData() async {
    try {
      final pickedFiles = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (pickedFiles.isEmpty) return;
      final bytes = await pickedFiles.single.readAsBytes();
      final source = utf8.decode(bytes);
      AppState.instance.importDataJson(source);
      if (mounted) _showDataMessage('Datos importados correctamente.');
    } on FormatException catch (error) {
      if (mounted) _showDataMessage('Respaldo inválido: ${error.message}');
    } catch (error) {
      if (mounted) _showDataMessage('No se pudo importar: $error');
    }
  }

  Future<void> _createBackup() async {
    await _exportData();
  }

  void _showDataMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  // Opción de Selector de Tema
  Widget _buildThemeOption(int index, String label, IconData icon) {
    final bool isSelected = _selectedThemeIndex == index;
    final isLightTheme = Theme.of(context).brightness == Brightness.light;
    final activeColor = switch (index) {
      0 => const Color(0xFF6366F1),
      1 => const Color(0xFFF59E0B),
      _ => const Color(0xFF0EA5E9),
    };
    return Expanded(
      child: GestureDetector(
        onTap: () {
          AppState.instance.updatePreferences(themeIndex: index);
        },
        child: AnimatedScale(
          scale: isSelected ? 1 : 0.97,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutBack,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? activeColor.withValues(
                      alpha: isLightTheme && index == 1 ? 0.9 : 1,
                    )
                  : (isLightTheme
                        ? const Color(0xFFF0F4FA)
                        : const Color(0xFF090B10)),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? activeColor
                    : (isLightTheme
                          ? const Color(0xFFD8E0EC)
                          : const Color(0xFF1E2638)),
                width: 1,
              ),
              boxShadow: isLightTheme
                  ? [
                      BoxShadow(
                        color: isSelected
                            ? activeColor.withValues(alpha: 0.18)
                            : const Color(0x140F2747),
                        blurRadius: isSelected ? 10 : 5,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: isSelected
                      ? Colors.white
                      : (isLightTheme
                            ? const Color(0xFF52627A)
                            : const Color(0xFF8E9BAE)),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : (isLightTheme
                              ? const Color(0xFF52627A)
                              : const Color(0xFF8E9BAE)),
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Fila con Switch para Seguridad
  Widget _buildSwitchTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final isLightTheme = Theme.of(context).brightness == Brightness.light;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isLightTheme
                        ? const Color(0xFF172033)
                        : Theme.of(context).colorScheme.onSurface,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.85,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: const Color(0xFF6366F1),
              activeTrackColor: const Color(0xFF6366F1).withValues(alpha: 0.3),
              inactiveThumbColor: isLightTheme
                  ? const Color(0xFF64748B)
                  : const Color(0xFF64748B),
              inactiveTrackColor: isLightTheme
                  ? const Color(0xFFE2E8F0)
                  : const Color(0xFF1E2330),
            ),
          ),
        ],
      ),
    );
  }

  // Fila de Acción discreta para Data Management
  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isLightTheme = Theme.of(context).brightness == Brightness.light;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: isLightTheme
                    ? const Color(0xFFE8EEF7)
                    : const Color(0xFF1E2638),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: const Color(0xFF94A3B8), size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isLightTheme
                          ? const Color(0xFF172033)
                          : Theme.of(context).colorScheme.onSurface,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Color(0xFF334155),
              size: 13,
            ),
          ],
        ),
      ),
    );
  }
}
