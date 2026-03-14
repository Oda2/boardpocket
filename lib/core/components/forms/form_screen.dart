import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../i18n/i18n.dart';
import '../../theme/app_theme.dart';
import '../app_text_field.dart';
import '../images/adaptive_image.dart';
import 'form_section.dart';
import 'form_screen_base.dart';

class FormScreen<T> extends StatefulWidget {
  final String title;
  final String? subtitle;
  final bool isEditing;
  final List<FormFieldConfig> fields;
  final List<Widget>? customFields;
  final Future<T?> Function(Map<String, dynamic> values)? onSave;
  final Future<T?> Function(String id)? onLoad;
  final String? editId;
  final String cancelText;
  final String saveText;
  final IconData? saveIcon;

  const FormScreen({
    super.key,
    required this.title,
    this.subtitle,
    required this.isEditing,
    required this.fields,
    this.customFields,
    this.onSave,
    this.onLoad,
    this.editId,
    this.cancelText = 'Cancel',
    this.saveText = 'Save',
    this.saveIcon,
  });

  @override
  State<FormScreen<T>> createState() => _FormScreenState<T>();
}

class _FormScreenState<T> extends State<FormScreen<T>> {
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, dynamic> _values = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    for (final field in widget.fields) {
      _controllers[field.name] = TextEditingController();
      if (widget.isEditing && widget.editId != null && widget.onLoad != null) {
        _loadData();
      }
    }
  }

  Future<void> _loadData() async {
    if (widget.editId == null || widget.onLoad == null) return;
    setState(() => _isLoading = true);
    final data = await widget.onLoad!(widget.editId!);
    if (data != null && mounted) {
      setState(() {
        _isLoading = false;
        for (final key in (data as Map).keys) {
          if (_controllers.containsKey(key)) {
            _controllers[key]!.text = data[key]?.toString() ?? '';
          }
        }
      });
    }
  }

  Future<void> _save() async {
    final values = <String, dynamic>{};
    for (final controller in _controllers.entries) {
      values[controller.key] = controller.value.text;
    }

    for (final field in widget.fields) {
      if (field.required && (values[field.name]?.isEmpty ?? true)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please enter ${field.label.toLowerCase()}')),
        );
        return;
      }
    }

    if (widget.onSave != null) {
      await widget.onSave!(values);
      if (mounted) context.pop();
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            FormScreenHeader(
              title: widget.title,
              cancelText: widget.cancelText,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...widget.fields.map((field) => _buildField(field)),
                    if (widget.customFields != null) ...widget.customFields!,
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
            FormScreenFooter(
              label: widget.saveText,
              icon: widget.saveIcon,
              onPressed: _save,
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(FormFieldConfig field) {
    switch (field.type) {
      case FormFieldType.text:
      case FormFieldType.url:
      case FormFieldType.number:
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: FormSection(
            label: field.label,
            child: AppTextField(
              controller: _controllers[field.name],
              hint: field.hint,
              icon: field.icon,
              suffixText: field.suffixText,
              keyboardType: field.type == FormFieldType.number
                  ? TextInputType.number
                  : field.type == FormFieldType.url
                  ? TextInputType.url
                  : TextInputType.text,
            ),
          ),
        );
      case FormFieldType.imagePreview:
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FormSection(
                label: field.label,
                child: AppTextField(
                  controller: _controllers[field.name],
                  hint: field.hint,
                  icon: field.icon,
                  keyboardType: TextInputType.url,
                  onChanged: (_) => setState(() {}),
                ),
              ),
              if (_controllers[field.name]?.text.isNotEmpty ?? false) ...[
                const SizedBox(height: 16),
                _buildImagePreview(),
              ],
            ],
          ),
        );
      default:
        return const SizedBox();
    }
  }

  Widget _buildImagePreview() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: AdaptiveImage(
          networkUrl: _controllers['imageUrl']?.text,
          width: double.infinity,
          height: 200,
        ),
      ),
    );
  }
}

enum FormFieldType { text, url, number, imagePreview }

class FormFieldConfig {
  final String name;
  final String label;
  final String? hint;
  final IconData? icon;
  final String? suffixText;
  final FormFieldType type;
  final bool required;

  const FormFieldConfig({
    required this.name,
    required this.label,
    this.hint,
    this.icon,
    this.suffixText,
    this.type = FormFieldType.text,
    this.required = false,
  });
}
