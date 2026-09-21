import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _textFadeAnimation;

  @override
  void initState() {
    super.initState();

    // Configurar la barra del sistema transparente
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    // Animación de escala de la chispa/nodo central
    _scaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );

    // Fade-in general de los elementos gráficos
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.7, curve: Curves.easeIn),
      ),
    );

    // Fade-in secuencial para el texto y tagline
    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.forward();

    Timer(const Duration(milliseconds: 3000), () {
      if (!mounted) {
        return;
      }

      Navigator.of(context).pushReplacementNamed(
        AppState.instance.onboardingCompleted
            ? (AppState.instance.appLockEnabled &&
                    AppState.instance.appPinConfigured
                ? '/lock'
                : '/home')
            : '/onboarding',
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080B12), // Deep Navy / Midnight
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Resplandor de fondo (Radial Glow)
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.65,
                  colors: [
                    Color(0x224F46E5), // Indigo Glow con opacidad
                    Color(0x00080B12), // Transparente hacia los bordes
                  ],
                ),
              ),
            ),
          ),

          // Puntos y nodos de fondo
          Positioned.fill(
            child: CustomPaint(painter: BackgroundNodesPainter()),
          ),

          // Contenido principal (Logo + Nombre + Tagline)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icono animado del nodo/chispa
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Opacity(
                        opacity: _fadeAnimation.value,
                        child: SizedBox(
                          width: 80,
                          height: 80,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.asset(
                              'image.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),

                // Nombre e Identidad
                FadeTransition(
                  opacity: _textFadeAnimation,
                  child: Column(
                    children: [
                      const Text(
                        'IDEON',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 4.0,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ideas que vale la pena construir.',
                        style: TextStyle(
                          color: const Color(0xFF94A3B8), // Cool Gray
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Pie de página discreto
          Positioned(
            bottom: 40,
            child: FadeTransition(
              opacity: _textFadeAnimation,
              child: const Text(
                'Espacio de trabajo personal',
                style: TextStyle(
                  color: Color(0xFF475569),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// CustomPainter para el logotipo geométrico de IDEON (Chispa / Nodo)
class IdeonLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Gradiente azul eléctrico a violeta
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF2563EB), Color(0xFF6366F1)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final glowPaint = Paint()
      ..color = const Color(0x662563EB)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0;

    // Trazado de nodo central geométrico
    final path = Path();
    path.moveTo(center.dx, center.dy - 30);
    path.lineTo(center.dx + 25, center.dy + 15);
    path.lineTo(center.dx - 20, center.dy + 25);
    path.close();

    // Dibujar brillo y línea principal
    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, paint);

    // Nodo central
    final nodePaint = Paint()
      ..color = const Color(0xFF38BDF8)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(center.dx, center.dy - 30), 4, nodePaint);
    canvas.drawCircle(Offset(center.dx + 25, center.dy + 15), 4, nodePaint);
    canvas.drawCircle(Offset(center.dx - 20, center.dy + 25), 4, nodePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// CustomPainter para sutiles puntos de fondo
class BackgroundNodesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x1A94A3B8)
      ..style = PaintingStyle.fill;

    // Matriz discreta de puntos
    const step = 40.0;
    for (double x = 20; x < size.width; x += step) {
      for (double y = 20; y < size.height; y += step) {
        canvas.drawCircle(Offset(x, y), 1.0, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
