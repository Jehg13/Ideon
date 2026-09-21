import 'package:flutter/material.dart';

import '../app_state.dart';
import '../widgets/ideon_loading.dart';

/// Screen individual de Detalle de Proyecto para IDEON.
/// Puedes importarla y navegar hacia ella directamente con Navigator.push(...)
class IdeonProjectDetailScreen extends StatefulWidget {
  const IdeonProjectDetailScreen({super.key, this.projectName});

  final String? projectName;

  @override
  State<IdeonProjectDetailScreen> createState() =>
      _IdeonProjectDetailScreenState();
}

class _IdeonProjectDetailScreenState extends State<IdeonProjectDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    AppState.instance.addListener(_onAppStateChanged);
    _loadProject();
  }

  Future<void> _loadProject() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (mounted) setState(() => _isLoading = false);
  }

  void _onAppStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    AppState.instance.removeListener(_onAppStateChanged);
    _tabController.dispose();
    super.dispose();
  }

  // Modal para la acción rápida "+ Add"
  void _showAddModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFF334155),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Añadir al proyecto',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Color(0xFF64748B)),
                      onPressed: () => Navigator.pop(sheetContext),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildModalOption(
                  icon: Icons.lightbulb_outline_rounded,
                  label: 'Idea',
                  color: const Color(0xFF00F0FF),
                  onTap: () => _openCapture(context, sheetContext, 'Idea'),
                ),
                _buildModalOption(
                  icon: Icons.auto_awesome_outlined,
                  label: 'Mejora',
                  color: const Color(0xFFA855F7),
                  onTap: () =>
                      _openCapture(context, sheetContext, 'Improvement'),
                ),
                _buildModalOption(
                  icon: Icons.check_box_outlined,
                  label: 'Tarea',
                  color: const Color(0xFF6366F1),
                  onTap: () => _openCapture(context, sheetContext, 'Task'),
                ),
                _buildModalOption(
                  icon: Icons.bug_report_outlined,
                  label: 'Bug',
                  color: const Color(0xFFFF3366),
                  onTap: () => _openCapture(context, sheetContext, 'Bug'),
                ),
                _buildModalOption(
                  icon: Icons.sticky_note_2_outlined,
                  label: 'Nota',
                  color: const Color(0xFFFFB74D),
                  onTap: () => _openCapture(context, sheetContext, 'Note'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openCapture(
    BuildContext pageContext,
    BuildContext sheetContext,
    String type,
  ) {
    Navigator.pop(sheetContext);
    Navigator.of(pageContext).pushNamed(
      '/quick-capture',
      arguments: {'type': type, 'project': widget.projectName},
    );
  }

  Widget _buildModalOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        label,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: Icon(Icons.chevron_right_rounded, color: Color(0xFF334155)),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: IdeonLoading(label: 'Cargando proyecto...'));
    }

    final projects = AppState.instance.projects;
    final matchingProjects = projects.where(
      (item) => item.name == widget.projectName,
    );
    final project = matchingProjects.isEmpty ? null : matchingProjects.first;
    final projectName = project?.name ?? widget.projectName ?? 'Proyecto';
    final captures = AppState.instance.captures
        .where((item) => item.project == projectName)
        .toList();
    final ideas = captures.where((item) => item.type == 'Idea').length;
    final improvements = captures
        .where((item) => item.type == 'Improvement')
        .length;
    final pending = captures.where((item) => item.type == 'Task').length;
    final completed = captures.where((item) => item.isCompleted).length;
    final total = captures.length;
    final progress = total == 0 ? 0.0 : completed / total;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddModal(context),
        backgroundColor: const Color(0xFF6366F1),
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        icon: Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          'Añadir',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 14,
            letterSpacing: 0.3,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Luces/Glows de fondo estilo Dark Dashboard
          Positioned(
            top: -100,
            left: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF6366F1).withValues(alpha: 0.12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.12),
                    blurRadius: 140,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 200,
            right: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00F0FF).withValues(alpha: 0.08),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00F0FF).withValues(alpha: 0.08),
                    blurRadius: 120,
                  ),
                ],
              ),
            ),
          ),

          // Contenido Principal
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. HEADER SECTION
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Botón Back
                      InkWell(
                        onTap: () {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          } else {
                            Navigator.of(context).pushReplacementNamed('/home');
                          }
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 6,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
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
                      const SizedBox(height: 12),

                      // Título del Proyecto
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFF6366F1).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              Icons.grid_view_rounded,
                              color: Color(0xFF6366F1),
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  projectName,
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  project?.description ??
                                      'Organiza tus ideas y conviértelas en trabajo.',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Color(0xFF94A3B8),
                                    fontSize: 12.5,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      if (project?.technologies.isNotEmpty ?? false) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            Text(
                              'Tecnologías:',
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            ...project!.technologies.map(_buildTechBadge),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // 2. PROJECT OVERVIEW METRICS (Números Grandes)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _buildMetricCard(
                        '$ideas',
                        'Ideas',
                        const Color(0xFF00F0FF),
                      ),
                      const SizedBox(width: 8),
                      _buildMetricCard(
                        '$improvements',
                        'Mejoras',
                        const Color(0xFFA855F7),
                      ),
                      const SizedBox(width: 8),
                      _buildMetricCard(
                        '$pending',
                        'Pendientes',
                        const Color(0xFFFFB74D),
                      ),
                      const SizedBox(width: 8),
                      _buildMetricCard(
                        '$completed',
                        'Completadas',
                        const Color(0xFF10B981),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 3. PROGRESS INDICATOR
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF1E2638),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Organización del proyecto',
                              style: TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${(progress * 100).round()}%',
                              style: TextStyle(
                                color: Color(0xFF6366F1),
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 6,
                            backgroundColor: Color(0xFF1E2330),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF6366F1),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // 4. TABS (Overview, Ideas, Improvements, Tasks, Bugs)
                Container(
                  height: 48,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.white
                        : const Color(0xFF0F141F),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF1D293D)),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: false,
                    labelPadding: EdgeInsets.zero,
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    indicator: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.light
                          ? const Color(0xFF2563EB)
                          : const Color(0xFF29365A),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFF7584FF),
                        width: 0.8,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x332F5BFF),
                          blurRadius: 10,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor:
                        Theme.of(context).brightness == Brightness.light
                        ? const Color(0xFF52627A)
                        : const Color(0xFF64748B),
                    labelStyle: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                    tabs: const [
                      Tab(text: 'Resumen'),
                      Tab(text: 'Ideas'),
                      Tab(text: 'Mejoras'),
                      Tab(text: 'Tareas'),
                      Tab(text: 'Errores'),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // 5. VISTAS DE CADA TAB (OVERVIEW RECENT ACTIVITY)
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ListView(
                          physics: const BouncingScrollPhysics(),
                          children: [
                            _buildActivityHeader(captures.length),
                            const SizedBox(height: 12),
                            if (captures.isEmpty)
                              _buildEmptyActivity(context)
                            else
                              ...captures.map(
                                (capture) => _buildActivityItem(capture),
                              ),
                            const SizedBox(height: 80),
                          ],
                        ),
                      ),
                      _buildFilteredTab(captures, 'Idea'),
                      _buildFilteredTab(captures, 'Improvement'),
                      _buildFilteredTab(captures, 'Task'),
                      _buildFilteredTab(captures, 'Bug'),
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

  // Métricas con números destacados
  Widget _buildMetricCard(String value, String label, Color accentColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF1E2638), width: 1),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
                shadows: [
                  Shadow(color: accentColor.withValues(alpha: 0.5), blurRadius: 8),
                ],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityHeader(int count) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: const Color(0xFF17243B),
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: const Color(0xFF263A5D)),
          ),
          child: Icon(Icons.bolt_rounded, color: Color(0xFF60A5FA), size: 17),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Actividad reciente',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Últimos movimientos del proyecto',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFF151E31),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              color: Color(0xFF93C5FD),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyActivity(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
      decoration: BoxDecoration(
        color: isLight ? Colors.white : const Color(0xFF101621),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isLight ? const Color(0xFFD8E2F0) : const Color(0xFF202C42),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: isLight
                  ? const Color(0xFFE8F0FF)
                  : const Color(0xFF17243B),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              Icons.inbox_outlined,
              color: const Color(0xFF60A5FA),
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Este proyecto está listo para empezar',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Añade una idea, mejora o tarea y comienza a darle forma.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF71809A),
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: () => _showAddModal(context),
            icon: Icon(Icons.add_rounded, size: 18),
            label: Text('Añadir primer elemento'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Fila de actividad reciente
  Widget _buildActivityItem(CaptureItem capture) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF1E2638), width: 0.8),
      ),
      child: Row(
        children: [
          Icon(
            capture.isCompleted
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            color: capture.isCompleted
                ? const Color(0xFF10B981)
                : const Color(0xFF64748B),
            size: 21,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              capture.title,
              style: TextStyle(
                color: capture.isCompleted
                    ? const Color(0xFF64748B)
                    : Theme.of(context).colorScheme.onSurface,
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                decoration: capture.isCompleted
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
          ),
          Text(
            _relativeDate(capture.createdAt),
            style: TextStyle(color: Color(0xFF475569), fontSize: 11),
          ),
          const SizedBox(width: 6),
          IconButton(
            tooltip: capture.isCompleted
                ? 'Marcar como pendiente'
                : 'Marcar como completada',
            onPressed: () =>
                AppState.instance.toggleCaptureCompleted(capture.id),
            icon: Icon(
              capture.isCompleted ? Icons.undo_rounded : Icons.check_rounded,
              color: const Color(0xFF60A5FA),
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  // Badges tecnológicos
  Widget _buildTechBadge(String label) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isLight ? const Color(0xFFE8EEF8) : const Color(0xFF1E2330),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isLight ? const Color(0xFFD1DCEB) : const Color(0xFF2A3142),
          width: 0.8,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isLight ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
          fontSize: 10.5,
          fontWeight: FontWeight.w500,
          fontFamily: 'monospace',
        ),
      ),
    );
  }

  Widget _buildFilteredTab(List<CaptureItem> captures, String type) {
    final items = captures.where((capture) => capture.type == type).toList();
    if (items.isEmpty) {
      return Center(
        child: Text(
          'Aún no hay ${_displayType(type).toLowerCase()} aquí.',
          style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: items.map((capture) => _buildActivityItem(capture)).toList(),
    );
  }

  String _displayType(String type) {
    return const {
          'Idea': 'Idea',
          'Improvement': 'Mejora',
          'Task': 'Tarea',
          'Bug': 'Error',
          'Note': 'Nota',
        }[type] ??
        type;
  }

  String _relativeDate(DateTime date) {
    final difference = DateTime.now().difference(date);
    if (difference.inMinutes < 1) return 'Ahora';
    if (difference.inHours < 1) return 'Hace ${difference.inMinutes} min';
    if (difference.inDays < 1) return 'Hace ${difference.inHours} h';
    return 'Hace ${difference.inDays} d';
  }
}
