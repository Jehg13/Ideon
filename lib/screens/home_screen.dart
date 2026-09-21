import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            Theme.of(context).brightness == Brightness.light
            ? Brightness.dark
            : Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // 1. HEADER & PROFILE
              _buildHeader(context),

              const SizedBox(height: 24),

              // 2. HERO QUICK CAPTURE CARD
              _buildQuickCaptureCard(context),

              const SizedBox(height: 28),

              // 3. OVERVIEW METRICS (2x2 Grid)
              _buildOverviewMetrics(context),

              const SizedBox(height: 32),

              // 4. RECENT ACTIVITY
              _buildSectionHeader(
                context,
                'Reciente',
                onSeeAll: () => Navigator.of(context).pushNamed('/inbox'),
              ),
              const SizedBox(height: 14),
              _buildRecentList(context),

              const SizedBox(height: 32),

              // 5. ACTIVE PROJECTS (Horizontal Carousel)
              _buildSectionHeader(
                context,
                'Proyectos',
                onSeeAll: () => Navigator.of(context).pushNamed('/projects'),
              ),
              const SizedBox(height: 14),
              _buildProjectsCarousel(context),

              const SizedBox(height: 100), // Espacio para el Bottom Navigation
            ],
          ),
        ),
      ),

      // FLOATING ACTION BUTTON
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed('/quick-capture');
        },
        backgroundColor: const Color(0xFF2563EB),
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2563EB).withValues(alpha: 0.6),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
        ),
      ),

      // BOTTOM NAVIGATION BAR
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  // --- WIDGETS DE LA INTERFAZ ---

  Widget _buildHeader(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final primary = isLight ? const Color(0xFF172033) : Colors.white;
    final surface = isLight ? Colors.white : const Color(0xFF101521);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Buenos días, Jesús.',
              style: TextStyle(
                color: primary,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                fontFamily: 'Inter',
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: 4),
            Text(
              '¿Qué tienes en mente?',
              style: TextStyle(
                color: Color(0xFF94A3B8), // Cool Gray
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),

        // Avatar minimalista local
        GestureDetector(
          onTap: () => Navigator.of(context).pushNamed('/settings'),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: surface,
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF2563EB).withValues(alpha: 0.5),
                width: 1.5,
              ),
            ),
            child: const Center(
              child: Text(
                'J',
                style: TextStyle(
                  color: Color(0xFF38BDF8),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickCaptureCard(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final surface = isLight ? Colors.white : const Color(0xFF101521);
    final primary = isLight ? const Color(0xFF172033) : Colors.white;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF2563EB).withValues(alpha: 0.5),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.15),
            blurRadius: 20,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).pushNamed('/quick-capture');
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2563EB).withValues(alpha: 0.5),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '+ Captura una idea',
                        style: TextStyle(
                          color: primary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter',
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Escríbela antes de olvidarla.',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Color(0xFF475569),
                  size: 14,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewMetrics(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final surface = isLight ? Colors.white : const Color(0xFF101521);
    final secondary = isLight
        ? const Color(0xFF52627A)
        : const Color(0xFF94A3B8);
    final captures = AppState.instance.captures;
    final metrics = [
      {
        'count': '${captures.where((item) => item.type == 'Idea').length}',
        'label': 'Ideas',
        'color': const Color(0xFF38BDF8),
      },
      {
        'count':
            '${captures.where((item) => item.type == 'Improvement').length}',
        'label': 'Mejoras',
        'color': const Color(0xFF818CF8),
      },
      {
        'count': '${captures.where((item) => item.type == 'Task').length}',
        'label': 'Pendientes',
        'color': const Color(0xFF60A5FA),
      },
      {
        'count': '${AppState.instance.projects.length}',
        'label': 'Proyectos',
        'color': const Color(0xFFA78BFA),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: metrics.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        final item = metrics[index];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF1E293B)),
          ),
          child: Row(
            children: [
              Text(
                item['count'] as String,
                style: TextStyle(
                  color: item['color'] as Color,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'RobotoMono',
                ),
              ),
              const SizedBox(width: 12),
              Text(
                item['label'] as String,
                style: TextStyle(
                  color: secondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecentList(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final surface = isLight ? Colors.white : const Color(0xFF101521);
    final primary = isLight ? const Color(0xFF172033) : Colors.white;
    final recentItems = AppState.instance.captures
        .take(4)
        .map(
          (capture) => {
            'title': capture.title,
            'project': capture.project,
            'type': capture.type,
            'time': 'Ahora',
            'icon': capture.icon,
            'iconColor': capture.iconColor,
          },
        )
        .toList();

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recentItems.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = recentItems[index];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF1E293B)),
          ),
          child: Row(
            children: [
              Icon(
                item['icon'] as IconData,
                size: 18,
                color: item['iconColor'] as Color,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title'] as String,
                      style: TextStyle(
                        color: primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          item['project'] as String,
                          style: const TextStyle(
                            color: Color(0xFF818CF8),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Text(
                          ' · ',
                          style: TextStyle(color: Color(0xFF475569)),
                        ),
                        Text(
                          item['type'] as String,
                          style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 11,
                          ),
                        ),
                        const Text(
                          ' · ',
                          style: TextStyle(color: Color(0xFF475569)),
                        ),
                        Text(
                          item['time'] as String,
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.more_vert_rounded,
                color: Color(0xFF475569),
                size: 18,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProjectsCarousel(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final surface = isLight ? Colors.white : const Color(0xFF101521);
    final primary = isLight ? const Color(0xFF172033) : Colors.white;
    final projects = AppState.instance.projects.map((project) {
      final count = AppState.instance.countForProject(project.name);
      return {
        'name': project.name,
        'ideas': '$count items',
        'improvements': project.description,
      };
    }).toList();

    return SizedBox(
      height: 154,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: projects.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final project = projects[index];
          return GestureDetector(
            onTap: () => Navigator.of(
              context,
            ).pushNamed('/project-detail', arguments: project['name']),
            child: Container(
              width: 170,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF1E293B)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          project['name']!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.folder_open_outlined,
                        color: Color(0xFF38BDF8),
                        size: 16,
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project['ideas']!,
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        project['improvements']!,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title, {
    required VoidCallback onSeeAll,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.light
                ? const Color(0xFF172033)
                : Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final surface = isLight ? Colors.white : const Color(0xFF080B12);
    return Container(
      decoration: BoxDecoration(
        color: surface,
        border: Border(
          top: BorderSide(
            color: isLight ? const Color(0xFFDCE3EF) : const Color(0xFF1E293B),
          ),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          const routes = ['/home', '/inbox', '/projects', '/search'];
          if (index != 0) {
            Navigator.of(context).pushReplacementNamed(routes[index]);
          }
        },
        backgroundColor: surface,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF2563EB),
        unselectedItemColor: const Color(0xFF64748B),
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_rounded),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inbox_outlined),
            label: 'Bandeja',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_outlined),
            label: 'Proyectos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_rounded),
            label: 'Buscar',
          ),
        ],
      ),
    );
  }
}
