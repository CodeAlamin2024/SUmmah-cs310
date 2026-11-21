import 'package:flutter/material.dart';

import '../models/announcement.dart';
import '../utils/app_colors.dart';
import '../utils/app_spacing.dart';
import '../utils/app_text_styles.dart';
import '../utils/date_format.dart';
import '../utils/validators.dart';
import '../widgets/app_dialog.dart';
import '../widgets/primary_button.dart';
import '../widgets/responsive_scroll_body.dart';

/// S8 – Announcement form (create or edit).
///
/// Validates title, description and category inline. When valid, shows the
/// D2 confirmation dialog before returning the created/updated [Announcement]
/// to S7, which publishes it to the shared feed (S1, S3). Closing with unsaved
/// edits asks "Discard changes?".
class AnnouncementFormScreen extends StatefulWidget {
  const AnnouncementFormScreen({super.key, this.initialAnnouncement});

  /// When non-null, the form opens pre-filled in edit mode.
  final Announcement? initialAnnouncement;

  @override
  State<AnnouncementFormScreen> createState() => _AnnouncementFormScreenState();
}

class _AnnouncementFormScreenState extends State<AnnouncementFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  AnnouncementCategory? _selectedCategory;
  DateTime? _selectedDate;
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  bool get _isEditing => widget.initialAnnouncement != null;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialAnnouncement;
    _titleController = TextEditingController(text: initial?.title ?? '');
    _descriptionController =
        TextEditingController(text: initial?.description ?? '');
    _selectedCategory = initial?.category;
    _selectedDate = initial?.publishedAt;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool get _hasChanges {
    final initial = widget.initialAnnouncement;
    if (initial == null) {
      return _titleController.text.trim().isNotEmpty ||
          _descriptionController.text.trim().isNotEmpty ||
          _selectedCategory != null ||
          _selectedDate != null;
    }
    final dateChanged = _selectedDate != null &&
        !DateFormatter.isSameDay(_selectedDate!, initial.publishedAt);
    return _titleController.text.trim() != initial.title ||
        _descriptionController.text.trim() != initial.description ||
        _selectedCategory != initial.category ||
        dateChanged;
  }

  Future<void> _handleClose() async {
    FocusScope.of(context).unfocus();

    if (!_hasChanges) {
      Navigator.of(context).pop();
      return;
    }

    final discard = await AppDialog.show<bool>(
      context,
      title: 'Discard changes?',
      message: 'Your unsaved edits will be lost.',
      actions: (dialogContext) => [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
          ),
          child: const Text('Keep editing'),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.error,
            textStyle: AppTextStyles.link,
          ),
          child: const Text('Discard'),
        ),
      ],
    );

    if (!mounted || discard != true) return;
    Navigator.of(context).pop();
  }

  Future<void> _pickDate() async {
    FocusScope.of(context).unfocus();
    final initial = _selectedDate ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2025, 1, 1),
      lastDate: DateTime(2030, 12, 31),
    );
    if (!mounted || picked == null) return;
    setState(() => _selectedDate = picked);
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      setState(() => _autovalidateMode = AutovalidateMode.onUserInteraction);
      return;
    }

    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    // D2 – Publish or save confirmation dialog.
    final confirmed = await AppDialog.show<bool>(
      context,
      title: _isEditing ? 'Save announcement?' : 'Publish announcement?',
      message: _isEditing
          ? '"$title" will be updated in the announcements feed straight away.'
          : '"$title" will appear in the announcements feed straight away.',
      actions: (dialogContext) => [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
          ),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            textStyle: AppTextStyles.link,
          ),
          child: Text(_isEditing ? 'Save' : 'Publish'),
        ),
      ],
    );

    if (!mounted || confirmed != true) return;

    // No date picked: publish now, so it appears at the top of the feed.
    final publishDate = _selectedDate ?? DateTime.now();
    final result = _isEditing
        ? widget.initialAnnouncement!.copyWith(
            title: title,
            description: description,
            category: _selectedCategory,
            publishedAt: publishDate,
          )
        : Announcement(
            id: 'ann-${DateTime.now().millisecondsSinceEpoch}',
            title: title,
            description: description,
            category: _selectedCategory!,
            publishedAt: publishDate,
          );

    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final dateText = _selectedDate == null
        ? 'Today'
        : DateFormatter.medium(_selectedDate!);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleClose();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: 'Close',
            icon: const Icon(Icons.close),
            onPressed: _handleClose,
          ),
          title: Text(_isEditing ? 'Edit announcement' : 'New announcement'),
        ),
        body: ResponsiveScrollBody(
          child: Form(
            key: _formKey,
            autovalidateMode: _autovalidateMode,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Title', style: AppTextStyles.label),
                const Gap(AppSpacing.xs + 2),
                TextFormField(
                  controller: _titleController,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.sentences,
                  style: AppTextStyles.body,
                  validator: Validators.announcementTitle,
                  decoration: const InputDecoration(
                    hintText: "For example, Jumu'ah time change",
                  ),
                ),
                const Gap(AppSpacing.lg),
                const Text('Description', style: AppTextStyles.label),
                const Gap(AppSpacing.xs + 2),
                TextFormField(
                  controller: _descriptionController,
                  minLines: 4,
                  maxLines: 6,
                  textCapitalization: TextCapitalization.sentences,
                  style: AppTextStyles.body,
                  validator: Validators.announcementDescription,
                  decoration: const InputDecoration(
                    hintText: 'Write the announcement details',
                    alignLabelWithHint: true,
                  ),
                ),
                const Gap(AppSpacing.lg),
                const Text('Category', style: AppTextStyles.label),
                const Gap(AppSpacing.xs + 2),
                DropdownButtonFormField<AnnouncementCategory>(
                  initialValue: _selectedCategory,
                  isExpanded: true,
                  style: AppTextStyles.body,
                  dropdownColor: AppColors.surface,
                  hint: const Text(
                    'Choose a category',
                    style: AppTextStyles.bodySecondary,
                  ),
                  items: [
                    for (final category in AnnouncementCategory.values)
                      DropdownMenuItem<AnnouncementCategory>(
                        value: category,
                        child: Text(category.label),
                      ),
                  ],
                  validator: (value) =>
                      Validators.announcementCategory(value?.label),
                  onChanged: (value) =>
                      setState(() => _selectedCategory = value),
                ),
                const Gap(AppSpacing.lg),
                const Text(
                  'Publication date (optional)',
                  style: AppTextStyles.label,
                ),
                const Gap(AppSpacing.xs + 2),
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      suffixIcon: Icon(Icons.calendar_month_outlined, size: 20),
                    ),
                    child: Text(
                      dateText,
                      style: _selectedDate == null
                          ? AppTextStyles.bodySecondary
                          : AppTextStyles.body,
                    ),
                  ),
                ),
                const Gap(AppSpacing.xs + 2),
                const Text(
                  'Leave empty to publish today',
                  style: AppTextStyles.caption,
                ),
                const Gap(AppSpacing.xl),
                Row(
                  children: [
                    Expanded(
                      child: SecondaryButton(
                        label: 'Cancel',
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const Gap(AppSpacing.md),
                    Expanded(
                      child: PrimaryButton(
                        label: _isEditing ? 'Save changes' : 'Publish',
                        onPressed: _submit,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}