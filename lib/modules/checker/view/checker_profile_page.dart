import 'package:flutter/material.dart';
import 'package:megacess/core/config/flavor_config.dart';
import 'package:megacess/core/theme/app_colors.dart';
import 'package:megacess/core/theme/app_typography.dart';
import 'package:megacess/core/widgets/mega_app_header.dart';
import 'package:megacess/modules/utility/secure_storage_service.dart';
import '../data/model/checker_profile_model.dart';
import '../data/service/checker_profile_service.dart';

class CheckerProfilePage extends StatefulWidget {
  const CheckerProfilePage({super.key});

  @override
  State<CheckerProfilePage> createState() => _CheckerProfilePageState();
}

class _CheckerProfilePageState extends State<CheckerProfilePage> {
  late final CheckerProfileService _checkerProfileService;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  CheckerProfile? profile;
  bool isLoading = true;
  bool isUpdating = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _checkerProfileService = CheckerProfileService(SecureStorageService());
    _fetchProfile();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _getFullImageUrl(String? userImg) {
    if (userImg == null || userImg.isEmpty) return null;
    if (userImg.startsWith('http://') || userImg.startsWith('https://')) {
      return userImg;
    }
    return '${FlavorConfig.instance.baseDomain}/$userImg';
  }

  Future<void> _fetchProfile() async {
    setState(() => isLoading = true);
    try {
      final fetchedProfile = await _checkerProfileService.fetchProfile();
      if (mounted) {
        setState(() {
          profile = fetchedProfile;
          _phoneController.text = fetchedProfile.userPhone;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load profile: $e'),
            backgroundColor: AppColors.statusRejectedText,
          ),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (_phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Phone number is required'),
          backgroundColor: AppColors.statusRejectedText,
        ),
      );
      return;
    }

    if (_passwordController.text.isNotEmpty &&
        _passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: AppColors.statusRejectedText,
        ),
      );
      return;
    }

    setState(() => isUpdating = true);

    try {
      final Map<String, dynamic> updateData = {
        'user_phone': _phoneController.text.trim(),
      };

      if (_passwordController.text.isNotEmpty) {
        updateData['user_password'] = _passwordController.text;
      }

      final updated = await _checkerProfileService.updateProfile(updateData);

      if (mounted) {
        setState(() {
          profile = updated;
          isUpdating = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: AppColors.statusCompletedText,
          ),
        );
        _passwordController.clear();
        _confirmPasswordController.clear();
      }
    } catch (e) {
      if (mounted) {
        setState(() => isUpdating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${e.toString().replaceFirst('Exception: ', '')}',
            ),
            backgroundColor: AppColors.statusRejectedText,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.mcBgApp,
        appBar: MegaAppHeader(
          title: 'My Profile',
          showBackButton: true,
        ),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.mcForestGreen),
          ),
        ),
      );
    }

    if (profile == null) {
      return Scaffold(
        backgroundColor: AppColors.mcBgApp,
        appBar: const MegaAppHeader(
          title: 'My Profile',
          showBackButton: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: AppColors.statusRejectedText,
                size: 48,
              ),
              const SizedBox(height: 12),
              const Text('Failed to load profile details'),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mcForestGreen,
                  foregroundColor: Colors.white,
                ),
                onPressed: _fetchProfile,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final p = profile!;
    final avatarUrl = _getFullImageUrl(p.userImg);

    return Scaffold(
      backgroundColor: AppColors.mcBgApp,
      appBar: const MegaAppHeader(
        title: 'My Profile',
        subtitle: 'Account & Security Settings',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 1. Profile Identity Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.mcBorder),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 46,
                    backgroundColor: AppColors.frond50,
                    backgroundImage:
                        avatarUrl != null ? NetworkImage(avatarUrl) : null,
                    child: avatarUrl == null
                        ? const Icon(
                            Icons.person,
                            size: 48,
                            color: AppColors.mcForestGreen,
                          )
                        : null,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    p.userFullname.isNotEmpty ? p.userFullname : p.userNickname,
                    style: AppTypography.headingH3.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.frond50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.frond200),
                    ),
                    child: Text(
                      p.userRole.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.mcForestGreen,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. Personal Information Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.mcBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Personal Information', style: AppTypography.headingH4),
                  const SizedBox(height: 12),
                  _InfoItem(label: 'Full Name', value: p.userFullname.isNotEmpty ? p.userFullname : '-'),
                  const Divider(height: 20),
                  _InfoItem(
                    label: 'Nickname',
                    value: p.userNickname.isNotEmpty ? p.userNickname : '-',
                  ),
                  const Divider(height: 20),
                  _InfoItem(
                    label: 'IC Number',
                    value: p.userIc.isNotEmpty ? p.userIc : '-',
                  ),
                  const Divider(height: 20),
                  _InfoItem(
                    label: 'Gender',
                    value: p.userGender.isNotEmpty ? p.userGender : '-',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 3. Edit Profile Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.mcBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Edit Details', style: AppTypography.headingH4),
                  const SizedBox(height: 14),

                  // Phone input
                  Text('Phone Number', style: AppTypography.caption),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.mcBgApp,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.mcBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.mcBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: AppColors.mcForestGreen),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // New Password input
                  Text('New Password (Optional)', style: AppTypography.caption),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: 'Enter new password',
                      hintStyle: TextStyle(color: AppColors.textDisabled),
                      filled: true,
                      fillColor: AppColors.mcBgApp,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.mcBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.mcBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: AppColors.mcForestGreen),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Confirm Password input
                  Text('Confirm Password', style: AppTypography.caption),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    decoration: InputDecoration(
                      hintText: 'Confirm new password',
                      hintStyle: TextStyle(color: AppColors.textDisabled),
                      filled: true,
                      fillColor: AppColors.mcBgApp,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.mcBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.mcBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: AppColors.mcForestGreen),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () => setState(
                          () => _obscureConfirmPassword =
                              !_obscureConfirmPassword,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 4. Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mcForestGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: isUpdating ? null : _saveProfile,
                child: isUpdating
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Save Changes',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;

  const _InfoItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.caption),
        Text(
          value,
          style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
