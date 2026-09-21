import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/app_database.dart';

class CaptureItem {
  CaptureItem({
    required this.title,
    required this.type,
    required this.project,
    required this.priority,
    required this.tags,
    String? id,
    DateTime? createdAt,
  }) : id = id ?? DateTime.now().microsecondsSinceEpoch.toString(),
       createdAt = createdAt ?? DateTime.now();

  final String id;
  String title;
  String type;
  String project;
  String priority;
  List<String> tags;
  final DateTime createdAt;
  bool isCompleted = false;

  IconData get icon {
    switch (type) {
      case 'Improvement':
        return Icons.tune_rounded;
      case 'Bug':
        return Icons.bug_report_outlined;
      case 'Task':
        return Icons.task_alt_rounded;
      case 'Note':
        return Icons.notes_rounded;
      default:
        return Icons.lightbulb_outline;
    }
  }

  Color get iconColor {
    switch (type) {
      case 'Improvement':
        return const Color(0xFF818CF8);
      case 'Bug':
        return const Color(0xFFF43F5E);
      case 'Task':
        return const Color(0xFF60A5FA);
      case 'Note':
        return const Color(0xFFA78BFA);
      default:
        return const Color(0xFF38BDF8);
    }
  }
}

String normalizeCaptureType(String type) {
  return const {
        'Idea': 'Idea',
        'idea': 'Idea',
        'Improvement': 'Improvement',
        'improvement': 'Improvement',
        'Mejora': 'Improvement',
        'mejora': 'Improvement',
        'Task': 'Task',
        'task': 'Task',
        'Tarea': 'Task',
        'tarea': 'Task',
        'Bug': 'Bug',
        'bug': 'Bug',
        'Error': 'Bug',
        'error': 'Bug',
        'Note': 'Note',
        'note': 'Note',
        'Nota': 'Note',
        'nota': 'Note',
      }[type] ??
      'Idea';
}

class ProjectRecord {
  ProjectRecord({
    required this.name,
    required this.description,
    required this.technologies,
    required this.createdAt,
  });

  final String name;
  final String description;
  final List<String> technologies;
  final DateTime createdAt;
}

class AppState extends ChangeNotifier {
  AppState._();

  static final AppState instance = AppState._();
  static const _quickCaptureEnabledKey = 'quick_capture_enabled';
  static const _themeIndexKey = 'theme_index';
  static const _defaultProjectKey = 'default_project';
  static const _defaultTypeKey = 'default_type';
  static const _appLockEnabledKey = 'app_lock_enabled';
  static const _biometricEnabledKey = 'biometric_enabled';
  static const _onboardingCompletedKey = 'onboarding_completed';
  static const _appPinKey = 'app_pin';
  static const _appPinConfiguredKey = 'app_pin_configured';

  final List<CaptureItem> _captures = [];
  final List<ProjectRecord> _projects = [];
  bool quickCaptureEnabled = true;
  int themeIndex = 0;
  String defaultProject = 'Sin asignar';
  String defaultType = 'Idea';
  bool appLockEnabled = false;
  bool biometricEnabled = false;
  bool onboardingCompleted = false;
  String appPin = '1234';
  bool appPinConfigured = false;
  bool skipNextLockAfterBiometric = false;

  Future<void> loadPreferences() async {
    await _loadDatabase();
    try {
      final preferences = await SharedPreferences.getInstance();
      quickCaptureEnabled =
          preferences.getBool(_quickCaptureEnabledKey) ?? quickCaptureEnabled;
      themeIndex = preferences.getInt(_themeIndexKey) ?? themeIndex;
      defaultProject =
          preferences.getString(_defaultProjectKey) ?? defaultProject;
      defaultType = normalizeCaptureType(
        preferences.getString(_defaultTypeKey) ?? defaultType,
      );
      appLockEnabled =
          preferences.getBool(_appLockEnabledKey) ?? appLockEnabled;
      biometricEnabled =
          preferences.getBool(_biometricEnabledKey) ?? biometricEnabled;
      onboardingCompleted =
          preferences.getBool(_onboardingCompletedKey) ?? onboardingCompleted;
      appPin = preferences.getString(_appPinKey) ?? appPin;
      appPinConfigured =
          preferences.getBool(_appPinConfiguredKey) ?? appPinConfigured;
      if (!appPinConfigured && (appLockEnabled || biometricEnabled)) {
        appLockEnabled = false;
        biometricEnabled = false;
        unawaited(_savePreferences());
      }
    } on MissingPluginException catch (error) {
      debugPrint('Preferencias no disponibles en esta ejecución: $error');
    }
  }

