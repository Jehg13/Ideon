import 'package:flutter/material.dart';

import '../app_state.dart';
import '../widgets/ideon_modal.dart';

/// Screen individual de Detalle de Idea para IDEON.
/// Diseñada con estilo Dark Premium, enfoque minimalista y foco en el contenido.
class IdeaDetailScreen extends StatelessWidget {
  const IdeaDetailScreen({super.key, this.capture});

  final CaptureItem? capture;

  Future<void> _deleteCapture(BuildContext context) async {
    final item = capture;
    if (item == null) return;

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar idea'),
        content: const Text(
          'Esta acción eliminará la idea de tu bandeja. ¿Quieres continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      AppState.instance.removeCapture(item.id);
      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed('/inbox');
      }
    }
  }

  Future<void> _convertToProject(BuildContext context) async {
    final nameController = TextEditingController(
      text: capture == null ? '' : capture!.title.split(' ').take(3).join(' '),
    );
    final descriptionController = TextEditingController(
      text: capture?.title ?? '',
    );

    final shouldCreate = await showDialog<bool>(
      context: context,
      builder: (context) => IdeonModal(
        icon: Icons.auto_awesome_rounded,
        eyebrow: 'Idea a proyecto',
        title: 'Construye sobre esta idea',
        actions: [
          ideonSecondaryButton(
            label: 'Ahora no',
            onPressed: () => Navigator.pop(context, false),
          ),
          const SizedBox(width: 8),
          ideonPrimaryButton(
            label: 'Crear proyecto',
            icon: Icons.rocket_launch_outlined,
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              decoration: ideonInputDecoration(
                label: 'Nombre del proyecto',
                icon: Icons.folder_outlined,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descriptionController,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              maxLines: 3,
              decoration: ideonInputDecoration(
                label: 'Descripción',
                icon: Icons.notes_outlined,
              ),
            ),
          ],
        ),
      ),
    );

    final projectName = nameController.text.trim();
    final projectDescription = descriptionController.text.trim();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      nameController.dispose();
      descriptionController.dispose();
    });
    if (shouldCreate == true && projectName.isNotEmpty) {
      AppState.instance.addProject(
        name: projectName,
        description: projectDescription,
        technologies: capture?.tags ?? const [],
        sourceIdea: capture,
      );
      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed('/projects');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final primaryText = isLight ? const Color(0xFF172033) : Colors.white;
    final panelBorder = isLight
        ? const Color(0xFFD8E2F0)
        : const Color(0xFF1E2638);
    final item = capture;
    final title = item?.title ?? 'Idea sin título';
    final type = _displayType(item?.type ?? 'Idea');
    final project = item?.project == null || item!.project == 'Unassigned'
        ? 'Sin asignar'
        : item.project;
    final priority = _displayPriority(item?.priority ?? 'Medium');
    final tags = item?.tags ?? const <String>[];
    final created = item == null
        ? 'Sin fecha'
        : '${item.createdAt.day.toString().padLeft(2, '0')}/'
              '${item.createdAt.month.toString().padLeft(2, '0')}/'
              '${item.createdAt.year}';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Sutil resplandor de fondo (Ambient Glow)
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF6366F1).withValues(alpha: 0.08),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.08),
                    blurRadius: 120,
                  ),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // 1. HEADER
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Botón ← Back
                      InkWell(
                        onTap: () {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          } else {
                            Navigator.of(context).pushReplacementNamed('/home');
                          }
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 6,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Color(0xFF94A3B8),
                                size: 16,
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
                      // Tag de Tipo y Menú Contextual
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00F0FF).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFF00F0FF).withValues(alpha: 0.3),
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              type,
                              style: TextStyle(
                                color: Color(0xFF00F0FF),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: Icon(
                              Icons.more_horiz_rounded,
                              color: Color(0xFF64748B),
                              size: 22,
                            ),
                            onPressed: () => _convertToProject(context),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 2. MAIN CONTENT SCROLLABLE AREA
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),

                        // Icono + Título Principal
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: panelBorder,
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                Icons.lightbulb_outline_rounded,
                                color: const Color(0xFFF59E0B),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                title,
                                style: TextStyle(
                                  color: primaryText,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  height: 1.25,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 28),

                        // METADATA GRID (Project, Type, Priority, Status, Created)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: panelBorder, width: 1),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  _buildMetaCell(
                                    isLight: isLight,
                                    'Proyecto',
                                    project,
                                    valueColor: const Color(0xFFFF3366),
                                  ),
                                  _buildMetaCell(
                                    'Tipo',
                                    type,
                                    isLight: isLight,
                                  ),
                                ],
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Divider(color: panelBorder, height: 1),
                              ),
                              Row(
                                children: [
                                  _buildMetaCell(
                                    isLight: isLight,
                                    'Prioridad',
                                    priority,
                                    valueColor: const Color(0xFFFFB74D),
                                  ),
                                  _buildMetaCell(
                                    isLight: isLight,
                                    'Estado',
                                    type,
                                    valueColor: const Color(0xFF00F0FF),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Divider(
                                  color: Color(0xFF1E2638),
                                  height: 1,
                                ),
                              ),
                              Row(
                                children: [_buildMetaCell('Creada', created)],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // DESCRIPTION SECTION
                        Text(
                          'DESCRIPCIÓN',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: isLight
                                ? const Color(0xFFF0F4FA)
                                : const Color(0xFF0E121B),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Theme.of(context).cardColor,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            title,
                            style: TextStyle(
                              color: primaryText,
                              fontSize: 15,
                              height: 1.55,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),

                        // TAGS SECTION
                        Text(
                          'ETIQUETAS',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (tags.isEmpty)
                              Text(
                                'Sin etiquetas',
                                style: TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 13,
                                ),
                              )
                            else
                              ...tags.map((tag) => _buildTag(tag, isLight)),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // SECONDARY ACTIONS GRID
                        Row(
                          children: [
                            Expanded(
                              child: _buildSecondaryActionButton(
                                'Editar',
                                Icons.edit_outlined,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildSecondaryActionButton(
                                'Eliminar',
                                Icons.delete_outline_rounded,
                                onPressed: () => _deleteCapture(context),
                                isDestructive: true,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // 3. BOTTOM CONVERSION CTA
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
                  decoration: BoxDecoration(
                    color: isLight ? Colors.white : const Color(0xFF0D1017),
                    border: Border(
                      top: BorderSide(
                        color: isLight
                            ? const Color(0xFFD8E2F0)
                            : const Color(0xFF1A202C),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Subtítulo con flujo de conversión
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'IDEA',
                            style: TextStyle(
                              color: Color(0xFF00F0FF),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: Color(0xFF64748B),
                            size: 12,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'PROYECTO',
                            style: TextStyle(
                              color: Color(0xFF6366F1),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Botón Principal
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () => _convertToProject(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6366F1),
                            elevation: 4,
                            shadowColor: const Color(
                              0xFF6366F1,
                            ).withValues(alpha: 0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Convertir en proyecto',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(
                                Icons.check_circle_outline_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
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

  String _displayPriority(String priority) {
    return const {
          'Low': 'Baja',
          'Medium': 'Media',
          'High': 'Alta',
          'Urgent': 'Urgente',
        }[priority] ??
        priority;
  }

  // Celda para la cuadrícula de metadatos
  Widget _buildMetaCell(
    String label,
    String value, {
    bool isLight = false,
    Color? valueColor,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color:
                  valueColor ??
                  (isLight ? const Color(0xFF172033) : Colors.white),
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // Tag Chip
  Widget _buildTag(String label, bool isLight) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isLight ? const Color(0xFFF0F4FA) : const Color(0xFF101521),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isLight ? const Color(0xFFD8E2F0) : const Color(0xFF1E2638),
          width: 0.8,
        ),
      ),
      child: Text(
        '#$label',
        style: TextStyle(
          color: isLight ? const Color(0xFF52627A) : const Color(0xFF94A3B8),
          fontSize: 11.5,
          fontWeight: FontWeight.w500,
          fontFamily: 'monospace',
        ),
      ),
    );
  }

  // Botón Secundario de Acción
  Widget _buildSecondaryActionButton(
    String label,
    IconData icon, {
    VoidCallback? onPressed,
    bool isDestructive = false,
  }) {
    return Builder(
      builder: (context) {
        final isLight = Theme.of(context).brightness == Brightness.light;
        return OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 11),
            side: BorderSide(
              color: isLight
                  ? const Color(0xFFD5DFEC)
                  : const Color(0xFF1E2638),
              width: 1,
            ),
            backgroundColor: isLight ? Colors.white : const Color(0xFF101521),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isDestructive
                    ? const Color(0xFFDC2626)
                    : const Color(0xFF94A3B8),
                size: 15,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isDestructive
                      ? const Color(0xFFDC2626)
                      : isLight
                      ? const Color(0xFF52627A)
                      : const Color(0xFFCBD5E1),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
