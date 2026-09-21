import 'package:flutter/material.dart';

/// Screen independiente de Visualización de Empty States para IDEON.
/// Incluye un selector de Tabs superior para alternar entre los 4 Empty States
/// con estética Dark Premium, geometría abstracta, nodos, chispas y mucho espacio negativo.
class IdeonEmptyStatesScreen extends StatefulWidget {
  const IdeonEmptyStatesScreen({super.key});

  @override
  State<IdeonEmptyStatesScreen> createState() => _IdeonEmptyStatesScreenState();
}

class _IdeonEmptyStatesScreenState extends State<IdeonEmptyStatesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Sutil resplandor ambiental superior
          Positioned(
            top: -120,
            left: MediaQuery.of(context).size.width / 2 - 120,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF6366F1).withValues(alpha: 0.08),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.08),
                    blurRadius: 150,
                  ),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Header & Selector de Ejemplo de Empty State
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () {
                              if (Navigator.canPop(context)) {
                                Navigator.pop(context);
                              } else {
                                Navigator.of(
                                  context,
                                ).pushReplacementNamed('/home');
                              }
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 6,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    color: Color(0xFF94A3B8),
                                    size: 14,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'Regresar',
                                    style: TextStyle(
                                      color: Color(0xFF94A3B8),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Text(
                            'EMPTY STATES',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(width: 48), // Balance visual
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 38,
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color:
                                Theme.of(context).brightness == Brightness.light
                                ? const Color(0xFFD9E2F0)
                                : const Color(0xFF1E2638),
                            width: 1,
                          ),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          isScrollable: true,
                          indicator: BoxDecoration(
                            color:
                                Theme.of(context).brightness == Brightness.light
                                ? const Color(0xFF2563EB)
                                : const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFF6366F1),
                              width: 1,
                            ),
                          ),
                          labelColor: Colors.white,
                          unselectedLabelColor:
                              Theme.of(context).brightness == Brightness.light
                              ? const Color(0xFF52627A)
                              : const Color(0xFF64748B),
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          tabs: const [
                            Tab(text: 'Bandeja'),
                            Tab(text: 'Proyectos'),
                            Tab(text: 'Buscar'),
                            Tab(text: 'Ideas'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Contenido de los Empty States
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // 1. EMPTY INBOX
                      _buildEmptyStateLayout(
                        abstractGraphic: _buildSparkGraphic(),
                        title: 'Your mind is clear.',
                        description:
                            'Captura tu próxima idea antes de que desaparezca.',
                        buttonLabel: '+ Capture idea',
                        onPressed: () =>
                            Navigator.of(context).pushNamed('/quick-capture'),
                      ),

                      // 2. EMPTY PROJECTS
                      _buildEmptyStateLayout(
                        abstractGraphic: _buildNodesGraphic(),
                        title: 'Aún no hay nada aquí.',
                        description:
                            'Comienza con una idea y conviértela en algo real.',
                        buttonLabel: '+ Crear proyecto',
                        onPressed: () =>
                            Navigator.of(context).pushNamed('/quick-capture'),
                      ),

                      // 3. EMPTY SEARCH
                      _buildEmptyStateLayout(
                        abstractGraphic: _buildSearchAbstractGraphic(),
                        title: 'Sin resultados.',
                        description: 'Try another keyword.',
                        buttonLabel: null, // Sin botón según especificación
                      ),

                      // 4. EMPTY IDEAS
                      _buildEmptyStateLayout(
                        abstractGraphic: _buildGeometricIdeasGraphic(),
                        title: 'Aún no hay ideas.',
                        description: 'Todo proyecto comienza con una.',
                        buttonLabel: '+ Add idea',
                        onPressed: () =>
                            Navigator.of(context).pushNamed('/quick-capture'),
                      ),
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

  // Estructura Base para cada Empty State con amplio espacio negativo
  Widget _buildEmptyStateLayout({
    required Widget abstractGraphic,
    required String title,
    required String description,
    String? buttonLabel,
    VoidCallback? onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const Spacer(flex: 3),

          // Gráfico abstracto geométrico / tecnológico
          abstractGraphic,

          const SizedBox(height: 36),

          // Título del Empty State
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),

          const SizedBox(height: 10),

          // Descripción
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF8E9BAE),
              fontSize: 14,
              height: 1.45,
              fontWeight: FontWeight.w400,
            ),
          ),

          const SizedBox(height: 28),

          // Botón de acción opcional
          if (buttonLabel != null)
            ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                elevation: 4,
                shadowColor: const Color(0xFF6366F1).withValues(alpha: 0.35),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                buttonLabel,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ),

          const Spacer(flex: 4),
        ],
      ),
    );
  }

  // Visual 1: Spark / Chispa & Nodo central pulsante (Inbox)
  Widget _buildSparkGraphic() {
    return Container(
      width: 120,
      height: 120,
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Anillo concéntrico sutil
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF00F0FF).withValues(alpha: 0.12),
                width: 1,
              ),
            ),
          ),
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF6366F1).withValues(alpha: 0.25),
                width: 1,
              ),
            ),
          ),
          // Chispa central glowing
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF00F0FF),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00F0FF).withValues(alpha: 0.6),
                  blurRadius: 20,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Icon(
              Icons.auto_awesome_rounded,
              color: Color(0xFF07080C),
              size: 14,
            ),
          ),
        ],
      ),
    );
  }

  // Visual 2: Nodos Interconectados (Projects)
  Widget _buildNodesGraphic() {
    return SizedBox(
      width: 140,
      height: 100,
      child: CustomPaint(painter: _NodesPainter()),
    );
  }

  // Visual 3: Búsqueda Abstracta / Esferas desalineadas (Search)
  Widget _buildSearchAbstractGraphic() {
    return SizedBox(
      width: 120,
      height: 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 20,
            top: 20,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
            ),
          ),
          Positioned(
            right: 25,
            bottom: 15,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF00F0FF).withValues(alpha: 0.3),
                  width: 1.2,
                ),
              ),
            ),
          ),
          Positioned(
            right: 48,
            top: 15,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFA855F7),
              ),
            ),
          ),
          // Línea diagonal abstracta de escaneo
          Transform.rotate(
            angle: -0.6,
            child: Container(
              width: 80,
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF00F0FF).withValues(alpha: 0.0),
                    const Color(0xFF00F0FF),
                    const Color(0xFF00F0FF).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Visual 4: Formas Geométricas / Cubo o Diamante flotante (Ideas)
  Widget _buildGeometricIdeasGraphic() {
    return SizedBox(
      width: 120,
      height: 110,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Rombo / Diamante rotado
          Transform.rotate(
            angle: 0.785398, // 45 grados
            child: Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFA855F7).withValues(alpha: 0.5),
                  width: 1.5,
                ),
                color: const Color(0xFFA855F7).withValues(alpha: 0.06),
              ),
            ),
          ),
          // Punto de origen tecnológico
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF6366F1),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.7),
                  blurRadius: 12,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter para renderizar nodos y líneas conectoras abstractas para Projects
