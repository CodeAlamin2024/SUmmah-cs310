import 'package:flutter/material.dart';

import '../utils/app_spacing.dart';
import '../utils/app_text_styles.dart';
import '../utils/validators.dart';
import '../widgets/app_dialog.dart';
import '../widgets/app_text_field.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/primary_button.dart';
import '../widgets/responsive_scroll_body.dart';

/// S6 – Create account.
///
/// Four-field form with inline validation. A valid submission shows the
/// D1 confirmation dialog; "Back to sign in" returns to S5 and pre-fills
/// the email. No account is stored in Step 2.
class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      setState(() => _autovalidateMode = AutovalidateMode.onUserInteraction);
      return;
    }

    // D1 – confirmation dialog after a valid submission.
    await AppDialog.show<void>(
      context,
      icon: Icons.check_circle_outline,
      title: 'Demo account created',
      message: 'This is a simulation. No account was stored. '
          'Real registration arrives with Firebase in Step 3.',
      actions: (dialogContext) => [
        PrimaryButton(
          label: 'Back to sign in',
          onPressed: () => Navigator.of(dialogContext).pop(),
        ),
      ],
    );

    if (!mounted) return;
    // Back to S5 with the email so it can be pre-filled.
    Navigator.of(context).pop(_emailController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('Create account'),
      ),
      body: ResponsiveScrollBody(
        child: AutofillGroup(
          child: Form(
            key: _formKey,
            autovalidateMode: _autovalidateMode,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'For masjid volunteers who manage times and announcements.',
                  style: AppTextStyles.bodySecondary,
                ),
                const Gap(AppSpacing.sm),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: DemoNotice(text: 'Demo only: no account is created'),
                ),
                const Gap(AppSpacing.xl),
                AppTextField(
                  label: 'Full name',
                  hint: 'Your name',
                  prefixIcon: Icons.person_outline,
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  autofillHints: const [AutofillHints.name],
                  validator: Validators.fullName,
                ),
                const Gap(AppSpacing.lg),
                AppTextField(
                  label: 'Email',
                  hint: 'name@sabanciuniv.edu',
                  prefixIcon: Icons.mail_outline,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  validator: Validators.email,
                ),
                const Gap(AppSpacing.lg),
                AppTextField(
                  label: 'Password',
                  hint: 'At least ${Validators.minPasswordLength} characters',
                  prefixIcon: Icons.lock_outline,
                  controller: _passwordController,
                  isPassword: true,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.newPassword],
                  validator: Validators.newPassword,
                ),
                const Gap(AppSpacing.lg),
                AppTextField(
                  label: 'Confirm password',
                  hint: 'Repeat your password',
                  prefixIcon: Icons.lock_outline,
                  controller: _confirmController,
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  validator: Validators.confirmPassword(
                    () => _passwordController.text,
                  ),
                  onFieldSubmitted: (_) => _submit(),
                ),
                const Gap(AppSpacing.xl),
                PrimaryButton(label: 'Create account', onPressed: _submit),
                const Gap(AppSpacing.md),
                AuthFooterLink(
                  prompt: 'Already have an account?',
                  actionLabel: 'Sign in',
                  onTap: () => Navigator.of(context).maybePop(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
