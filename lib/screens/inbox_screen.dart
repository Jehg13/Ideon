import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_state.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  String _selectedFilter = 'Todas';

  final List<String> _filters = [
    'Todas',
    'Ideas',
    'Mejoras',
    'Errores',
    'Tareas',
    'Notas',
  ];

  final List<Map<String, dynamic>> _inboxItems = [];

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

  List<Map<String, dynamic>> get _allItems {
    final capturedItems = AppState.instance.captures.map((capture) {
      return <String, dynamic>{
        'id': capture.id,
        'title': capture.title,
        'type': capture.type,
        'project': capture.project,
        'date': 'Ahora',
        'icon': capture.icon,
        'iconColor': capture.iconColor,
        'captureId': capture.id,
      };
    });
    return [...capturedItems, ..._inboxItems];
  }

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

    final items = _allItems;
    final filteredItems = _selectedFilter == 'Todas'
        ? items
        : items
              .where(
                (item) =>
                    item['type'].toString().toLowerCase() ==
                    const {
                      'Ideas': 'idea',
                      'Mejoras': 'improvement',
                      'Errores': 'bug',
                      'Tareas': 'task',
                      'Notas': 'note',
                    }[_selectedFilter],
              )
              .toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // 1. HEADER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () =>
                        Navigator.of(context).pushReplacementNamed('/home'),
                    icon: Icon(Icons.arrow_back_rounded),
                    color: const Color(0xFF94A3B8),
                    tooltip: 'Volver al inicio',
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bandeja',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Inter',
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Cosas que esperan tu atención.',
                        style: TextStyle(
                          color: Color(0xFF94A3B8), // Cool Gray
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  // Badge del contador de items
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF1E293B)),
                    ),
                    child: Text(
                      '${items.length} items',
                      style: TextStyle(
                        color: Color(0xFF38BDF8),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'RobotoMono',
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 2. FILTERS (Chips Horizontales)
            SizedBox(
              height: 36,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _filters.length,
                itemBuilder: (context, index) {
                  final filter = _filters[index];
                  final isActive = filter == _selectedFilter;
                  final isLight =
                      Theme.of(context).brightness == Brightness.light;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: isActive,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedFilter = filter);
                        }
                      },
                      selectedColor: const Color(0xFF2563EB),
                      backgroundColor: Theme.of(context).cardColor,
                      labelStyle: TextStyle(
                        color: isActive
                            ? Colors.white
                            : (isLight
                                  ? const Color(0xFF52627A)
                                  : const Color(0xFF94A3B8)),
                        fontSize: 12,
                        fontWeight: isActive
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isActive
                              ? const Color(0xFF38BDF8)
                              : (isLight
                                    ? const Color(0xFFD5DFEC)
                                    : const Color(0xFF1E293B)),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // 3. INBOX LIST WITH SWIPE ACTIONS
            Expanded(
              child: filteredItems.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      itemCount: filteredItems.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        return _buildDismissibleItem(item);
                      },
                    ),
            ),
          ],
        ),
      ),

      // FLOATING ACTION BUTTON
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).pushNamed('/quick-capture');
        },
        backgroundColor: const Color(0xFF2563EB),
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: Icon(Icons.add_rounded, color: Colors.white, size: 20),
        label: Text(
          'Capturar',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 1,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      selectedItemColor: const Color(0xFF2563EB),
      unselectedItemColor: const Color(0xFF64748B),
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        const routes = ['/home', '/inbox', '/projects', '/search'];
        if (index != 1) {
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

  // WIDGET CON ACCIONES DE DESLIZAMIENTO (SWIPE ACTIONS)
  Widget _buildDismissibleItem(Map<String, dynamic> item) {
    return Dismissible(
      key: Key(item['id'].toString()),
      background: _buildSwipeBackground(
        alignment: Alignment.centerLeft,
        color: const Color(0xFF1E293B),
        icon: Icons.drive_file_move_outlined,
        label: 'Assign',
        padding: const EdgeInsets.only(left: 20),
      ),
      secondaryBackground: _buildSwipeBackground(
        alignment: Alignment.centerRight,
        color: const Color(0xFF881337),
        icon: Icons.delete_outline_rounded,
        label: 'Delete',
        padding: const EdgeInsets.only(right: 20),
      ),
      onDismissed: (direction) {
        final captureId = item['captureId'] as String?;
        if (captureId != null) {
          AppState.instance.removeCapture(captureId);
        }
        setState(() {
          _inboxItems.removeWhere((element) => element['id'] == item['id']);
        });
        HapticFeedback.lightImpact();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF1E293B)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(
          onTap: () {
            final capture = item['captureId'] == null
                ? null
                : AppState.instance.captures.firstWhere(
                    (entry) => entry.id == item['captureId'],
                  );
            Navigator.of(context).pushNamed('/idea-detail', arguments: capture);
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icono de Tipo
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF1E293B)),
                ),
                child: Icon(
                  item['icon'] as IconData,
                  size: 18,
                  color: item['iconColor'] as Color,
                ),
              ),
              const SizedBox(width: 14),

              // Contenido Principal
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title'] as String,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Inter',
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Metadata Row: Project | Type | Date
                    Row(
                      children: [
                        if (item['project'] != null) ...[
                          Text(
                            item['project'] as String,
                            style: TextStyle(
                              color: Color(0xFF818CF8), // Indigo
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            ' · ',
                            style: TextStyle(color: Color(0xFF475569)),
                          ),
                        ],
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item['type'] as String,
                            style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          item['date'] as String,
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 11,
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
      ),
    );
  }

  Widget _buildSwipeBackground({
    required Alignment alignment,
    required Color color,
    required IconData icon,
    required String label,
    required EdgeInsets padding,
  }) {
    return Container(
      alignment: alignment,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.onSurface, size: 20),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 48, color: Color(0xFF334155)),
          SizedBox(height: 12),
          Text(
            'Todo limpio',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'No hay ideas capturadas esperando ser procesadas.',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
          ),
        ],
      ),
    );
  }
}
