import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart'; // Commented out - image editing disabled
import '../data/model/mandor_profile_model.dart';
import '../data/service/mandor_profile_service.dart';
import 'package:megacess/core/config/flavor_config.dart';

class MandorProfilePage extends StatefulWidget {
  const MandorProfilePage({super.key});

  @override
  State<MandorProfilePage> createState() => _MandorProfilePageState();
}

class _MandorProfilePageState extends State<MandorProfilePage> {
  final MandorProfileService _mandorProfileService = MandorProfileService();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  // final ImagePicker _imagePicker = ImagePicker(); // Commented out

  MandorProfile? profile;
  bool isLoading = true;
  bool isUpdating = false;
  // bool isUploadingImage = false; // Commented out
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _fetchProfile() async {
    setState(() => isLoading = true);
    try {
      final fetchedProfile = await _mandorProfileService.fetchProfile();
      setState(() {
        profile = fetchedProfile;
        _phoneController.text = fetchedProfile.userPhone;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Image upload functionality commented out
  // Future<void> _pickAndUploadImage() async {
  //   try {
  //     // Show dialog to choose between camera or gallery
  //     final ImageSource? source = await showDialog<ImageSource>(
  //       context: context,
  //       builder: (context) => AlertDialog(
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(12),
  //         ),
  //         title: const Text('Choose Image Source'),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             ListTile(
  //               leading: const Icon(Icons.camera_alt, color: Color(0xFF7ED957)),
  //               title: const Text('Camera'),
  //               onTap: () => Navigator.pop(context, ImageSource.camera),
  //             ),
  //             ListTile(
  //               leading: const Icon(
  //                 Icons.photo_library,
  //                 color: Color(0xFF7ED957),
  //               ),
  //               title: const Text('Gallery'),
  //               onTap: () => Navigator.pop(context, ImageSource.gallery),
  //             ),
  //           ],
  //         ),
  //       ),
  //     );

  //     if (source == null) return;

  //     final XFile? pickedFile = await _imagePicker.pickImage(
  //       source: source,
  //       maxWidth: 1024,
  //       maxHeight: 1024,
  //       imageQuality: 85,
  //     );

  //     if (pickedFile == null) return;

  //     setState(() => isUploadingImage = true);

  //     print('Uploading image from: ${pickedFile.path}');

  //     final updatedProfile = await _mandorProfileService.uploadProfileImage(
  //       pickedFile.path,
  //     );

  //     print('Upload successful, new image: ${updatedProfile.userImg}');

  //     setState(() {
  //       profile = updatedProfile;
  //       isUploadingImage = false;
  //     });

  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text('Profile image updated successfully'),
  //           backgroundColor: Colors.green,
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     setState(() => isUploadingImage = false);
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text(
  //             'Failed to upload image: ${e.toString().replaceFirst('Exception: ', '')}',
  //           ),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     }
  //   }
  // }

  Future<void> _saveProfile() async {
    // Validate phone number
    if (_phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Phone number is required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate password confirmation if password is provided
    if (_passwordController.text.isNotEmpty &&
        _passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isUpdating = true);
    try {
      final updateData = <String, dynamic>{
        'user_phone': _phoneController.text.trim(),
      };

      // Only include password if it's provided
      if (_passwordController.text.isNotEmpty) {
        updateData['user_password'] = _passwordController.text;
      }

      final updatedProfile = await _mandorProfileService.updateProfile(
        updateData,
      );

      setState(() {
        isUpdating = false;
        profile = updatedProfile;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        // Clear password fields after successful update
        _passwordController.clear();
        _confirmPasswordController.clear();
      }
    } catch (e) {
      setState(() => isUpdating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${e.toString().replaceFirst('Exception: ', '')}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9D9D9),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : profile == null
          ? const Center(child: Text('Failed to load profile'))
          : Column(
              children: [
                // Header with gradient
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                    left: 0,
                    right: 0,
                    top: 0,
                    bottom: 32,
                  ),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF7ED957), Color(0xFFB2F7EF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                  child: SafeArea(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.black,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        const SizedBox(width: 8),
                        const Padding(
                          padding: EdgeInsets.only(top: 12.0),
                          child: Text(
                            'Manage Profile',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Profile content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        // Profile Avatar with Edit Button
                        Center(
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 60,
                                backgroundColor: Colors.grey[300],
                                backgroundImage:
                                    profile!.userImg != null &&
                                        profile!.userImg!.isNotEmpty
                                    ? NetworkImage(
                                        profile!.userImg!.startsWith('http')
                                            ? '${profile!.userImg!}?t=${DateTime.now().millisecondsSinceEpoch}'
                                            : '${FlavorConfig.instance.baseDomain}${profile!.userImg!}?t=${DateTime.now().millisecondsSinceEpoch}',
                                      )
                                    : null,
                                child:
                                    profile!.userImg == null ||
                                        profile!.userImg!.isEmpty
                                    ? const Icon(
                                        Icons.account_circle,
                                        size: 100,
                                        color: Colors.black26,
                                      )
                                    : null,
                              ),
                              // Loading overlay commented out since image editing is disabled
                              // if (isUploadingImage)
                              //   Positioned.fill(
                              //     child: CircleAvatar(
                              //       radius: 60,
                              //       backgroundColor: Colors.black54,
                              //       child: const CircularProgressIndicator(
                              //         color: Colors.white,
                              //         strokeWidth: 3,
                              //       ),
                              //     ),
                              //   ),
                              // Edit button commented out
                              // Positioned(
                              //   bottom: 0,
                              //   right: 0,
                              //   child: GestureDetector(
                              //     onTap: isUploadingImage
                              //         ? null
                              //         : _pickAndUploadImage,
                              //     child: Container(
                              //       padding: const EdgeInsets.all(8),
                              //       decoration: BoxDecoration(
                              //         color: const Color(0xFF7ED957),
                              //         shape: BoxShape.circle,
                              //         border: Border.all(
                              //           color: Colors.white,
                              //           width: 3,
                              //         ),
                              //       ),
                              //       child: const Icon(
                              //         Icons.edit,
                              //         color: Colors.white,
                              //         size: 20,
                              //       ),
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Phone Number Field
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Phone Number:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: TextField(
                                controller: _phoneController,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  hintText: 'Enter phone number',
                                ),
                                keyboardType: TextInputType.phone,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Password Field
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Password:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: TextField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  hintText: 'Enter new password',
                                  suffixIcon: TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                    child: Text(
                                      _obscurePassword ? 'show' : 'hide',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Confirm Password Field
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Confirm Password:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: TextField(
                                controller: _confirmPasswordController,
                                obscureText: _obscureConfirmPassword,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  hintText: 'Confirm new password',
                                  suffixIcon: TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _obscureConfirmPassword =
                                            !_obscureConfirmPassword;
                                      });
                                    },
                                    child: Text(
                                      _obscureConfirmPassword ? 'show' : 'hide',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Save Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF007AFF),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            onPressed: isUpdating ? null : _saveProfile,
                            child: isUpdating
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    'Save',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
