import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../providers/cv_provider.dart';
import '../services/template_service.dart';
import '../services/api_service.dart';
import 'template_preview_screen.dart';
import 'task_status_screen.dart';

class TemplateSelectionScreen extends StatefulWidget {
  const TemplateSelectionScreen({super.key});

  @override
  State<TemplateSelectionScreen> createState() => _TemplateSelectionScreenState();
}

class _TemplateSelectionScreenState extends State<TemplateSelectionScreen> {
  final TemplateService _templateService = TemplateService();
  List<CVTemplate> _templates = [];
  bool _isLoading = true;
  String? _error;
  String? _selectedTemplateId;

  @override
  void initState() {
    super.initState();
    _loadTemplates();
    _loadSelectedTemplate();
  }

  void _loadSelectedTemplate() {
    final cvProvider = Provider.of<CVProvider>(context, listen: false);
    _selectedTemplateId = cvProvider.cvData.selectedTemplate;
  }

  Future<void> _loadTemplates() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final templates = await _templateService.loadTemplates();
      
      setState(() {
        _templates = templates;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _selectTemplate(String templateId) {
    setState(() {
      _selectedTemplateId = templateId;
    });
    
    final cvProvider = Provider.of<CVProvider>(context, listen: false);
    cvProvider.selectTemplate(templateId);
  }

  void _previewTemplate(CVTemplate template) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TemplatePreviewScreen(template: template),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF111827) : const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text('Choose Template'),
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
      body: _buildBody(isDark),
      bottomNavigationBar: _selectedTemplateId != null 
          ? _buildBottomBar(isDark)
          : null,
    );
  }

  Widget _buildBody(bool isDark) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
            ),
            SizedBox(height: 16),
            Text('Loading templates...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: isDark ? Colors.white54 : const Color(0xFF9CA3AF),
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load templates',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : const Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadTemplates,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

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
                'Choose Your Template',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select a professional template that best represents your style',
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Templates grid
              _buildTemplatesGrid(isDark),
            ],
          ),
        ),
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
              'Step 6 of 6',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.white70 
                    : const Color(0xFF6B7280),
              ),
            ),
            const Text(
              'Template Selection',
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
          value: 6/6,
          backgroundColor: const Color(0xFFE5E7EB),
          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
          minHeight: 4,
        ),
      ],
    );
  }

  Widget _buildTemplatesGrid(bool isDark) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.7,
      ),
      itemCount: _templates.length,
      itemBuilder: (context, index) {
        final template = _templates[index];
        final isSelected = _selectedTemplateId == template.id;
        
        return AnimationConfiguration.staggeredGrid(
          position: index,
          duration: const Duration(milliseconds: 600),
          columnCount: 2,
          child: ScaleAnimation(
            child: FadeInAnimation(
              child: _buildTemplateCard(template, isSelected, isDark),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTemplateCard(CVTemplate template, bool isSelected, bool isDark) {
    return GestureDetector(
      onTap: () => _selectTemplate(template.id),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F2937) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
                ? const Color(0xFF6366F1)
                : isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
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
            // Template preview
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Stack(
                  children: [
                    // Template preview image
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      child: FutureBuilder<Uint8List?>(
                        future: _templateService.getTemplatePreviewImage(template.id),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                              ),
                            );
                          }
                          
                          if (snapshot.hasData && snapshot.data != null) {
                            return Image.memory(
                              snapshot.data!,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            );
                          }
                          
                          // Fallback preview
                          return _buildFallbackPreview(template, isDark);
                        },
                      ),
                    ),
                    
                    // Selection indicator
                    if (isSelected)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            color: Color(0xFF6366F1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    
                    // Preview button
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () => _previewTemplate(template),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.visibility,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Template info
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      template.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF1F2937),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Text(
                        template.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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

  Widget _buildFallbackPreview(CVTemplate template, bool isDark) {
    final colors = {
      'template1': const Color(0xFF3B82F6),
      'template2': const Color(0xFF6B7280),
      'template3': const Color(0xFFF59E0B),
      'template4': const Color(0xFF1F2937),
      'template5': const Color(0xFF9CA3AF),
      'template6': const Color(0xFF10B981),
    };
    
    final color = colors[template.id] ?? const Color(0xFF6366F1);
    
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: color.withOpacity(0.1),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 40,
            color: color,
            child: Center(
              child: Text(
                'SAMPLE CV',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 8,
                    color: color.withOpacity(0.3),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 80,
                    height: 6,
                    color: color.withOpacity(0.2),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    height: 4,
                    color: color.withOpacity(0.1),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    width: double.infinity,
                    height: 4,
                    color: color.withOpacity(0.1),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    width: 100,
                    height: 4,
                    color: color.withOpacity(0.1),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
          ),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 56,
            child: ElevatedButton(
              onPressed: () async {
                final cvProvider = Provider.of<CVProvider>(context, listen: false);
                
                try {
                  // Show loading
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                  
                  // Generate CV
                  final apiService = ApiService();
                  final taskId = await apiService.generateCV(
                    cvData: cvProvider.cvData,
                    templateName: _selectedTemplateId!,
                  );
                  
                  // Hide loading
                  Navigator.of(context).pop();
                  
                  // Navigate to task status
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => TaskStatusScreen(taskId: taskId),
                    ),
                  );
                } catch (e) {
                  // Hide loading
                  Navigator.of(context).pop();
                  
                  // Show error
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to generate CV: \$e'),
                      backgroundColor: const Color(0xFFEF4444),
                    ),
                  );
                }
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
                  'Generate CV',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.auto_awesome, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
