import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0; // 0: Pantalla 1, 1: Pantalla 2, 2: Pantalla 3

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: Theme.of(
        context,
      ).scaffoldBackgroundColor, // Midnight / Deep Navy
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar: Logo + Skip (se oculta el Skip en la última pantalla)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: CustomPaint(painter: SmallIdeonLogoPainter()),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'IDEON',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.0,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                  if (_currentPage < 2)
                    TextButton(
                      onPressed: () {
                        _pageController.animateToPage(
                          2,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          color: Color(0xFF64748B), // Cool Gray
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  else
                    const SizedBox(
                      height: 36,
                    ), // Espaciador para mantener altura
                ],
              ),
            ),

            // Contenido deslizable (PageView)
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  Onboarding1Content(),
                  Onboarding2Content(),
                  Onboarding3Content(), // PANTALLA 3
                ],
              ),
            ),

            // Footer persistente: Indicador + Botón
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 28.0,
                vertical: 24.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Progress Indicator
                  Row(
                    children: [
                      Text(
                        '0${_currentPage + 1}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'RobotoMono',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        children: List.generate(3, (index) {
                          final isActive = index <= _currentPage;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            width: isActive ? 20 : 8,
                            height: 4,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? const Color(0xFF2563EB)
                                  : const Color(0xFF1E293B),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '03',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'RobotoMono',
                        ),
                      ),
                    ],
                  ),

                  // Botón Principal
                  ElevatedButton(
                    onPressed: () {
                      if (_currentPage < 2) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        Navigator.of(context).pushReplacementNamed('/home');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: _currentPage == 2 ? 32 : 28,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 8,
                      shadowColor: const Color(0xFF2563EB).withValues(alpha: 0.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _currentPage == 2 ? 'Comenzar' : 'Continuar',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          _currentPage == 2
                              ? Icons.rocket_launch_outlined
                              : Icons.arrow_forward_rounded,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// PANTALLA ONBOARDING 3 — "Build what matters."
// ==========================================
class Onboarding3Content extends StatelessWidget {
  const Onboarding3Content({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Composición Visual Central: Evolución + Tarjeta Convertida
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Fondo con Resplandor Indigo/Azul
              Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.65,
                    colors: [
                      Color(0x252563EB), // Electric Blue Glow
                      Color(0x00080B12),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Cadena de Evolución Tecnológica (Nodos)
                    const TechEvolutionPipeline(),

                    const SizedBox(height: 28),

                    // Tarjeta Destacada de Conversión
                    _buildConversionExampleCard(),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Copy Inferior
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Build what matters.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Inter',
                  height: 1.2,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Turn your ideas into improvements, tasks and projects you can actually build.',
                style: TextStyle(
                  color: Color(0xFF94A3B8), // Cool Gray
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Componente de Tarjeta de Ejemplo mostrando la conversión
  Widget _buildConversionExampleCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF101521),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2563EB).withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.auto_awesome, size: 14, color: Color(0xFF38BDF8)),
                  SizedBox(width: 6),
                  Text(
                    'CONVERTED TO TASK',
                    style: TextStyle(
                      color: Color(0xFF38BDF8),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Planned',
                  style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Add achievement system',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildMetaTag('Project', 'GymOS', const Color(0xFF818CF8)),
              const SizedBox(width: 12),
              _buildMetaTag('Type', 'Feature', const Color(0xFF60A5FA)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetaTag(String label, String value, Color accent) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
        ),
        Text(
          value,
          style: TextStyle(
            color: accent,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// Widget de la línea de tiempo evolutiva de la idea
class TechEvolutionPipeline extends StatelessWidget {
  const TechEvolutionPipeline({super.key});

  @override
  Widget build(BuildContext context) {
    final stages = [
      {'label': 'Spark', 'icon': Icons.flash_on_outlined},
      {'label': 'Idea', 'icon': Icons.lightbulb_outline},
      {'label': 'Improvement', 'icon': Icons.tune_outlined},
      {'label': 'Task', 'icon': Icons.task_alt_outlined},
      {'label': 'Project', 'icon': Icons.folder_open_outlined},
      {'label': 'Build', 'icon': Icons.code_rounded},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(stages.length, (index) {
          final isLast = index == stages.length - 1;
          final isHighlight = index == 5; // Node 'Build'

          return Row(
            children: [
              Column(
                children: [
                  Container(
                    width: isHighlight ? 38 : 32,
                    height: isHighlight ? 38 : 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isHighlight
                          ? const Color(0xFF2563EB)
                          : const Color(0xFF101521),
                      border: Border.all(
                        color: isHighlight
                            ? const Color(0xFF38BDF8)
                            : const Color(0xFF334155),
                      ),
                    ),
                    child: Icon(
                      stages[index]['icon'] as IconData,
                      size: isHighlight ? 18 : 14,
                      color: isHighlight
                          ? Colors.white
                          : const Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    stages[index]['label'] as String,
                    style: TextStyle(
                      color: isHighlight
                          ? Colors.white
                          : const Color(0xFF64748B),
                      fontSize: 10,
                      fontWeight: isHighlight
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ],
              ),
              if (!isLast)
                Container(
                  width: 18,
                  height: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  color: const Color(0xFF2563EB).withValues(alpha: 0.4),
                ),
            ],
          );
        }),
      ),
    );
  }
}

// ==========================================
// PANTALLAS ANTERIORES REUTILIZADAS
// ==========================================
class Onboarding1Content extends StatelessWidget {
  const Onboarding1Content({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.6,
                    colors: [Color(0x2838BDF8), Color(0x00080B12)],
                  ),
                ),
              ),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF101521),
                  border: Border.all(
                    color: const Color(0xFF38BDF8).withValues(alpha: 0.5),
                  ),
                ),
                child: Center(
                  child: SizedBox(
                    width: 32,
                    height: 32,
                    child: CustomPaint(painter: SmallIdeonLogoPainter()),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Capture every idea.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Your next great project can start with a single thought.',
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class Onboarding2Content extends StatelessWidget {
  const Onboarding2Content({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.6,
                    colors: [Color(0x206366F1), Color(0x00080B12)],
                  ),
                ),
              ),
              const Center(
                child: Icon(
                  Icons.hub_outlined,
                  color: Color(0xFF38BDF8),
                  size: 48,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Everything has a place.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Organize ideas, improvements, bugs and pending work without slowing down your workflow.',
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class SmallIdeonLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF38BDF8), Color(0xFF6366F1)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path = Path();
    path.moveTo(center.dx, center.dy - 10);
    path.lineTo(center.dx + 8, center.dy + 6);
    path.lineTo(center.dx - 7, center.dy + 8);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
