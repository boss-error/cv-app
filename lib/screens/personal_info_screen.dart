import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cv_provider.dart';
import '../models/cv_data.dart';
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
    super.dispose();
  }

  void _saveAndContinue() {
    if (_formKey.currentState!.validate()) {
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
      );

      Provider.of<CVProvider>(context, listen: false).updatePersonalInfo(personalInfo);
      
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                'Enter your personal details to get started with your CV',
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                ),
              ),
              
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
                        'Continue to Education',
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
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.white70 
                        : const Color(0xFF6B7280),
                  ),
                ),
                Text(
                  'Personal Info',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6366F1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: 1/6,
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
              minHeight: 4,
            ),
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
          label: 'Full Name',
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
          label: 'Email Address',
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
          label: 'Phone Number',
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
          label: 'Address',
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
          hint: 'Brief description about yourself',
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
        
        // Website (Optional)
        _buildTextField(
          controller: _websiteController,
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
