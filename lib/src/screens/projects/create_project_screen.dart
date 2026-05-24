import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/app_models.dart';
import '../../state/app_controller.dart';
import '../../widgets/scene_link_widgets.dart';

class CreateProjectScreen extends StatefulWidget {
  const CreateProjectScreen({super.key, this.existingProject});

  final CreativeProject? existingProject;

  @override
  State<CreateProjectScreen> createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends State<CreateProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _categoryController;
  late final TextEditingController _rolesController;
  late final TextEditingController _locationController;
  late final TextEditingController _budgetController;
  late final TextEditingController _deadlineController;
  ProjectStatus _status = ProjectStatus.open;
  bool _saving = false;

  Future<void> _deleteProject() async {
    final project = widget.existingProject;
    if (project == null) {
      return;
    }

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete project?'),
        content: Text('This will permanently remove "${project.title}".'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) {
      return;
    }

    setState(() => _saving = true);
    final controller = context.read<AppController>();
    try {
      await controller.deleteProject(project.projectId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Project deleted'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.go('/projects');
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    final project = widget.existingProject;
    _titleController = TextEditingController(text: project?.title ?? '');
    _descriptionController = TextEditingController(text: project?.description ?? '');
    _categoryController = TextEditingController(text: project?.category ?? '');
    _rolesController = TextEditingController(text: project?.requiredRoles.join(', ') ?? '');
    _locationController = TextEditingController(text: project?.location ?? '');
    _budgetController =
        TextEditingController(text: project?.budget?.toStringAsFixed(0) ?? '');
    _deadlineController = TextEditingController(
      text: project == null
          ? ''
          : project.deadline.toIso8601String().substring(0, 10),
    );
    _status = project?.status ?? ProjectStatus.open;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _rolesController.dispose();
    _locationController.dispose();
    _budgetController.dispose();
    _deadlineController.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final initialDate =
        DateTime.tryParse(_deadlineController.text) ??
        DateTime.now().add(const Duration(days: 14));
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      initialDate: initialDate,
    );
    if (picked != null) {
      _deadlineController.text = picked.toIso8601String().substring(0, 10);
      setState(() {});
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final controller = context.read<AppController>();
    final user = controller.currentUser;
    if (user == null) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You must be signed in to create a project.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    final project = CreativeProject(
      projectId: widget.existingProject?.projectId ??
          'p_${DateTime.now().millisecondsSinceEpoch}',
      creatorId: widget.existingProject?.creatorId ?? user.uid,
      creatorName: widget.existingProject?.creatorName ?? user.name,
      creatorRole: widget.existingProject?.creatorRole ?? user.role,
      creatorImage: widget.existingProject?.creatorImage ?? user.profileImage,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _categoryController.text.trim(),
      requiredRoles: _rolesController.text
          .split(',')
          .map((v) => v.trim())
          .where((v) => v.isNotEmpty)
          .toList(),
      deadline: DateTime.tryParse(_deadlineController.text.trim()) ??
          DateTime.now().add(const Duration(days: 14)),
      status: _status,
      applicants: widget.existingProject?.applicants ?? const [],
      blindApplications: widget.existingProject?.blindApplications ?? const [],
      location: _locationController.text.trim(),
      budget: _parseBudget(_budgetController.text),
      createdAt: widget.existingProject?.createdAt ?? DateTime.now(),
      savedByIds: widget.existingProject?.savedByIds ?? const [],
    );

    String? error;
    try {
      if (widget.existingProject == null) {
        error = await controller.createProject(project);
      } else {
        error = await controller.updateProject(project);
      }
    } catch (e) {
      error = e.toString();
    }
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          error != null
              ? error
              : widget.existingProject != null
                  ? 'Project updated'
                  : 'Project created',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
    if (error != null && !error.contains('Saved locally')) return;
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/app');
    }
  }

  double? _parseBudget(String raw) {
    final cleaned = raw.replaceAll(RegExp(r'[^0-9.]'), '');
    if (cleaned.isEmpty) return null;
    return double.tryParse(cleaned);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingProject != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit project' : 'New project'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Basic info ─────────────────────────────────────────
                _SectionLabel(label: 'Basic information'),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Project title',
                    prefixIcon: Icon(Icons.title_rounded),
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Enter a title' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _categoryController,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    hintText: 'e.g. Film, Photography, Audio',
                    prefixIcon: Icon(Icons.category_rounded),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Enter a category' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _rolesController,
                  decoration: const InputDecoration(
                    labelText: 'Roles needed',
                    hintText: 'Videographer, Editor, Sound Designer',
                    prefixIcon: Icon(Icons.people_outline_rounded),
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    prefixIcon: Icon(Icons.description_rounded),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 5,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Describe the project' : null,
                ),
                const SizedBox(height: 22),

                // ── Location & deadline ────────────────────────────────
                _SectionLabel(label: 'Location & schedule'),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    prefixIcon: Icon(Icons.place_outlined),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Enter a location' : null,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _deadlineController,
                        readOnly: true,
                        onTap: _pickDeadline,
                        decoration: const InputDecoration(
                          labelText: 'Deadline',
                          prefixIcon: Icon(Icons.calendar_today_rounded),
                          hintText: 'YYYY-MM-DD',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ScenePillButton(
                      label: 'Pick',
                      onPressed: _pickDeadline,
                      filled: false,
                      icon: Icons.date_range_rounded,
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                // ── Budget & status ────────────────────────────────────
                _SectionLabel(label: 'Budget & status'),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _budgetController,
                  decoration: const InputDecoration(
                    labelText: 'Budget (optional)',
                    prefixIcon: Icon(Icons.payments_rounded),
                    prefixText: '£ ',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<ProjectStatus>(
                  initialValue: _status,
                  items: ProjectStatus.values
                      .map((s) => DropdownMenuItem(value: s, child: Text(s.label)))
                      .toList(),
                  onChanged: (v) => setState(() => _status = v ?? ProjectStatus.open),
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    prefixIcon: Icon(Icons.flag_rounded),
                  ),
                ),
                const SizedBox(height: 28),

                // ── Save button ────────────────────────────────────────
                FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_rounded),
                  label: Text(
                    _saving
                        ? 'Saving…'
                        : isEditing
                            ? 'Update project'
                            : 'Create project',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
                if (isEditing) ...[
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _saving ? null : _deleteProject,
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                    label: const Text(
                      'Delete project',
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
