import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../services/template_service.dart';
import '../services/localization_service.dart';
import 'template_preview_screen.dart';

class TemplateSelectionScreen extends StatefulWidget {
  const TemplateSelectionScreen({super.key});

  @override
  State<TemplateSelectionScreen> createState() => _TemplateSelectionScreenState();
}

class _TemplateSelectionScreenState extends State<TemplateSelectionScreen> {
  List<Map<String, dynamic>> templates = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  void _loadTemplates() async {
    try {
      final templateService = TemplateService();
      final loadedTemplates = await templateService.getTemplates();
      setState(() {
        templates = loadedTemplates;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('errors.load_failed'.tr),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

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
          child: Column(
            children: [
              // Custom App Bar
              _buildAppBar(context, isDark),
              
              // Content
              Expanded(
                child: isLoading
                    ? _buildLoadingState(isDark)
                    : templates.isEmpty
                        ? _buildEmptyState(isDark)
                        : _buildTemplateGrid(context, isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.arrow_back_ios,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'templates.title'.tr,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
                Text(
                  'templates.subtitle'.tr,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.white70 : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              isDark ? Colors.white : const Color(0xFF6366F1),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'common.loading'.tr,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white70 : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.dashboard_outlined,
            size: 64,
            color: isDark ? Colors.white30 : const Color(0xFFE5E7EB),
          ),
          const SizedBox(height: 16),
          Text(
            'No templates available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please check back later',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white60 : const Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateGrid(BuildContext context, bool isDark) {
    return AnimationLimiter(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.75,
          ),
          itemCount: templates.length,
          itemBuilder: (context, index) {
            final template = templates[index];
            return AnimationConfiguration.staggeredGrid(
              position: index,
              duration: const Duration(milliseconds: 400),
              columnCount: 2,
              child: SlideAnimation(
                verticalOffset: 30.0,
                child: FadeInAnimation(
                  child: _buildTemplateCard(context, template, isDark),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTemplateCard(BuildContext context, Map<String, dynamic> template, bool isDark) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TemplatePreviewScreen(template: template),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F2937) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Template Preview Image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _getTemplateColors(template['id']),
                  ),
                ),
                child: Stack(
                  children: [
                    // Placeholder for template preview
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.description_outlined,
                            size: 48,
                            color: Colors.white.withOpacity(0.8),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'templates.preview'.tr,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Premium badge (if applicable)
                    if (template['isPremium'] == true)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'PRO',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            
            // Template Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      template['name'] ?? 'Unknown Template',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Text(
                        template['description'] ?? 'No description available',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white70 : const Color(0xFF64748B),
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'templates.select'.tr,
                            style: const TextStyle(
                              color: Color(0xFF6366F1),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 12,
                          color: isDark ? Colors.white60 : const Color(0xFF9CA3AF),
                        ),
                      ],
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

  List<Color> _getTemplateColors(String templateId) {
    switch (templateId) {
      case 'template1':
        return [const Color(0xFF3B82F6), const Color(0xFF1E40AF)];
      case 'template2':
        return [const Color(0xFF6B7280), const Color(0xFF374151)];
      case 'template3':
        return [const Color(0xFFEF4444), const Color(0xFFF97316)];
      case 'template4':
        return [const Color(0xFF1F2937), const Color(0xFF111827)];
      case 'template5':
        return [const Color(0xFFF3F4F6), const Color(0xFFE5E7EB)];
      case 'template6':
        return [const Color(0xFF10B981), const Color(0xFF059669)];
      default:
        return [const Color(0xFF6366F1), const Color(0xFF8B5CF6)];
    }
  }
}
