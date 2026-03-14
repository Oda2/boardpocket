import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../i18n/i18n.dart';
import '../../theme/app_theme.dart';
import '../app_button.dart';
import '../form_fields.dart';

enum FormFieldKind {
  text,
  number,
  url,
  imageUrl,
  chipSelector,
  numberSelector,
  starRating,
}

class FormFieldDef {
  final String key;
  final String label;
  final FormFieldKind type;
  final String? hint;
  final IconData? icon;
  final String? suffixText;
  final bool required;
  final List<String>? chipOptions;
  final int? minValue;
  final int? maxValue;
  final int? defaultValue;

  const FormFieldDef({
    required this.key,
    required this.label,
    required this.type,
    this.hint,
    this.icon,
    this.suffixText,
    this.required = false,
    this.chipOptions,
    this.minValue,
    this.maxValue,
    this.defaultValue,
  });
}

class GenericFormScreen extends StatefulWidget {
  final String title;
  final List<FormFieldDef> fields;
  final Future<void> Function(Map<String, dynamic> values) onSave;
  final Future<Map<String, dynamic>?> Function()? onLoad;
  final String saveLabel;
  final IconData? saveIcon;
  final String? cancelLabel;

  const GenericFormScreen({
    super.key,
    required this.title,
    required this.fields,
    required this.onSave,
    this.onLoad,
    required this.saveLabel,
    this.saveIcon,
    this.cancelLabel,
  });

  @override
  State<GenericFormScreen> createState() => _GenericFormScreenState();
}

class _GenericFormScreenState extends State<GenericFormScreen> {
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, dynamic> _values = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    for (final field in widget.fields) {
      _controllers[field.key] = TextEditingController();
      _values[field.key] =
          field.defaultValue ?? (field.type == FormFieldKind.number ? 0 : '');
    }
    if (widget.onLoad != null) _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final data = await widget.onLoad!();
    if (data != null && mounted) {
      setState(() {
        _isLoading = false;
        for (final entry in data.entries) {
          if (_controllers.containsKey(entry.key)) {
            _controllers[entry.key]!.text = entry.value?.toString() ?? '';
            _values[entry.key] = entry.value;
          }
        }
      });
    }
  }

  Future<void> _save() async {
    for (final field in widget.fields) {
      if (field.required) {
        final value = _values[field.key];
        if (value == null || (value is String && value.isEmpty)) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('${field.label} is required')));
          return;
        }
      }
    }
    await widget.onSave(_values);
    if (mounted) context.pop();
  }

  @override
  void dispose() {
    for (final c in _controllers.values) c.dispose();
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
            _buildHeader(l10n),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widget.fields.map((f) => _buildField(f)).toList(),
                ),
              ),
            ),
            _buildFooter(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_ios),
            color: AppColors.primary,
          ),
          Expanded(
            child: Text(
              widget.title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(
            onPressed: () => context.pop(),
            child: Text(widget.cancelLabel ?? l10n.cancel),
          ),
        ],
      ),
    );
  }

  Widget _buildField(FormFieldDef field) {
    switch (field.type) {
      case FormFieldKind.text:
      case FormFieldKind.number:
      case FormFieldKind.url:
        return _buildTextField(field);
      case FormFieldKind.imageUrl:
        return _buildImageUrlField(field);
      case FormFieldKind.chipSelector:
        return _buildChipSelector(field);
      case FormFieldKind.numberSelector:
        return _buildNumberSelector(field);
      case FormFieldKind.starRating:
        return _buildStarRating(field);
    }
  }

  Widget _buildTextField(FormFieldDef field) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            field.label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextFieldInput(
            controller: _controllers[field.key],
            hint: field.hint,
            icon: field.icon,
            suffixText: field.suffixText,
            keyboardType: field.type == FormFieldKind.number
                ? TextInputType.number
                : field.type == FormFieldKind.url
                ? TextInputType.url
                : TextInputType.text,
            onChanged: (v) => _values[field.key] = v,
          ),
        ],
      ),
    );
  }

  Widget _buildImageUrlField(FormFieldDef field) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            field.label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextFieldInput(
            controller: _controllers[field.key],
            hint: field.hint ?? 'https://...',
            icon: field.icon ?? Icons.image_outlined,
            keyboardType: TextInputType.url,
            onChanged: (v) {
              _values[field.key] = v;
              setState(() {});
            },
          ),
          if (_controllers[field.key]?.text.isNotEmpty ?? false) ...[
            const SizedBox(height: 16),
            ImageUrlPreview(imageUrl: _controllers[field.key]?.text),
          ],
        ],
      ),
    );
  }

  Widget _buildChipSelector(FormFieldDef field) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            field.label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SelectableChips(
            items: field.chipOptions ?? [],
            selected: _values[field.key]?.toString() ?? '',
            onSelected: (v) => setState(() => _values[field.key] = v),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberSelector(FormFieldDef field) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            field.label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          NumberSelector(
            value: _values[field.key] ?? field.defaultValue ?? 1,
            min: field.minValue ?? 1,
            max: field.maxValue ?? 100,
            onChanged: (v) => setState(() => _values[field.key] = v),
          ),
        ],
      ),
    );
  }

  Widget _buildStarRating(FormFieldDef field) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            field.label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          StarRatingInput(
            value: _values[field.key] ?? field.defaultValue ?? 3,
            onChanged: (v) => setState(() => _values[field.key] = v),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
            (isDark ? AppColors.backgroundDark : AppColors.backgroundLight)
                .withValues(alpha: 0),
          ],
        ),
      ),
      child: SafeArea(
        child: AppButton(
          label: widget.saveLabel,
          icon: widget.saveIcon,
          onPressed: _save,
        ),
      ),
    );
  }
}
