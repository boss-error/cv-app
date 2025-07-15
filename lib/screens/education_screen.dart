import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../providers/cv_provider.dart';
import '../providers/theme_provider.dart';
import '../models/cv_data.dart';
import '../widgets/modern_dialog.dart';
import 'experience_screen.dart';

class EducationScreen extends StatefulWidget {
  const EducationScreen({super.key});

  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.themeMode == ThemeMode.dark;
    
    return CupertinoPageScaffold(
      backgroundColor: isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F7),
      navigationBar: CupertinoNavigationBar(
        backgroundColor: isDark 
            ? const Color(0xFF1C1C1E).withOpacity(0.8)
            : const Color(0xFFF2F2F7).withOpacity(0.8),
        border: Border(
          bottom: BorderSide(
            color: isDark 
                ? const Color(0xFF38383A)
                : const Color(0xFFD1D1D6),
            width: 0.5,
          ),
        ),
        middle: Text(
          'Education',
          style: TextStyle(
            color: isDark ? CupertinoColors.white : CupertinoColors.black,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: Consumer<CVProvider>(
          builder: (context, cvProvider, child) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF007AFF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${(cvProvider.completionPercentage * 100).toInt()}%',
                style: const TextStyle(
                  color: Color(0xFF007AFF),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            );
          },
        ),
      ),
      child: Consumer<CVProvider>(
        builder: (context, cvProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: AnimationLimiter(
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
                      'Education Background',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add your educational qualifications and achievements',
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Education list
                    _buildEducationList(cvProvider, isDark),
                    
                    const SizedBox(height: 24),
                    
                    // Add education button
                    _buildAddEducationButton(isDark),
                    
                    const SizedBox(height: 40),
                    
                    // Continue button
                    _buildContinueButton(cvProvider),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Step 2 of 6',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.white70 
                    : const Color(0xFF6B7280),
              ),
            ),
            const Text(
              'Education',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6366F1),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: 2/6,
          backgroundColor: const Color(0xFFE5E7EB),
          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
          minHeight: 4,
        ),
      ],
    );
  }

  Widget _buildEducationList(CVProvider cvProvider, bool isDark) {
    if (cvProvider.cvData.education.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F2937) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.school_outlined,
              size: 64,
              color: isDark ? Colors.white54 : const Color(0xFF9CA3AF),
            ),
            const SizedBox(height: 16),
            Text(
              'No Education Added Yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your educational background to strengthen your CV',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : const Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: cvProvider.cvData.education.asMap().entries.map((entry) {
        final index = entry.key;
        final education = entry.value;
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: _buildEducationCard(education, index, cvProvider, isDark),
        );
      }).toList(),
    );
  }

  Widget _buildEducationCard(Education education, int index, CVProvider cvProvider, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark 
                ? Colors.black.withOpacity(0.2)
                : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.school,
                  color: Color(0xFF6366F1),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      education.degree,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      education.institution,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    _showEducationDialog(education: education, index: index);
                  } else if (value == 'delete') {
                    cvProvider.removeEducation(index);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 16),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 16, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 16,
                color: isDark ? Colors.white54 : const Color(0xFF9CA3AF),
              ),
              const SizedBox(width: 8),
              Text(
                '\${education.startDate} - \${education.endDate}',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                ),
              ),
              if (education.gpa?.isNotEmpty == true) ...[
                const SizedBox(width: 16),
                Icon(
                  Icons.star,
                  size: 16,
                  color: isDark ? Colors.white54 : const Color(0xFF9CA3AF),
                ),
                const SizedBox(width: 8),
                Text(
                  'GPA: \${education.gpa}',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                  ),
                ),
              ],
            ],
          ),
          if (education.fieldOfStudy.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                education.fieldOfStudy,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6366F1),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          if (education.description?.isNotEmpty == true) ...[
            const SizedBox(height: 12),
            Text(
              education.description!,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAddEducationButton(bool isDark) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: CupertinoButton(
        onPressed: () => _showEducationDialog(),
        color: const Color(0xFF007AFF),
        borderRadius: BorderRadius.circular(12),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.add,
              color: CupertinoColors.white,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              'Add Education',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton(CVProvider cvProvider) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: CupertinoButton(
        onPressed: () {
          Navigator.of(context).push(
            CupertinoPageRoute(
              builder: (context) => const ExperienceScreen(),
            ),
          );
        },
        color: const Color(0xFF34C759),
        borderRadius: BorderRadius.circular(12),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Continue to Experience',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.white,
              ),
            ),
            SizedBox(width: 8),
            Icon(
              CupertinoIcons.arrow_right,
              color: CupertinoColors.white,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showEducationDialog({Education? education, int? index}) {
    final isEditing = education != null;
    final institutionController = TextEditingController(text: education?.institution ?? '');
    final degreeController = TextEditingController(text: education?.degree ?? '');
    final fieldController = TextEditingController(text: education?.fieldOfStudy ?? '');
    final startDateController = TextEditingController(text: education?.startDate ?? '');
    final endDateController = TextEditingController(text: education?.endDate ?? '');
    final gpaController = TextEditingController(text: education?.gpa ?? '');
    final descriptionController = TextEditingController(text: education?.description ?? '');

    showDialog(
      context: context,
      builder: (context) => ModernDialog(
        title: isEditing ? 'Edit Education' : 'Add Education',
        content: Column(
          children: [
            ModernTextField(
              controller: institutionController,
              label: 'Institution',
              hint: 'University/School name',
              isRequired: true,
            ),
            const SizedBox(height: 20),
            ModernTextField(
              controller: degreeController,
              label: 'Degree',
              hint: 'Bachelor of Science, Master of Arts, etc.',
              isRequired: true,
            ),
            const SizedBox(height: 20),
            ModernTextField(
              controller: fieldController,
              label: 'Field of Study',
              hint: 'Computer Science, Business, etc.',
              isRequired: true,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ModernTextField(
                    controller: startDateController,
                    label: 'Start Date',
                    hint: 'MM/YYYY',
                    isRequired: true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ModernTextField(
                    controller: endDateController,
                    label: 'End Date',
                    hint: 'MM/YYYY or Present',
                    isRequired: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ModernTextField(
              controller: gpaController,
              label: 'GPA',
              hint: '3.8/4.0',
            ),
            const SizedBox(height: 20),
            ModernTextField(
              controller: descriptionController,
              label: 'Description',
              hint: 'Relevant coursework, achievements, etc.',
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          ModernButton(
            text: 'Cancel',
            onPressed: () => Navigator.of(context).pop(),
          ),
          ModernButton(
            text: isEditing ? 'Update' : 'Add',
            isPrimary: true,
            icon: isEditing ? Icons.update : Icons.add,
            onPressed: () {
              // Validate required fields
              if (institutionController.text.trim().isEmpty ||
                  degreeController.text.trim().isEmpty ||
                  fieldController.text.trim().isEmpty ||
                  startDateController.text.trim().isEmpty ||
                  endDateController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill in all required fields'),
                    backgroundColor: Color(0xFFEF4444),
                  ),
                );
                return;
              }

              final newEducation = Education(
                institution: institutionController.text.trim(),
                degree: degreeController.text.trim(),
                fieldOfStudy: fieldController.text.trim(),
                startDate: startDateController.text.trim(),
                endDate: endDateController.text.trim(),
                gpa: gpaController.text.trim().isEmpty ? null : gpaController.text.trim(),
                description: descriptionController.text.trim().isEmpty ? null : descriptionController.text.trim(),
              );

              final cvProvider = Provider.of<CVProvider>(context, listen: false);
              
              if (isEditing && index != null) {
                cvProvider.updateEducation(index, newEducation);
              } else {
                cvProvider.addEducation(newEducation);
              }

              Navigator.of(context).pop();
              
              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isEditing ? 'Education updated successfully!' : 'Education added successfully!'),
                  backgroundColor: const Color(0xFF10B981),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
