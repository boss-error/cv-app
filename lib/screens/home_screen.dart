import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../providers/theme_provider.dart';
import 'personal_info_screen.dart';
import 'file_upload_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF0F172A),
                    const Color(0xFF1E293B),
                  ]
                : [
                    const Color(0xFFF8FAFC),
                    const Color(0xFFE2E8F0),
                  ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with theme toggle
                _buildHeader(context, isDark),
                
                const SizedBox(height: 40),
                
                // Welcome section
                _buildWelcomeSection(context, isDark),
                
                const SizedBox(height: 40),
                
                // Features section
                Expanded(
                  child: _buildFeaturesSection(context, isDark),
                ),
                
                const SizedBox(height: 30),
                
                // Action buttons
                _buildActionButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // App logo and title
        Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
              ),
              child: const Icon(
                Icons.description_outlined,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'CV Generator',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        
        // Theme toggle and language selector
        Row(
          children: [
            // Language selector
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF374151) : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark ? const Color(0xFF4B5563) : const Color(0xFFE5E7EB),
                ),
              ),
              child: Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
                  return DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: themeProvider.locale.languageCode,
                      icon: Icon(
                        Icons.keyboard_arrow_down,
                        color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                        size: 16,
                      ),
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF374151),
                        fontSize: 14,
                      ),
                      items: const [
                        DropdownMenuItem(value: 'en', child: Text('EN')),
                        DropdownMenuItem(value: 'ar', child: Text('AR')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          themeProvider.setLocale(Locale(value));
                        }
                      },
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Theme toggle
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return IconButton(
                  onPressed: () => themeProvider.toggleTheme(),
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      isDark ? Icons.light_mode : Icons.dark_mode,
                      key: ValueKey(isDark),
                      color: isDark ? Colors.amber : const Color(0xFF6366F1),
                    ),
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: isDark ? const Color(0xFF374151) : Colors.white,
                    padding: const EdgeInsets.all(12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: isDark ? const Color(0xFF4B5563) : const Color(0xFFE5E7EB),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWelcomeSection(BuildContext context, bool isDark) {
    return AnimationLimiter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: AnimationConfiguration.toStaggeredList(
          duration: const Duration(milliseconds: 600),
          childAnimationBuilder: (widget) => SlideAnimation(
            horizontalOffset: 50.0,
            child: FadeInAnimation(child: widget),
          ),
          children: [
            Text(
              'Create Your Professional CV',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
                height: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Build a stunning CV in minutes with our advanced templates and AI-powered suggestions. Choose from multiple professional designs and export as PDF.',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white70 : const Color(0xFF64748B),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesSection(BuildContext context, bool isDark) {
    final features = [
      {
        'icon': Icons.edit_outlined,
        'title': 'Manual Input',
        'description': 'Enter your information step by step with our guided form',
        'color': const Color(0xFF10B981),
      },
      {
        'icon': Icons.upload_file_outlined,
        'title': 'File Upload',
        'description': 'Upload your existing CV in PDF, DOC, or TXT format',
        'color': const Color(0xFF3B82F6),
      },
      {
        'icon': Icons.palette_outlined,
        'title': 'Multiple Templates',
        'description': 'Choose from professional templates with live preview',
        'color': const Color(0xFF8B5CF6),
      },
      {
        'icon': Icons.download_outlined,
        'title': 'PDF Export',
        'description': 'Download your CV as a high-quality PDF document',
        'color': const Color(0xFFF59E0B),
      },
    ];

    return AnimationLimiter(
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.1,
        ),
        itemCount: features.length,
        itemBuilder: (context, index) {
          final feature = features[index];
          return AnimationConfiguration.staggeredGrid(
            position: index,
            duration: const Duration(milliseconds: 600),
            columnCount: 2,
            child: ScaleAnimation(
              child: FadeInAnimation(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1F2937) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
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
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: (feature['color'] as Color).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          feature['icon'] as IconData,
                          color: feature['color'] as Color,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        feature['title'] as String,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Text(
                          feature['description'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white70 : const Color(0xFF64748B),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return AnimationLimiter(
      child: Column(
        children: AnimationConfiguration.toStaggeredList(
          duration: const Duration(milliseconds: 400),
          childAnimationBuilder: (widget) => SlideAnimation(
            verticalOffset: 30.0,
            child: FadeInAnimation(child: widget),
          ),
          children: [
            // Primary action - Manual input
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const PersonalInfoScreen(),
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
                    Icon(Icons.edit_outlined, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Start Creating CV',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Secondary action - File upload
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const FileUploadScreen(),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF6366F1),
                  side: const BorderSide(color: Color(0xFF6366F1)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.upload_file_outlined, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Upload Existing CV',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