  Future<void> _loadDatabase() async {
    try {
      final database = AppDatabase.instance;
      final captureRows = await database.getCaptures();
      final projectRows = await database.getProjects();
      _captures
        ..clear()
        ..addAll(
          captureRows.map(
            (row) => CaptureItem(
              id: row['id'] as String,
              title: row['title'] as String,
              type: normalizeCaptureType(row['type'] as String),
              project: row['project'] as String,
              priority: row['priority'] as String,
              tags: (jsonDecode(row['tags'] as String) as List)
                  .whereType<String>()
                  .toList(),
              createdAt: DateTime.parse(row['created_at'] as String),
            )..isCompleted = row['is_completed'] == 1,
          ),
        );
      _projects
        ..clear()
        ..addAll(
          projectRows.map(
            (row) => ProjectRecord(
              name: row['name'] as String,
              description: row['description'] as String,
              technologies: (jsonDecode(row['technologies'] as String) as List)
                  .whereType<String>()
                  .toList(),
              createdAt: DateTime.parse(row['created_at'] as String),
            ),
          ),
        );
    } catch (error, stackTrace) {
      debugPrint('No se pudieron cargar los datos locales: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Map<String, Object?> _captureRow(CaptureItem capture) {
    return {
      'id': capture.id,
      'title': capture.title,
      'type': capture.type,
      'project': capture.project,
      'priority': capture.priority,
      'tags': jsonEncode(capture.tags),
      'created_at': capture.createdAt.toIso8601String(),
      'is_completed': capture.isCompleted ? 1 : 0,
    };
  }

  Map<String, Object?> _projectRow(ProjectRecord project) {
    return {
      'name': project.name,
      'description': project.description,
      'technologies': jsonEncode(project.technologies),
      'created_at': project.createdAt.toIso8601String(),
    };
  }

  void _persist(Future<void> operation, String action) {
    unawaited(
      operation.catchError((error, stackTrace) {
        debugPrint('No se pudo $action en el almacenamiento local: $error');
        debugPrintStack(stackTrace: stackTrace);
      }),
    );
  }

  List<CaptureItem> get captures => List.unmodifiable(_captures);
  List<ProjectRecord> get projects => List.unmodifiable(_projects);
  List<String> get tags {
    final values = <String>{};
    for (final capture in _captures) {
      values.addAll(capture.tags);
    }

    return values.toList()..sort();
  }

  String exportDataJson() {
    return const JsonEncoder.withIndent('  ').convert({
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'captures': _captures
          .map(
            (capture) => {
              'id': capture.id,
              'title': capture.title,
              'type': capture.type,
              'project': capture.project,
              'priority': capture.priority,
              'tags': capture.tags,
              'createdAt': capture.createdAt.toIso8601String(),
              'isCompleted': capture.isCompleted,
            },
          )
          .toList(),
      'projects': _projects
          .map(
            (project) => {
              'name': project.name,
              'description': project.description,
              'technologies': project.technologies,
              'createdAt': project.createdAt.toIso8601String(),
            },
          )
          .toList(),
    });
  }

  void importDataJson(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('El archivo no tiene un formato válido.');
    }
    final importedCaptures = decoded['captures'];
    final importedProjects = decoded['projects'];
    if (importedCaptures is! List || importedProjects is! List) {
      throw const FormatException('El respaldo está incompleto.');
    }

    final captures = importedCaptures.map((item) {
      if (item is! Map<String, dynamic> || item['title'] is! String) {
        throw const FormatException('Hay una captura inválida.');
      }
      final capture = CaptureItem(
        id: item['id'] as String?,
        title: item['title'] as String,
        type: normalizeCaptureType(item['type'] as String? ?? 'Idea'),
        project: item['project'] as String? ?? 'Unassigned',
        priority: item['priority'] as String? ?? 'Medium',
        tags: (item['tags'] as List? ?? const []).whereType<String>().toList(),
      );
      capture.isCompleted = item['isCompleted'] == true;
      return capture;
    }).toList();

    final projects = importedProjects.map((item) {
      if (item is! Map<String, dynamic> || item['name'] is! String) {
        throw const FormatException('Hay un proyecto inválido.');
      }
      return ProjectRecord(
        name: item['name'] as String,
        description: item['description'] as String? ?? '',
        technologies: (item['technologies'] as List? ?? const [])
            .whereType<String>()
            .toList(),
        createdAt:
            DateTime.tryParse(item['createdAt'] as String? ?? '') ??
            DateTime.now(),
      );
    }).toList();

    _captures
      ..clear()
      ..addAll(captures);
    _projects
      ..clear()
      ..addAll(projects);
    _persist(
      AppDatabase.instance.replaceAll(
        captures: _captures.map(_captureRow).toList(),
        projects: _projects.map(_projectRow).toList(),
      ),
      'guardar el respaldo importado',
    );
    notifyListeners();
  }

  void updatePreferences({
    bool? quickCaptureEnabled,
    int? themeIndex,
    String? defaultProject,
    String? defaultType,
    bool? appLockEnabled,
    bool? biometricEnabled,
    bool? onboardingCompleted,
    String? appPin,
  }) {
    if (quickCaptureEnabled != null) {
      this.quickCaptureEnabled = quickCaptureEnabled;
    }
    if (themeIndex != null) this.themeIndex = themeIndex;
    if (defaultProject != null) this.defaultProject = defaultProject;
    if (defaultType != null) {
      this.defaultType = normalizeCaptureType(defaultType);
    }
    if (appLockEnabled != null) this.appLockEnabled = appLockEnabled;
    if (biometricEnabled != null) this.biometricEnabled = biometricEnabled;
    if (onboardingCompleted != null) {
      this.onboardingCompleted = onboardingCompleted;
    }
    if (appPin != null && appPin.length == 4) this.appPin = appPin;
    unawaited(_savePreferences());
    notifyListeners();
  }

  Future<void> _savePreferences() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setBool(_quickCaptureEnabledKey, quickCaptureEnabled);
      await preferences.setInt(_themeIndexKey, themeIndex);
      await preferences.setString(_defaultProjectKey, defaultProject);
      await preferences.setString(_defaultTypeKey, defaultType);
      await preferences.setBool(_appLockEnabledKey, appLockEnabled);
      await preferences.setBool(_biometricEnabledKey, biometricEnabled);
      await preferences.setBool(_onboardingCompletedKey, onboardingCompleted);
      await preferences.setString(_appPinKey, appPin);
      await preferences.setBool(_appPinConfiguredKey, appPinConfigured);
    } on MissingPluginException catch (error) {
      debugPrint('Preferencias no disponibles en esta ejecución: $error');
    }
  }

  Future<void> setAppPin(String pin) async {
    if (!RegExp(r'^\d{4}$').hasMatch(pin)) {
      throw const FormatException('El código debe tener 4 dígitos.');
    }
    appPinConfigured = true;
    updatePreferences(appPin: pin, appLockEnabled: true);
  }

  void addCapture({
    required String title,
    required String type,
    String project = 'Unassigned',
    required String priority,
    List<String> tags = const [],
  }) {
    _captures.insert(
      0,
      CaptureItem(
        title: title,
        type: normalizeCaptureType(type),
        project: project,
        priority: priority,
        tags: List.unmodifiable(tags),
      ),
    );
    _persist(
      AppDatabase.instance.upsertCapture(_captureRow(_captures.first)),
      'guardar la captura',
    );
    notifyListeners();
  }

  void addProject({
    required String name,
    required String description,
    List<String> technologies = const [],
    CaptureItem? sourceIdea,
  }) {
    final normalizedName = name.trim();
    if (normalizedName.isEmpty ||
        _projects.any(
          (project) =>
              project.name.toLowerCase() == normalizedName.toLowerCase(),
        )) {
      return;
    }

    _projects.add(
      ProjectRecord(
        name: normalizedName,
        description: description.trim().isEmpty
            ? 'Proyecto creado desde una idea.'
            : description.trim(),
        technologies: List.unmodifiable(technologies),
        createdAt: DateTime.now(),
      ),
    );
    if (sourceIdea != null) {
      sourceIdea.project = normalizedName;
      _persist(
        AppDatabase.instance.upsertCapture(_captureRow(sourceIdea)),
        'actualizar la captura convertida',
      );
    }
    _persist(
      AppDatabase.instance.upsertProject(_projectRow(_projects.last)),
      'guardar el proyecto',
    );
    notifyListeners();
  }

  void removeCapture(String id) {
    _captures.removeWhere((capture) => capture.id == id);
    _persist(AppDatabase.instance.deleteCapture(id), 'eliminar la captura');
    notifyListeners();
  }

  void updateCapture({
    required String id,
    required String title,
    required String type,
    required String project,
    required String priority,
    required List<String> tags,
  }) {
    final index = _captures.indexWhere((capture) => capture.id == id);
    if (index == -1) return;
    final capture = _captures[index]
      ..title = title.trim()
      ..type = normalizeCaptureType(type)
      ..project = project
      ..priority = priority
      ..tags = List.unmodifiable(tags);
    _persist(
      AppDatabase.instance.upsertCapture(_captureRow(capture)),
      'actualizar la captura',
    );
    notifyListeners();
  }

  void toggleCaptureCompleted(String id) {
    final index = _captures.indexWhere((capture) => capture.id == id);
    if (index == -1) return;
    _captures[index].isCompleted = !_captures[index].isCompleted;
    _persist(
      AppDatabase.instance.upsertCapture(_captureRow(_captures[index])),
      'actualizar el estado de la captura',
    );
    notifyListeners();
  }

  int countForProject(String project) {
    return _captures.where((capture) => capture.project == project).length;
  }
}
