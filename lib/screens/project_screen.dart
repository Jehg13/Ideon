import 'package:flutter/material.dart';

import '../app_state.dart';
import '../widgets/ideon_modal.dart';

/// Pantalla Principal de Proyectos para la plataforma IDEON.
class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  String _selectedSort = 'Recientes';

  Future<void> _createProject() async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final technologyController = TextEditingController();
    final technologies = <String>[];
    final projectDraft = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => MediaQuery.removeViewInsets(
        context: context,
        removeBottom: true,
        child: StatefulBuilder(
          builder: (context, setModalState) => IdeonModal(
            icon: Icons.create_new_folder_outlined,
            eyebrow: 'Espacio de trabajo',
            title: 'Crear proyecto',
            actions: [
              ideonSecondaryButton(
                label: 'Cancelar',
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 8),
              ideonPrimaryButton(
                label: 'Crear proyecto',
                icon: Icons.add_rounded,
                onPressed: () {
                  final technology = technologyController.text.trim();
                  if (technology.isNotEmpty) technologies.add(technology);
                  Navigator.pop(context, {
                    'name': nameController.text,
                    'description': descriptionController.text,
                    'technologies': List<String>.from(technologies),
                  });
                },
              ),
            ],
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  autofocus: true,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  decoration: ideonInputDecoration(
                    label: 'Nombre del proyecto',
                    icon: Icons.folder_outlined,
                    hint: 'ej. Aplicación de finanzas personales',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  maxLines: 3,
                  decoration: ideonInputDecoration(
                    label: 'Descripción',
                    icon: Icons.notes_outlined,
                    hint: '¿Qué estás construyendo?',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: technologyController,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  decoration: ideonInputDecoration(
                    label: 'Tecnologías',
                    icon: Icons.code_rounded,
                    hint: 'ej. Flutter, Firebase, Figma',
                  ),
                  onSubmitted: (value) {
                    final technology = value.trim();
                    if (technology.isEmpty) return;
                    setModalState(() {
                      technologies.add(technology);
                      technologyController.clear();
                    });
                  },
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children:
                        ['Flutter', 'Dart', 'Firebase', 'Supabase', 'Figma']
                            .map(
                              (technology) => ActionChip(
                                label: Text(technology),
                                onPressed: () {
                                  if (technologies.contains(technology)) return;
                                  setModalState(
                                    () => technologies.add(technology),
                                  );
                                },
                                backgroundColor:
                                    Theme.of(context).brightness ==
                                        Brightness.light
                                    ? const Color(0xFFF0F4FA)
                                    : Theme.of(context).cardColor,
                                side: BorderSide(
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.light
                                      ? const Color(0xFFD5DFEC)
                                      : const Color(0xFF263A5D),
                                ),
                                labelStyle: TextStyle(
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.light
                                      ? const Color(0xFF52627A)
                                      : const Color(0xFF93C5FD),
                                  fontSize: 11,
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ),
                if (technologies.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: technologies
                          .map(
                            (technology) => InputChip(
                              label: Text(technology),
                              onDeleted: () => setModalState(
                                () => technologies.remove(technology),
                              ),
                              backgroundColor:
                                  Theme.of(context).brightness ==
                                      Brightness.light
                                  ? const Color(0xFFF0F4FA)
                                  : const Color(0xFF17243B),
                              labelStyle: TextStyle(
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.light
                                    ? const Color(0xFF52627A)
                                    : const Color(0xFFBFDBFE),
                                fontSize: 12,
                              ),
                              deleteIconColor:
                                  Theme.of(context).brightness ==
                                      Brightness.light
                                  ? const Color(0xFF52627A)
                                  : const Color(0xFF93C5FD),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 350));
    nameController.dispose();
    descriptionController.dispose();
    technologyController.dispose();

    if (projectDraft != null &&
        (projectDraft['name'] as String).trim().isNotEmpty) {
      AppState.instance.addProject(
        name: projectDraft['name'] as String,
        description: projectDraft['description'] as String,
        technologies: (projectDraft['technologies'] as List).cast<String>(),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    AppState.instance.addListener(_onAppStateChanged);
  }

  void _onAppStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    AppState.instance.removeListener(_onAppStateChanged);
    super.dispose();
  }

  List<ProjectItem> get _sortedProjects {
    final capturedByProject = <String, List<CaptureItem>>{};
    for (final capture in AppState.instance.captures) {
      capturedByProject
          .putIfAbsent(capture.project.toUpperCase(), () => [])
          .add(capture);
    }

    final list = AppState.instance.projects.map((project) {
      final captures = capturedByProject[project.name.toUpperCase()] ?? [];
      final ideas = captures.where((item) => item.type == 'Idea').length;
      final improvements = captures
          .where((item) => item.type == 'Improvement')
          .length;
      final pending = captures.length - ideas - improvements;
      final completed = captures.where((item) => item.isCompleted).length;
      return ProjectItem(
        id: project.name,
        name: project.name,
        description: project.description,
        icon: Icons.folder_outlined,
        accentColor: const Color(0xFF6366F1),
        techBadges: project.technologies,
        ideasCount: ideas,
        improvementsCount: improvements,
        pendingCount: pending,
        progress: captures.isEmpty ? 0 : completed / captures.length,
        completedCount: completed,
        lastModified: captures.isEmpty
            ? project.createdAt
            : captures.first.createdAt,
      );
    }).toList();
    if (_selectedSort == 'Recientes') {
      list.sort((a, b) => b.lastModified.compareTo(a.lastModified));
    } else if (_selectedSort == 'Más activos') {
      list.sort((a, b) => b.totalItems.compareTo(a.totalItems));
    } else if (_selectedSort == 'Alfabético') {
      list.sort((a, b) => a.name.compareTo(b.name));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Luces de fondo (Glow Ambient Background)
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF6366F1).withValues(alpha: 0.14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.14),
                    blurRadius: 100,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: -80,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00F0FF).withValues(alpha: 0.08),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00F0FF).withValues(alpha: 0.08),
                    blurRadius: 90,
                  ),
                ],
              ),
            ),
          ),

          // Contenido Principal
          SafeArea(
            child: Column(
              children: [
                // 1. Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        onPressed: () =>
                            Navigator.of(context).pushReplacementNamed('/home'),
                        icon: const Icon(Icons.arrow_back_rounded),
                        color: const Color(0xFF8E9BAE),
                        tooltip: 'Volver al inicio',
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF6366F1),
                                    borderRadius: BorderRadius.circular(2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF6366F1,
                                        ).withValues(alpha: 0.8),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Proyectos',
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            const Padding(
                              padding: EdgeInsets.only(left: 14),
                              child: Text(
                                'Todo lo que estás construyendo.',
                                style: TextStyle(
                                  color: Color(0xFF8E9BAE),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Action Button (New Project)
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF6366F1,
                              ).withValues(alpha: 0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: _createProject,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 9,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.add_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Nuevo',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // 2. Control de Orden (Sort Selector)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Icon(
                        Icons.sort_rounded,
                        size: 16,
                        color: Color(0xFF64748B),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'SORT:',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: ['Recientes', 'Más activos', 'Alfabético']
                                .map((option) => _buildSortButton(option))
                                .toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 3. Lista de Proyectos (Cards Container)
                Expanded(
                  child: _sortedProjects.isEmpty
                      ? Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.folder_open_outlined,
                                  size: 56,
                                  color: Color(0xFF334155),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Aún no hay proyectos',
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Captura una idea, ábrela en Bandeja y conviértela en tu primer proyecto.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                          itemCount: _sortedProjects.length,
                          itemBuilder: (context, index) {
                            return _ProjectCard(
                              project: _sortedProjects[index],
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 2,
      backgroundColor: Theme.of(context).cardColor,
      selectedItemColor: const Color(0xFF6366F1),
      unselectedItemColor: const Color(0xFF64748B),
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        const routes = ['/home', '/inbox', '/projects', '/search'];
        if (index != 2) {
          Navigator.of(context).pushReplacementNamed(routes[index]);
        }
      },
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
    );
  }

  Widget _buildSortButton(String label) {
    final isSelected = _selectedSort == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _selectedSort = label),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? (Theme.of(context).brightness == Brightness.light
                      ? const Color(0xFF2563EB)
                      : const Color(0xFF1E2330))
                : (Theme.of(context).brightness == Brightness.light
                      ? const Color(0xFFEAF0F8)
                      : const Color(0xFF10141D)),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF6366F1)
                  : const Color(0xFF1A202C),
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : (Theme.of(context).brightness == Brightness.light
                        ? const Color(0xFF52627A)
                        : const Color(0xFF8E9BAE)),
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

/// Componente Tarjeta de Proyecto Individual
class _ProjectCard extends StatelessWidget {
  final ProjectItem project;

  const _ProjectCard({required this.project});

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final surface = isLight ? Colors.white : const Color(0xFF11141C);
    final border = isLight ? const Color(0xFFD8E2F0) : const Color(0xFF1D2433);
    final primary = isLight ? const Color(0xFF172033) : Colors.white;
    final secondary = isLight
        ? const Color(0xFF52627A)
        : const Color(0xFF8E9BAE);
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Borde superior brillante según color del proyecto
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 2,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      project.accentColor,
                      project.accentColor.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Fila 1: Logo, Título, Descripción y Menú
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Logo/Icono con efecto Neón suave
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: project.accentColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: project.accentColor.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          project.icon,
                          color: project.accentColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Título y Descripción
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              project.name,
                              style: TextStyle(
                                color: primary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.6,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              project.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: secondary,
                                fontSize: 12,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Menú Contextual
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            '/project-detail',
                            arguments: project.name,
                          );
                        },
                        borderRadius: BorderRadius.circular(6),
                        child: Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Icon(
                            Icons.more_vert_rounded,
                            color: Color(0xFF475569),
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Fila 2: Badges de Tecnologías
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: project.techBadges
                        .map(
                          (tech) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: isLight
                                  ? const Color(0xFFF0F4FA)
                                  : const Color(0xFF181D29),
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                color: const Color(0xFF262E3E),
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              tech,
                              style: TextStyle(
                                color: secondary,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),

                  const SizedBox(height: 14),

                  // Fila 3: Progress Bar
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'PROGRESO',
                            style: TextStyle(
                              color: secondary,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            '${(project.progress * 100).toInt()}%',
                            style: TextStyle(
                              color: project.accentColor,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: project.progress,
                          minHeight: 4,
                          backgroundColor: isLight
                              ? const Color(0xFFE2E8F0)
                              : const Color(0xFF181D29),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            project.accentColor,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Separador Sutil
                  Divider(color: border, height: 1, thickness: 1),

                  const SizedBox(height: 10),

                  // Fila 4: Métricas (Ideas, Improvements, Pending)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: _buildMetricItem(
                          isLight: isLight,
                          icon: Icons.lightbulb_outline_rounded,
                          count: project.ideasCount,
                          label: 'Ideas',
                          color: const Color(0xFF00F0FF),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: _buildMetricItem(
                          isLight: isLight,
                          icon: Icons.auto_awesome_outlined,
                          count: project.improvementsCount,
                          label: 'Mejoras',
                          color: const Color(0xFFA855F7),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: _buildMetricItem(
                          isLight: isLight,
                          icon: Icons.pending_actions_rounded,
                          count: project.pendingCount,
                          label: 'Pendientes',
                          color: const Color(0xFFFFB74D),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem({
    required bool isLight,
    required IconData icon,
    required int count,
    required String label,
    required Color color,
  }) {
    final countFormatted = count.toString().padLeft(2, '0');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: isLight ? const Color(0xFFF0F4FA) : const Color(0xFF0B0D12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isLight ? const Color(0xFFD8E2F0) : const Color(0xFF181D2A),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            countFormatted,
            style: TextStyle(
              color: isLight ? const Color(0xFF172033) : Colors.white,
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isLight
                    ? const Color(0xFF52627A)
                    : const Color(0xFF64748B),
                fontSize: 10.5,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Modelo de Datos para un Proyecto
class ProjectItem {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color accentColor;
  final List<String> techBadges;
  final int ideasCount;
  final int improvementsCount;
  final int pendingCount;
  final double progress;
  final int completedCount;
  final DateTime lastModified;

  ProjectItem({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.accentColor,
    required this.techBadges,
    required this.ideasCount,
    required this.improvementsCount,
    required this.pendingCount,
    required this.progress,
    required this.completedCount,
    required this.lastModified,
  });

  int get totalItems => ideasCount + improvementsCount + pendingCount;
}
