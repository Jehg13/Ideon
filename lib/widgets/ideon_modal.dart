import 'package:flutter/material.dart';

class IdeonModal extends StatelessWidget {
  const IdeonModal({
    super.key,
    required this.icon,
    required this.eyebrow,
    required this.title,
    required this.child,
    required this.actions,
  });

  final IconData icon;
  final String eyebrow;
  final String title;
  final Widget child;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final surface = isLight ? Colors.white : const Color(0xFF111722);
    final border = isLight ? const Color(0xFFD9E2F0) : const Color(0xFF26344D);
    final primary = isLight ? const Color(0xFF172033) : Colors.white;
    final secondary = isLight
        ? const Color(0xFF52627A)
        : const Color(0xFF94A3B8);
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.86,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: border),
            boxShadow: const [
              BoxShadow(
                color: Color(0x66000000),
                blurRadius: 32,
                offset: Offset(0, 16),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                Positioned(
                  top: -70,
                  right: -45,
                  child: Container(
                    width: 170,
                    height: 170,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF6366F1).withValues(alpha: 0.12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFF6366F1,
                          ).withValues(alpha: 0.16),
                          blurRadius: 70,
                        ),
                      ],
                    ),
                  ),
                ),
                SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF2563EB,
                                ).withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(13),
                                border: Border.all(
                                  color: const Color(
                                    0xFF38BDF8,
                                  ).withValues(alpha: 0.25),
                                ),
                              ),
                              child: Icon(
                                icon,
                                color: const Color(0xFF38BDF8),
                                size: 21,
                              ),
                            ),
                            const SizedBox(width: 13),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    eyebrow.toUpperCase(),
                                    style: TextStyle(
                                      color: isLight
                                          ? const Color(0xFF2563EB)
                                          : const Color(0xFF38BDF8),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    title,
                                    style: TextStyle(
                                      color: primary,
                                      fontSize: 21,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: Icon(Icons.close_rounded),
                              color: secondary,
                              tooltip: 'Cerrar',
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        child,
                        const SizedBox(height: 24),
                        Wrap(
                          alignment: WrapAlignment.end,
                          spacing: 8,
                          runSpacing: 8,
                          children: actions,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

InputDecoration ideonInputDecoration({
  required String label,
  required IconData icon,
  String? hint,
}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    labelStyle: TextStyle(color: const Color(0xFF64748B), fontSize: 13),
    hintStyle: TextStyle(color: const Color(0xFF94A3B8), fontSize: 13),
    prefixIcon: Icon(icon, color: const Color(0xFF6366F1), size: 19),
    filled: true,
    fillColor: Colors.transparent,
    contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: BorderSide(
        color: const Color(0xFF94A3B8).withValues(alpha: 0.45),
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: const BorderSide(color: Color(0xFF38BDF8), width: 1.2),
    ),
  );
}

Widget ideonSecondaryButton({
  required String label,
  required VoidCallback onPressed,
}) {
  return Builder(
    builder: (context) {
      final isLight = Theme.of(context).brightness == Brightness.light;
      return TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: isLight ? const Color(0xFF52627A) : Colors.white,
          backgroundColor: isLight
              ? const Color(0xFFF0F4FA)
              : const Color(0xFF1B2638),
          side: BorderSide(
            color: isLight ? const Color(0xFFD5DFEC) : const Color(0xFF334155),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(label),
      );
    },
  );
}

Widget ideonPrimaryButton({
  required String label,
  required VoidCallback onPressed,
  IconData icon = Icons.arrow_forward_rounded,
}) {
  return FilledButton.icon(
    onPressed: onPressed,
    icon: Icon(icon, size: 17),
    label: Text(label),
    style: FilledButton.styleFrom(
      backgroundColor: const Color(0xFF2563EB),
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
