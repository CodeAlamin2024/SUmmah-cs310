import 'package:flutter/material.dart';

import '../utils/app_routes.dart';
import '../utils/app_spacing.dart';
import '../utils/validators.dart';
import '../widgets/app_text_field.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/primary_button.dart';
import '../widgets/responsive_scroll_body.dart';

/// S5 – Admin sign in.
///
/// UI-only in Step 2: a valid form simply opens the Admin dashboard.
/// Firebase Authentication replaces this in Step 3.
class AdminSignInScreen extends StatefulWidget {
  const AdminSignInScreen({super.key});

  @override
  State<AdminSignInScreen> createState() => _AdminSignInScreenState();
}

class _AdminSignInScreenState extends State<AdminSignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  /// Errors appear only after the first "Sign in" tap, then update live.
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();

    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      setState(() => _autovalidateMode = AutovalidateMode.onUserInteraction);
      return;
    }

    // Step 2: no real authentication yet.
    Navigator.of(context).pushReplacementNamed(AppRoutes.adminDashboard);
  }

  Future<void> _openCreateAccount() async {
    final result =
        await Navigator.of(context).pushNamed(AppRoutes.createAccount);

    // Create account returns the new email so the admin can sign in faster.
    if (!mounted) return;
    if (result is String && result.isNotEmpty) {
      _emailController.text = result;
      _passwordController.clear();
    }
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
      ),
      body: ResponsiveScrollBody(
        child: AutofillGroup(
          child: Form(
            key: _formKey,
            autovalidateMode: _autovalidateMode,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AuthHeader(
                  title: 'Admin sign in',
                  subtitle: 'For masjid organisers',
                ),
                const Gap(AppSpacing.md),
                const Center(
                  child: DemoNotice(
                    text: 'Demo only: sign-in is simulated until Step 3',
                  ),
                ),
                const Gap(AppSpacing.xl),
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
                  hint: 'Password',
                  prefixIcon: Icons.lock_outline,
                  controller: _passwordController,
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.password],
                  validator: Validators.requiredPassword,
                  onFieldSubmitted: (_) => _submit(),
                ),
                const Gap(AppSpacing.xl),
                PrimaryButton(label: 'Sign in', onPressed: _submit),
                const Gap(AppSpacing.md),
                AuthFooterLink(
                  prompt: "Don't have an account?",
                  actionLabel: 'Create one',
                  onTap: _openCreateAccount,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
