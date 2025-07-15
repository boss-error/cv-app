import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../providers/cv_provider.dart';
import '../models/cv_data.dart';
import 'skills_screen.dart';

class ExperienceScreen extends StatefulWidget {
  const ExperienceScreen({super.key});

  @override
  State<ExperienceScreen> createState() => _ExperienceScreenState();
}

class _ExperienceScreenState extends State<ExperienceScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF111827) : const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text('Work Experience'),
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
      body: Consumer<CVProvider>(
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
                      'Work Experience',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add your professional work experience and achievements',
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Experience list
                    _buildExperienceList(cvProvider, isDark),
                    
                    const SizedBox(height: 24),
                    
                    // Add experience button
                    _buildAddExperienceButton(isDark),
                    
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
              'Step 3 of 6',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.white70 
                    : const Color(0xFF6B7280),
              ),
            ),
            const Text(
              'Experience',
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
          value: 3/6,
          backgroundColor: const Color(0xFFE5E7EB),
          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
          minHeight: 4,
        ),
      ],
    );
  }

  Widget _buildExperienceList(CVProvider cvProvider, bool isDark) {
    if (cvProvider.cvData.experience.isEmpty) {
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
              Icons.work_outline,
              size: 64,
              color: isDark ? Colors.white54 : const Color(0xFF9CA3AF),
            ),
            const SizedBox(height: 16),
            Text(
              'No Experience Added Yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your work experience to showcase your professional journey',
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
      children: cvProvider.cvData.experience.asMap().entries.map((entry) {
        final index = entry.key;
        final experience = entry.value;
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: _buildExperienceCard(experience, index, cvProvider, isDark),
        );
      }).toList(),
    );
  }

  Widget _buildExperienceCard(Experience experience, int index, CVProvider cvProvider, bool isDark) {
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
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.work,
                  color: Color(0xFF10B981),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      experience.position,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      experience.company,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              if (experience.isCurrentJob)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Current',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF10B981),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    _showExperienceDialog(experience: experience, index: index);
                  } else if (value == 'delete') {
                    cvProvider.removeExperience(index);
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
                '\${experience.startDate} - \${experience.isCurrentJob ? "Present" : experience.endDate}',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                ),
              ),
              if (experience.location?.isNotEmpty == true) ...[
                const SizedBox(width: 16),
                Icon(
                  Icons.location_on,
                  size: 16,
                  color: isDark ? Colors.white54 : const Color(0xFF9CA3AF),
                ),
                const SizedBox(width: 8),
                Text(
                  experience.location!,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                  ),
                ),
              ],
            ],
          ),
          if (experience.responsibilities.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Key Responsibilities:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            ...experience.responsibilities.map((responsibility) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 4,
                    height: 4,
                    margin: const EdgeInsets.only(top: 8, right: 8),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white54 : const Color(0xFF9CA3AF),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      responsibility,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildAddExperienceButton(bool isDark) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: () => _showExperienceDialog(),
        icon: const Icon(Icons.add),
        label: const Text(
          'Add Experience',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF6366F1),
          side: const BorderSide(color: Color(0xFF6366F1)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildContinueButton(CVProvider cvProvider) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const SkillsScreen(),
            ),
          );
        },
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
              'Continue to Skills',
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
    );
  }

  void _showExperienceDialog({Experience? experience, int? index}) {
    final isEditing = experience != null;
    final companyController = TextEditingController(text: experience?.company ?? '');
    final positionController = TextEditingController(text: experience?.position ?? '');
    final locationController = TextEditingController(text: experience?.location ?? '');
    final startDateController = TextEditingController(text: experience?.startDate ?? '');
    final endDateController = TextEditingController(text: experience?.endDate ?? '');
    final responsibilitiesController = TextEditingController(
      text: experience?.responsibilities.join('\n') ?? ''
    );
    bool isCurrentJob = experience?.isCurrentJob ?? false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(isEditing ? 'Edit Experience' : 'Add Experience'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: companyController,
                  decoration: const InputDecoration(
                    labelText: 'Company',
                    hintText: 'Company name',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: positionController,
                  decoration: const InputDecoration(
                    labelText: 'Position',
                    hintText: 'Job title',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location (Optional)',
                    hintText: 'City, Country',
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: startDateController,
                        decoration: const InputDecoration(
                          labelText: 'Start Date',
                          hintText: 'MM/YYYY',
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: endDateController,
                        enabled: !isCurrentJob,
                        decoration: InputDecoration(
                          labelText: 'End Date',
                          hintText: isCurrentJob ? 'Present' : 'MM/YYYY',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text('I currently work here'),
                  value: isCurrentJob,
                  onChanged: (value) {
                    setState(() {
                      isCurrentJob = value ?? false;
                      if (isCurrentJob) {
                        endDateController.clear();
                      }
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: responsibilitiesController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Responsibilities',
                    hintText: 'Enter each responsibility on a new line',
                    alignLabelWithHint: true,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final responsibilities = responsibilitiesController.text
                    .split('\n')
                    .map((r) => r.trim())
                    .where((r) => r.isNotEmpty)
                    .toList();

                final newExperience = Experience(
                  company: companyController.text.trim(),
                  position: positionController.text.trim(),
                  location: locationController.text.trim().isEmpty ? null : locationController.text.trim(),
                  startDate: startDateController.text.trim(),
                  endDate: isCurrentJob ? '' : endDateController.text.trim(),
                  responsibilities: responsibilities,
                  isCurrentJob: isCurrentJob,
                );

                final cvProvider = Provider.of<CVProvider>(context, listen: false);
                
                if (isEditing && index != null) {
                  cvProvider.updateExperience(index, newExperience);
                } else {
                  cvProvider.addExperience(newExperience);
                }

                Navigator.of(context).pop();
              },
              child: Text(isEditing ? 'Update' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }
}
