import 'package:flutter/material.dart';
import '../view-model/login_view_model.dart';
import 'role_home.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/mega_button.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final LoginViewModel _viewModel = LoginViewModel();
  final _formKey = GlobalKey<FormState>();

  // Ensure controllers are strictly initialized empty with no demo pre-fill
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter both username and password.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final success = await _viewModel.login(username, password);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _errorMessage = _viewModel.errorMessage;
    });

    if (success) {
      final userRole = _viewModel.userRole;
      final nickname = _viewModel.lastLoginResponse?.user.userNickname;

      final home = userRole == null
          ? null
          : homeForRole(userRole, nickname: nickname);
      if (home == null) {
        await _viewModel.logout();
        if (!mounted) return;
        setState(() {
          _errorMessage = 'Access denied. This account role is not supported.';
        });
        return;
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => home),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mcBgApp,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Brand Header Banner
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: AppColors.mcForestDark,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.frond7, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.mcForestDark.withValues(alpha: 0.12),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'M',
                        style: AppTypography.heroNumber.copyWith(
                          color: Colors.white,
                          fontSize: 38,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'MEGACESS',
                    style: AppTypography.titleLarge.copyWith(
                      color: AppColors.mcForestDark,
                      letterSpacing: 2.0,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Estate Workforce & Field Operations',
                    style: AppTypography.caption.copyWith(color: AppColors.mcTextSecondary),
                  ),
                  const SizedBox(height: 32),

                  // Login Form Card
                  Container(
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: AppColors.mcBgSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.mcBorder, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Sign In',
                          style: AppTypography.titleMedium.copyWith(fontSize: 18),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Enter your estate personnel credentials',
                          style: AppTypography.captionMuted,
                        ),
                        const SizedBox(height: 20),

                        // Username Field
                        Text(
                          'Username',
                          style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _usernameController,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.text,
                          style: AppTypography.bodyRegular,
                          decoration: InputDecoration(
                            hintText: 'Enter your estate ID or username',
                            prefixIcon: const Icon(
                              Icons.person_outline,
                              size: 20,
                              color: AppColors.mcTextSecondary,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Username is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Password Field
                        Text(
                          'Password',
                          style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _login(),
                          style: AppTypography.bodyRegular,
                          decoration: InputDecoration(
                            hintText: 'Enter your password',
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              size: 20,
                              color: AppColors.mcTextSecondary,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                size: 20,
                                color: AppColors.mcTextSecondary,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Error message banner
                        if (_errorMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.mcStatusDangerBg,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.mcStatusDanger.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  size: 18,
                                  color: AppColors.mcStatusDanger,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: AppTypography.caption.copyWith(
                                      color: AppColors.mcStatusDanger,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Login Action Button
                        MegaButton(
                          text: 'Sign In to Estate',
                          icon: Icons.login,
                          isLoading: _isLoading,
                          onPressed: _login,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  Text(
                    'Connected to Central Plantation Cloud',
                    style: AppTypography.captionMuted,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
