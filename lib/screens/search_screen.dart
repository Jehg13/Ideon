import 'package:flutter/material.dart';

import '../app_state.dart';

/// Screen individual de Búsqueda Global para IDEON.
/// Diseñada con estilo Dark Premium, input destacado ("Search-first"),
/// búsquedas recientes y resultados instantáneos agrupados por categoría.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  String _query = '';
  String _activeType = 'Todos';
  String _activeProject = 'Todos';
  String _activeTag = 'Todas';

  // Búsquedas recientes
  final List<String> _recentSearches = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _query = _searchController.text.trim();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // Modal para la hoja de filtros avanzada
  void _showFilterModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (sheetContext) {
        var selectedProject = _activeProject;
        var selectedType = _activeType;
        var selectedTag = _activeTag;

        return StatefulBuilder(
          builder: (context, setSheetState) => SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 48),
                      Text(
                        'Filtros',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Color(0xFF64748B)),
                        onPressed: () => Navigator.pop(sheetContext),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildFilterCategory(
                    'Proyecto',
                    [
                      'Todos',
                      ...AppState.instance.projects.map((item) => item.name),
                    ],
                    selectedProject,
                    (value) => setSheetState(() => selectedProject = value),
                  ),
                  const SizedBox(height: 12),
                  _buildFilterCategory(
                    'Tipo',
                    const ['Todos', 'Idea', 'Mejora', 'Tarea', 'Error', 'Nota'],
                    selectedType,
                    (value) => setSheetState(() => selectedType = value),
                  ),
                  const SizedBox(height: 12),
                  _buildFilterCategory(
                    'Etiqueta',
                    ['Todas', ...AppState.instance.tags],
                    selectedTag,
                    (value) => setSheetState(() => selectedTag = value),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _activeProject = selectedProject;
                          _activeType = selectedType;
                          _activeTag = selectedTag;
                        });
                        Navigator.pop(sheetContext);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Aplicar filtros',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterCategory(
    String title,
    List<String> options,
    String selected,
    ValueChanged<String> onSelected,
  ) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Color(0xFF64748B),
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          children: options.map((opt) {
            return ChoiceChip(
              label: Text(
                opt,
                style: TextStyle(
                  fontSize: 11,
                  color: selected == opt
                      ? Colors.white
                      : (isLight ? const Color(0xFF172033) : Colors.white),
                ),
              ),
              selected: selected == opt,
              onSelected: (_) => onSelected(opt),
              backgroundColor: Theme.of(context).cardColor,
              selectedColor: const Color(0xFF2563EB),
              side: BorderSide(
                color: isLight
                    ? const Color(0xFFD5DFEC)
                    : const Color(0xFF1E2638),
                width: 0.8,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasQuery = _query.isNotEmpty;
    final bool hasActiveFilters =
        _activeType != 'Todos' ||
        _activeProject != 'Todos' ||
        _activeTag != 'Todas';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Resplandor posterior (Glow azul eléctrico / índigo)
          Positioned(
            top: -80,
            left: -60,
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

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. HEADER & SEARCH INPUT
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Buscar',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                          // Botón Filter
                          OutlinedButton.icon(
                            onPressed: () => _showFilterModal(context),
                            icon: Icon(
                              Icons.tune_rounded,
                              size: 16,
                              color: Color(0xFF00F0FF),
                            ),
                            label: Text(
                              'Filtrar',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Theme.of(context).cardColor,
                              side: const BorderSide(
                                color: Color(0xFF1E2638),
                                width: 1,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Input Grande de Búsqueda (Search-First)
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _focusNode.hasFocus
                                ? const Color(0xFF6366F1)
                                : const Color(0xFF1E2638),
                            width: 1.2,
                          ),
                          boxShadow: [
                            if (_focusNode.hasFocus)
                              BoxShadow(
                                color: const Color(0xFF6366F1).withValues(alpha: 0.2),
                                blurRadius: 12,
                              ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          focusNode: _focusNode,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Busca ideas, proyectos y mejoras...',
                            hintStyle: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 14,
                            ),
                            prefixIcon: Icon(
                              Icons.search_rounded,
                              color: Color(0xFF00F0FF),
                              size: 22,
                            ),
                            suffixIcon: hasQuery
                                ? IconButton(
                                    icon: Icon(
                                      Icons.close_rounded,
                                      color: Color(0xFF64748B),
                                      size: 18,
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 2. MAIN CONTENT (Recent Searches VS Grouped Results)
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: hasQuery || hasActiveFilters
                        ? _buildSearchResults()
                        : _buildRecentSearches(),
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
      currentIndex: 3,
      backgroundColor: Theme.of(context).cardColor,
      selectedItemColor: const Color(0xFF00F0FF),
      unselectedItemColor: const Color(0xFF64748B),
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        const routes = ['/home', '/inbox', '/projects', '/search'];
        if (index != 3) {
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

  // Vista de Búsquedas Recientes
  Widget _buildRecentSearches() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      children: [
        Text(
          'BÚSQUEDAS RECIENTES',
          style: TextStyle(
            color: Color(0xFF64748B),
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _recentSearches.map((term) {
            return InkWell(
              onTap: () {
                _searchController.text = term;
                _searchController.selection = TextSelection.fromPosition(
                  TextPosition(offset: term.length),
                );
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.light
                        ? const Color(0xFFD9E2F0)
                        : const Color(0xFF1E2638),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.history_rounded,
                      color: Color(0xFF64748B),
                      size: 14,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      term,
                      style: TextStyle(
                        color: Color(0xFFCBD5E1),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Vista de Resultados Agrupados al buscar
  Widget _buildSearchResults() {
    final captures = AppState.instance.captures.where((capture) {
      final query = _query.toLowerCase();
      final matchesQuery =
          query.isEmpty ||
          capture.title.toLowerCase().contains(query) ||
          capture.tags.any((tag) => tag.toLowerCase().contains(query));
      final matchesType =
          _activeType == 'Todos' ||
          _displayType(normalizeCaptureType(capture.type)) == _activeType;
      final matchesProject =
          _activeProject == 'Todos' || capture.project == _activeProject;
      final matchesTag =
          _activeTag == 'Todas' || capture.tags.contains(_activeTag);
      return matchesQuery && matchesType && matchesProject && matchesTag;
    }).toList();
    final projects = AppState.instance.projects.where((project) {
      final query = _query.toLowerCase();
      final matchesQuery =
          query.isEmpty ||
          project.name.toLowerCase().contains(query) ||
          project.description.toLowerCase().contains(query);
      final matchesProject =
          _activeProject == 'Todos' || project.name == _activeProject;
      final matchesTag =
          _activeTag == 'Todas' || project.technologies.contains(_activeTag);
      final matchesType = _activeType == 'Todos';
      return matchesQuery && matchesProject && matchesTag && matchesType;
    }).toList();

    if (projects.isEmpty && captures.isEmpty) {
      return const Center(
        child: Text(
          'No hay resultados todavía. Crea una idea para comenzar.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
        ),
      );
    }

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      children: [
        if (projects.isNotEmpty) ...[
          _buildSectionHeader('PROYECTOS'),
          ...projects.map(
            (project) => _buildResultCard(
              icon: Icons.folder_outlined,
              iconColor: const Color(0xFF6366F1),
              title: project.name,
              subtitle: project.description,
              badge: 'Proyecto',
              badgeColor: const Color(0xFF6366F1),
            ),
          ),
        ],
        if (captures.isNotEmpty) ...[
          _buildSectionHeader('CAPTURAS'),
          ...captures.map(
            (capture) => _buildResultCard(
              icon: capture.icon,
              iconColor: capture.iconColor,
              title: capture.title,
              subtitle:
                  '${capture.project} · ${_displayType(capture.type)} · ${capture.tags.join(', ')}',
              badge: _displayType(capture.type),
              badgeColor: capture.iconColor,
            ),
          ),
        ],

        const SizedBox(height: 24),
      ],
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

  // Encabezado de Categoría de Resultados
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        title,
        style: TextStyle(
          color: Color(0xFF64748B),
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  // Tarjeta de Resultado Individual
  Widget _buildResultCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String badge,
    required Color badgeColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E2638), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.of(context).pushNamed('/idea-detail');
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Icono
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: iconColor, size: 18),
                ),
                const SizedBox(width: 12),

                // Título y Subtítulo
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Color(0xFF8E9BAE),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Badge Tipo
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: badgeColor.withValues(alpha: 0.3),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      color: badgeColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
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
