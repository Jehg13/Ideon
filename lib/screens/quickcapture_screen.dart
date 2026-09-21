import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_state.dart';
import '../widgets/ideon_modal.dart';

class QuickCaptureScreen extends StatefulWidget {
  const QuickCaptureScreen({super.key, this.initialType, this.initialProject});

  final String? initialType;
  final String? initialProject;

  @override
  State<QuickCaptureScreen> createState() => _QuickCaptureScreenState();
}

String _typeLabel(String type) {
  return const {
        'Improvement': 'Mejora',
        'Bug': 'Error',
        'Task': 'Tarea',
        'Note': 'Nota',
        'Idea': 'Idea',
      }[type] ??
      type;
}

class _QuickCaptureScreenState extends State<QuickCaptureScreen> {
  final TextEditingController _ideaController = TextEditingController(text: '');
  final FocusNode _focusNode = FocusNode();

  // Estados seleccionados (Opcionales)
  String _selectedType = 'Improvement';
  String _selectedProject = 'Unassigned';
  String _selectedPriority = 'Medium';
  bool _isSaved = false;
  final List<String> _tags = [];

  final List<String> _quickTypes = [
    'Idea',
    'Improvement',
    'Bug',
    'Task',
    'Note',
  ];

  @override
  void initState() {
    super.initState();
    _selectedType = normalizeCaptureType(AppState.instance.defaultType);
    _selectedProject = AppState.instance.defaultProject;
    if (widget.initialType != null &&
        _quickTypes.contains(normalizeCaptureType(widget.initialType!))) {
      _selectedType = normalizeCaptureType(widget.initialType!);
    }
    if (widget.initialProject != null && widget.initialProject!.isNotEmpty) {
      _selectedProject = widget.initialProject!;
    }
    // Auto-focus en el input para escritura inmediata
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _ideaController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSave() {
    final title = _ideaController.text.trim();
    if (title.isEmpty) return;

    AppState.instance.addCapture(
      title: title,
      type: _selectedType,
      project: _selectedProject,
      priority: _selectedPriority,
      tags: _tags,
    );

    setState(() {
      _isSaved = true;
    });

    // Retroalimentación háptica
    HapticFeedback.mediumImpact();

    // Simular guardado y retorno
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        _goBack(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
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
        child: Column(
          children: [
            // 1. HEADER
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 12.0,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => _goBack(context),
                    icon: Icon(
                      Icons.arrow_back_rounded,
                      color: Theme.of(context).colorScheme.onSurface,
                      size: 24,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Capturar',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Inter',
                        ),
                      ),
                      Text(
                        'Sácalo de tu cabeza.',
                        style: TextStyle(
                          color: Color(0xFF64748B), // Cool Gray
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 2. QUICK TYPE SELECTOR (Fila de acciones rápidas)
            SizedBox(
              height: 36,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _quickTypes.length,
                itemBuilder: (context, index) {
                  final type = _quickTypes[index];
                  final isSelected = type == _selectedType;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(_typeLabel(type)),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedType = type);
                        }
                      },
                      selectedColor: const Color(0xFF2563EB),
                      backgroundColor: Theme.of(context).cardColor,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : (isLight
                                  ? const Color(0xFF52627A)
                                  : const Color(0xFF94A3B8)),
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected
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

            // 3. MAIN INPUT (Protagonista de la pantalla)
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                decoration: BoxDecoration(
                  color: isLight ? Colors.white : const Color(0xFF111722),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: isLight
                        ? const Color(0xFFD8E2F0)
                        : const Color(0xFF26344D),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isLight
                          ? const Color(0x180F2747)
                          : Colors.black.withValues(alpha: 0.3),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.edit_note_rounded,
                            color: Color(0xFF2563EB),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Tu idea',
                          style: TextStyle(
                            color: isLight
                                ? const Color(0xFF172033)
                                : Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Escribe libremente',
                          style: TextStyle(
                            color: isLight
                                ? const Color(0xFF64748B)
                                : const Color(0xFF94A3B8),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Expanded(
                      child: TextField(
                        controller: _ideaController,
                        focusNode: _focusNode,
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        cursorColor: const Color(0xFF2563EB),
                        cursorWidth: 2,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Inter',
                          height: 1.45,
                        ),
                        decoration: InputDecoration(
                          hintText:
                              'Escribe tu idea aquí...\n\nPuedes agregar contexto, preguntas o próximos pasos.',
                          hintStyle: TextStyle(
                            color: isLight
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                            fontSize: 18,
                            height: 1.45,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 4. OPTIONAL ORGANIZATION (Controles opcionales no intrusivos)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildOptionChip(
                      label: 'Proyecto',
                      value: _selectedProject,
                      icon: Icons.folder_open_outlined,
                      color: const Color(0xFF818CF8),
                      onTap: _showProjectSelector,
                    ),
                    const SizedBox(width: 8),
                    _buildOptionChip(
                      label: 'Prioridad',
                      value: _priorityLabel(_selectedPriority),
                      icon: Icons.flag_outlined,
                      color: const Color(0xFF60A5FA),
                      onTap: _showPrioritySelector,
                    ),
                    const SizedBox(width: 8),
                    ActionChip(
                      onPressed: _showTagSelector,
                      avatar: Icon(
                        Icons.add,
                        size: 14,
                        color: isLight
                            ? const Color(0xFF52627A)
                            : const Color(0xFF94A3B8),
                      ),
                      label: Text(
                        _tags.isEmpty
                            ? 'Añadir etiqueta'
                            : '+${_tags.length} etiquetas',
                      ),
                      backgroundColor: Theme.of(context).cardColor,
                      labelStyle: TextStyle(
                        color: isLight
                            ? const Color(0xFF52627A)
                            : const Color(0xFF94A3B8),
                        fontSize: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isLight
                              ? const Color(0xFFD5DFEC)
                              : const Color(0xFF1E293B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 5. SAVE BUTTON / CAPTURED STATE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isSaved ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isSaved
                        ? const Color(0xFF059669)
                        : const Color(0xFF2563EB),
                    disabledBackgroundColor: const Color(0xFF059669),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: _isSaved ? 0 : 8,
                    shadowColor: const Color(0xFF2563EB).withValues(alpha: 0.5),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _isSaved
                        ? Row(
                            key: const ValueKey('saved'),
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Guardada',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            key: const ValueKey('save'),
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Guardar idea',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(
                                Icons.arrow_upward_rounded,
                                color: Colors.white,
                                size: 18,
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
    );
  }

  Widget _buildOptionChip({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.light
                ? const Color(0xFFD5DFEC)
                : const Color(0xFF1E293B),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Text(
              '$label: ',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
            ),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showProjectSelector() async {
    if (AppState.instance.projects.isEmpty) return;
    final selected = await showDialog<String>(
      context: context,
      builder: (context) => IdeonModal(
        icon: Icons.folder_open_outlined,
        eyebrow: 'Organizar',
        title: 'Elegir proyecto',
        actions: [
          ideonSecondaryButton(
            label: 'Cancelar',
            onPressed: () => Navigator.pop(context),
          ),
        ],
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...AppState.instance.projects.map(
              (project) => ChoiceChip(
                label: Text(project.name),
                selected: _selectedProject == project.name,
                onSelected: (_) => Navigator.pop(context, project.name),
                selectedColor: const Color(0xFF2563EB),
                backgroundColor: Theme.of(context).cardColor,
                labelStyle: TextStyle(
                  color: _selectedProject == project.name
                      ? Colors.white
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            ChoiceChip(
              label: Text('Sin asignar'),
              selected: _selectedProject == 'Unassigned',
              onSelected: (_) => Navigator.pop(context, 'Unassigned'),
              selectedColor: const Color(0xFF2563EB),
              backgroundColor: Theme.of(context).cardColor,
              labelStyle: TextStyle(
                color: _selectedProject == 'Unassigned'
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
    if (selected != null && mounted) {
      setState(() => _selectedProject = selected);
    }
  }

  Future<void> _showPrioritySelector() async {
    final selected = await showDialog<String>(
      context: context,
      builder: (context) => IdeonModal(
        icon: Icons.flag_outlined,
        eyebrow: 'Organizar',
        title: 'Elegir prioridad',
        actions: [
          ideonSecondaryButton(
            label: 'Cancelar',
            onPressed: () => Navigator.pop(context),
          ),
        ],
        child: Column(
          children: [
            _buildPriorityOption(
              context,
              value: 'Low',
              label: 'Baja',
              description: 'Para ideas que pueden esperar.',
              color: const Color(0xFF60A5FA),
            ),
            const SizedBox(height: 8),
            _buildPriorityOption(
              context,
              value: 'Medium',
              label: 'Media',
              description: 'Importante, pero no urgente.',
              color: const Color(0xFFFBBF24),
            ),
            const SizedBox(height: 8),
            _buildPriorityOption(
              context,
              value: 'High',
              label: 'Alta',
              description: 'Conviene atenderla pronto.',
              color: const Color(0xFFF97316),
            ),
            const SizedBox(height: 8),
            _buildPriorityOption(
              context,
              value: 'Urgent',
              label: 'Urgente',
              description: 'Requiere atención inmediata.',
              color: const Color(0xFFF43F5E),
            ),
          ],
        ),
      ),
    );
    if (selected != null && mounted) {
      setState(() => _selectedPriority = selected);
    }
  }

  Widget _buildPriorityOption(
    BuildContext context, {
    required String value,
    required String label,
    required String description,
    required Color color,
  }) {
    final selected = _selectedPriority == value;
    final isLight = Theme.of(context).brightness == Brightness.light;
    return InkWell(
      onTap: () => Navigator.pop(context, value),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: isLight ? 0.16 : 0.12)
              : (isLight ? const Color(0xFFF0F4FA) : const Color(0xFF0B111B)),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? color
                : (isLight ? const Color(0xFFD9E2F0) : const Color(0xFF243149)),
            width: selected ? 1.2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.flag_rounded, color: color, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: isLight ? const Color(0xFF172033) : Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    style: TextStyle(
                      color: isLight
                          ? const Color(0xFF52627A)
                          : const Color(0xFF94A3B8),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            if (selected) Icon(Icons.check_circle_rounded, color: color),
          ],
        ),
      ),
    );
  }

  String _priorityLabel(String priority) {
    return const {
          'Low': 'Baja',
          'Medium': 'Media',
          'High': 'Alta',
          'Urgent': 'Urgente',
        }[priority] ??
        priority;
  }

  void _goBack(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  Future<void> _showTagSelector() async {
    final controller = TextEditingController();
    final tag = await showDialog<String>(
      context: context,
      builder: (context) => IdeonModal(
        icon: Icons.sell_outlined,
        eyebrow: 'Organizar',
        title: 'Etiquetas',
        actions: [
          ideonSecondaryButton(
            label: 'Listo',
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          ideonPrimaryButton(
            label: 'Agregar',
            icon: Icons.add_rounded,
            onPressed: () => Navigator.pop(context, controller.text),
          ),
        ],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (AppState.instance.tags.isNotEmpty) ...[
              Text(
                'Usa una etiqueta existente',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.light
                      ? const Color(0xFF52627A)
                      : const Color(0xFF94A3B8),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AppState.instance.tags.map((existingTag) {
                  final selected = _tags.contains(existingTag);
                  return FilterChip(
                    label: Text(existingTag),
                    selected: selected,
                    onSelected: (_) => setState(() {
                      selected
                          ? _tags.remove(existingTag)
                          : _tags.add(existingTag);
                    }),
                    selectedColor: const Color(0xFF2563EB),
                    backgroundColor: Theme.of(context).cardColor,
                    labelStyle: TextStyle(
                      color: selected
                          ? Colors.white
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
            TextField(
              controller: controller,
              autofocus: AppState.instance.tags.isEmpty,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              decoration: ideonInputDecoration(
                label: 'Nueva etiqueta',
                icon: Icons.tag_rounded,
                hint: 'ej. urgente, investigación, lanzamiento',
              ),
              onSubmitted: (value) => Navigator.pop(context, value),
            ),
          ],
        ),
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.dispose();
    });
    if (tag != null && tag.trim().isNotEmpty && mounted) {
      setState(() => _tags.add(tag.trim()));
    }
  }
}
