import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../providers/cv_provider.dart';
import '../models/cv_data.dart';
import '../services/file_service.dart';
import 'education_screen.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _profileSummaryController = TextEditingController();
  final _linkedInController = TextEditingController();
  final _websiteController = TextEditingController();
  final _githubController = TextEditingController();
  final _portfolioController = TextEditingController();
  
  final FileService _fileService = FileService();
  bool _isUploadingPhoto = false;
  String? _photoError;

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() {
    final cvProvider = Provider.of<CVProvider>(context, listen: false);
    final personalInfo = cvProvider.cvData.personalInfo;
    
    _fullNameController.text = personalInfo.fullName;
    _emailController.text = personalInfo.email;
    _phoneController.text = personalInfo.phone;
    _addressController.text = personalInfo.address;
    _profileSummaryController.text = personalInfo.profileSummary ?? '';
    _linkedInController.text = personalInfo.linkedIn ?? '';
    _websiteController.text = personalInfo.website ?? '';
    _githubController.text = personalInfo.github ?? '';
    _portfolioController.text = personalInfo.portfolio ?? '';
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _profileSummaryController.dispose();
    _linkedInController.dispose();
    _websiteController.dispose();
    _githubController.dispose();
    _portfolioController.dispose();
    super.dispose();
  }

  Future<void> _pickImageFromGallery() async {
    try {
      setState(() {
        _isUploadingPhoto = true;
        _photoError = null;
      });

      final file = await _fileService.pickImageFromGallery();
      if (file != null) {
        final cvProvider = Provider.of<CVProvider>(context, listen: false);
        cvProvider.updateProfilePhoto(file.path);
      }
    } catch (e) {
      setState(() {
        _photoError = e.toString();
      });
    } finally {
      setState(() {
        _isUploadingPhoto = false;
      });
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      setState(() {
        _isUploadingPhoto = true;
        _photoError = null;
      });

      final file = await _fileService.pickImageFromCamera();
      if (file != null) {
        final cvProvider = Provider.of<CVProvider>(context, listen: false);
        cvProvider.updateProfilePhoto(file.path);
      }
    } catch (e) {
      setState(() {
        _photoError = e.toString();
      });
    } finally {
      setState(() {
        _isUploadingPhoto = false;
      });
    }
  }

  void _showImagePickerDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark 
              ? const Color(0xFF1F2937) 
              : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Select Profile Photo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.white 
                    : const Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildImagePickerOption(
                    icon: Icons.photo_library_outlined,
                    label: 'Gallery',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImageFromGallery();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildImagePickerOption(
                    icon: Icons.camera_alt_outlined,
                    label: 'Camera',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImageFromCamera();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePickerOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF374151) : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? const Color(0xFF4B5563) : const Color(0xFFE5E7EB),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: const Color(0xFF6366F1),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF374151),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveAndContinue() {
    if (_formKey.currentState!.validate()) {
      final cvProvider = Provider.of<CVProvider>(context, listen: false);
      final currentPhoto = cvProvider.cvData.personalInfo.profilePhotoPath;
      
      final personalInfo = PersonalInfo(
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        profileSummary: _profileSummaryController.text.trim().isEmpty 
            ? null 
            : _profileSummaryController.text.trim(),
        linkedIn: _linkedInController.text.trim().isEmpty 
            ? null 
            : _linkedInController.text.trim(),
        website: _websiteController.text.trim().isEmpty 
            ? null 
            : _websiteController.text.trim(),
        github: _githubController.text.trim().isEmpty 
            ? null 
            : _githubController.text.trim(),
        portfolio: _portfolioController.text.trim().isEmpty 
            ? null 
            : _portfolioController.text.trim(),
        profilePhotoPath: currentPhoto,
      );

      cvProvider.updatePersonalInfo(personalInfo);
      
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const EducationScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF111827) : const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text('Personal Information'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Consumer<CVProvider>(
            builder: (context, cvProvider, child) {
              return Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '\${(cvProvider.completionPercentage * 100).toInt()}% Complete',
                  style: const TextStyle(
                    color: Color(0xFF6366F1),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: AnimationLimiter(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: AnimationConfiguration.toStaggeredList(
                duration: const Duration(milliseconds: 600),
                childAnimationBuilder: (widget) => SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(child: widget),
                ),
                children: [
                  // Progress indicator
                  _buildProgressIndicator(),
                  
                  const SizedBox(height: 32),
                  
                  // Header
                  Text(
                    'Tell us about yourself',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This information will be used to create your professional CV',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Profile Photo Section
                  _buildProfilePhotoSection(isDark),
                  
                  const SizedBox(height: 32),
                  
                  // Form fields
                  _buildFormFields(isDark),
                  
                  const SizedBox(height: 40),
                  
                  // Continue button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _saveAndContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Continue',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, size: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Consumer<CVProvider>(
      builder: (context, cvProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Step 1 of 6',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.white70 
                        : const Color(0xFF6B7280),
                  ),
                ),
                Text(
                  '\${(cvProvider.completionPercentage * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.white70 
                        : const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: cvProvider.completionPercentage,
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
              minHeight: 6,
            ),
          ],
        );
      },
    );
  }

  Widget _buildProfilePhotoSection(bool isDark) {
    return Consumer<CVProvider>(
      builder: (context, cvProvider, child) {
        final photoPath = cvProvider.cvData.personalInfo.profilePhotoPath;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Profile Photo (Optional)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 16),
            
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
                      border: Border.all(
                        color: const Color(0xFF6366F1),
                        width: 3,
                      ),
                    ),
                    child: _isUploadingPhoto
                        ? const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                            ),
                          )
                        : photoPath != null
                            ? ClipOval(
                                child: Image.file(
                                  File(photoPath),
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.person_outline,
                                      size: 60,
                                      color: isDark ? Colors.white54 : const Color(0xFF9CA3AF),
                                    );
                                  },
                                ),
                              )
                            : Icon(
                                Icons.person_outline,
                                size: 60,
                                color: isDark ? Colors.white54 : const Color(0xFF9CA3AF),
                              ),
                  ),
                  
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _isUploadingPhoto ? null : _showImagePickerDialog,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: Color(0xFF6366F1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            if (_photoError != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFEF4444).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Color(0xFFEF4444),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _photoError!,
                        style: const TextStyle(
                          color: Color(0xFFEF4444),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            if (photoPath != null) ...[
              const SizedBox(height: 12),
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    final cvProvider = Provider.of<CVProvider>(context, listen: false);
                    cvProvider.removeProfilePhoto();
                    setState(() {
                      _photoError = null;
                    });
                  },
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Color(0xFFEF4444),
                    size: 16,
                  ),
                  label: const Text(
                    'Remove Photo',
                    style: TextStyle(
                      color: Color(0xFFEF4444),
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildFormFields(bool isDark) {
    return Column(
      children: [
        // Full Name
        _buildTextField(
          controller: _fullNameController,
          label: 'Full Name *',
          hint: 'Enter your full name',
          icon: Icons.person_outline,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your full name';
            }
            return null;
          },
          isDark: isDark,
        ),
        
        const SizedBox(height: 20),
        
        // Email
        _buildTextField(
          controller: _emailController,
          label: 'Email Address *',
          hint: 'Enter your email address',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your email address';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}\$').hasMatch(value)) {
              return 'Please enter a valid email address';
            }
            return null;
          },
          isDark: isDark,
        ),
        
        const SizedBox(height: 20),
        
        // Phone
        _buildTextField(
          controller: _phoneController,
          label: 'Phone Number *',
          hint: 'Enter your phone number',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your phone number';
            }
            return null;
          },
          isDark: isDark,
        ),
        
        const SizedBox(height: 20),
        
        // Address
        _buildTextField(
          controller: _addressController,
          label: 'Address *',
          hint: 'Enter your address',
          icon: Icons.location_on_outlined,
          maxLines: 2,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your address';
            }
            return null;
          },
          isDark: isDark,
        ),
        
        const SizedBox(height: 20),
        
        // Profile Summary (Optional)
        _buildTextField(
          controller: _profileSummaryController,
          label: 'Profile Summary (Optional)',
          hint: 'Brief description about yourself and your career goals',
          icon: Icons.description_outlined,
          maxLines: 4,
          isDark: isDark,
        ),
        
        const SizedBox(height: 20),
        
        // LinkedIn (Optional)
        _buildTextField(
          controller: _linkedInController,
          label: 'LinkedIn Profile (Optional)',
          hint: 'https://linkedin.com/in/yourprofile',
          icon: Icons.link_outlined,
          keyboardType: TextInputType.url,
          isDark: isDark,
        ),
        
        const SizedBox(height: 20),
        
        // GitHub (Optional)
        _buildTextField(
          controller: _githubController,
          label: 'GitHub Profile (Optional)',
          hint: 'https://github.com/yourusername',
          icon: Icons.code_outlined,
          keyboardType: TextInputType.url,
          isDark: isDark,
        ),
        
        const SizedBox(height: 20),
        
        // Website/Portfolio (Optional)
        _buildTextField(
          controller: _portfolioController,
          label: 'Website/Portfolio (Optional)',
          hint: 'https://yourwebsite.com',
          icon: Icons.language_outlined,
          keyboardType: TextInputType.url,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isDark,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1F2937),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: isDark ? Colors.white54 : const Color(0xFF9CA3AF),
            ),
            prefixIcon: Icon(
              icon,
              color: isDark ? Colors.white70 : const Color(0xFF6B7280),
            ),
            filled: true,
            fillColor: isDark ? const Color(0xFF374151) : const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? const Color(0xFF4B5563) : const Color(0xFFE5E7EB),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? const Color(0xFF4B5563) : const Color(0xFFE5E7EB),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF6366F1),
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFEF4444),
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFEF4444),
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