class _NodesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintLine = Paint()
      ..color = const Color(0xFF1E2638)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final paintActiveLine = Paint()
      ..color = const Color(0xFF6366F1).withValues(alpha: 0.4)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final paintNode = Paint()..color = const Color(0xFF131722);
    final paintBorderNode = Paint()
      ..color = const Color(0xFF64748B)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final paintActiveNode = Paint()..color = const Color(0xFF00F0FF);

    final p1 = Offset(size.width * 0.2, size.height * 0.5);
    final p2 = Offset(size.width * 0.5, size.height * 0.2);
    final p3 = Offset(size.width * 0.8, size.height * 0.6);
    final p4 = Offset(size.width * 0.5, size.height * 0.85);

    // Dibuja conectores
    canvas.drawLine(p1, p2, paintActiveLine);
    canvas.drawLine(p2, p3, paintLine);
    canvas.drawLine(p1, p4, paintLine);
    canvas.drawLine(p4, p3, paintLine);

    // Dibuja Nodos
    canvas.drawCircle(p1, 6, paintNode);
    canvas.drawCircle(p1, 6, paintBorderNode);

    canvas.drawCircle(p2, 7, paintActiveNode);

    canvas.drawCircle(p3, 5, paintNode);
    canvas.drawCircle(p3, 5, paintBorderNode);

    canvas.drawCircle(p4, 5, paintNode);
    canvas.drawCircle(p4, 5, paintBorderNode);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
