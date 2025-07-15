import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cv_provider.dart';
import '../services/template_service.dart';
import '../models/cv_data.dart';

class TemplatePreviewScreen extends StatefulWidget {
  final CVTemplate template;

  const TemplatePreviewScreen({
    super.key,
    required this.template,
  });

  @override
  State<TemplatePreviewScreen> createState() => _TemplatePreviewScreenState();
}

class _TemplatePreviewScreenState extends State<TemplatePreviewScreen> {
  final TemplateService _templateService = TemplateService();
  bool _showPdfPreview = true;
  Uint8List? _previewImage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreview();
  }

  Future<void> _loadPreview() async {
    try {
      final image = await TemplateService.getTemplatePreviewImage(widget.template.id);
      setState(() {
        _previewImage = image;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _selectTemplate() {
    final cvProvider = Provider.of<CVProvider>(context, listen: false);
    cvProvider.selectTemplate(widget.template.id);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Template "\${widget.template.name}" selected!'),
        backgroundColor: const Color(0xFF10B981),
      ),
    );
    
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF111827) : const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: Text(widget.template.name),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Toggle preview mode
          IconButton(
            onPressed: () {
              setState(() {
                _showPdfPreview = !_showPdfPreview;
              });
            },
            icon: Icon(
              _showPdfPreview ? Icons.image : Icons.picture_as_pdf,
              color: const Color(0xFF6366F1),
            ),
            tooltip: _showPdfPreview ? 'Show Image Preview' : 'Show PDF Preview',
          ),
          
          // Select template
          Consumer<CVProvider>(
            builder: (context, cvProvider, child) {
              final isSelected = cvProvider.cvData.selectedTemplate == widget.template.id;
              return IconButton(
                onPressed: _selectTemplate,
                icon: Icon(
                  isSelected ? Icons.check_circle : Icons.check_circle_outline,
                  color: isSelected ? const Color(0xFF10B981) : const Color(0xFF6366F1),
                ),
                tooltip: isSelected ? 'Selected' : 'Select Template',
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Preview mode toggle
          _buildPreviewModeToggle(isDark),
          
          // Preview content
          Expanded(
            child: _buildPreviewContent(isDark),
          ),
          
          // Template info and actions
          _buildBottomInfo(isDark),
        ],
      ),
    );
  }

  Widget _buildPreviewModeToggle(bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _showPdfPreview = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _showPdfPreview 
                      ? const Color(0xFF6366F1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.picture_as_pdf,
                      size: 20,
                      color: _showPdfPreview 
                          ? Colors.white
                          : isDark ? Colors.white70 : const Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'PDF Preview',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _showPdfPreview 
                            ? Colors.white
                            : isDark ? Colors.white70 : const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _showPdfPreview = false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !_showPdfPreview 
                      ? const Color(0xFF6366F1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image,
                      size: 20,
                      color: !_showPdfPreview 
                          ? Colors.white
                          : isDark ? Colors.white70 : const Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Image Preview',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: !_showPdfPreview 
                            ? Colors.white
                            : isDark ? Colors.white70 : const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewContent(bool isDark) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
            ),
            SizedBox(height: 16),
            Text('Loading preview...'),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark 
                ? Colors.black.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: _showPdfPreview 
            ? _buildPdfPreview(isDark)
            : _buildImagePreview(isDark),
      ),
    );
  }

  Widget _buildPdfPreview(bool isDark) {
    // For PDF preview, we'll show a placeholder since flutter_pdfview 
    // might not work well in web. In a real app, you'd use flutter_pdfview
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: isDark ? const Color(0xFF374151) : const Color(0xFFF9FAFB),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.picture_as_pdf,
            size: 64,
            color: isDark ? Colors.white54 : const Color(0xFF9CA3AF),
          ),
          const SizedBox(height: 16),
          Text(
            'PDF Preview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Full PDF preview would be available\nin the mobile app',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white70 : const Color(0xFF6B7280),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              widget.template.file,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6366F1),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview(bool isDark) {
    if (_previewImage != null) {
      return InteractiveViewer(
        panEnabled: true,
        scaleEnabled: true,
        minScale: 0.5,
        maxScale: 3.0,
        child: Image.memory(
          _previewImage!,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.contain,
        ),
      );
    }

    // Fallback preview
    return _buildFallbackPreview(isDark);
  }

  Widget _buildFallbackPreview(bool isDark) {
    final colors = {
      'template1': const Color(0xFF3B82F6),
      'template2': const Color(0xFF6B7280),
      'template3': const Color(0xFFF59E0B),
      'template4': const Color(0xFF1F2937),
      'template5': const Color(0xFF9CA3AF),
      'template6': const Color(0xFF10B981),
    };
    
    final color = colors[widget.template.id] ?? const Color(0xFF6366F1);
    
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: color.withValues(alpha: 0.05),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              height: 80,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  'JOHN DOE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Contact info
            Container(
              width: double.infinity,
              height: 20,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Sections
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Experience section
                  Container(
                    width: 120,
                    height: 16,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 12),
                   ...List.generate(3, (index) => Padding(
                     padding: const EdgeInsets.only(bottom: 8),
                     child: Container(
                       width: double.infinity,
                       height: 12,
                       decoration: BoxDecoration(
                         color: color.withValues(alpha: 0.1),
                         borderRadius: BorderRadius.circular(4),
                       ),
                     ),
                   )),
                   
                   const SizedBox(height: 24),
                   
                   // Education section
                   Container(
                     width: 100,
                     height: 16,
                     decoration: BoxDecoration(
                       color: color,
                       borderRadius: BorderRadius.circular(4),
                     ),
                   ),
                   const SizedBox(height: 12),
                   ...List.generate(2, (index) => Padding(
                     padding: const EdgeInsets.only(bottom: 8),
                     child: Container(
                       width: double.infinity,
                       height: 12,
                       decoration: BoxDecoration(
                         color: color.withValues(alpha: 0.1),
                         borderRadius: BorderRadius.circular(4),
                       ),
                     ),
                   )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomInfo(bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.template.name,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.template.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              Consumer<CVProvider>(
                builder: (context, cvProvider, child) {
                  final isSelected = cvProvider.cvData.selectedTemplate == widget.template.id;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? const Color(0xFF10B981).withValues(alpha: 0.1)
                          : const Color(0xFF6366F1).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isSelected ? 'Selected' : 'Available',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? const Color(0xFF10B981) : const Color(0xFF6366F1),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Select button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: Consumer<CVProvider>(
              builder: (context, cvProvider, child) {
                final isSelected = cvProvider.cvData.selectedTemplate == widget.template.id;
                return ElevatedButton(
                  onPressed: isSelected ? null : _selectTemplate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSelected 
                        ? const Color(0xFF10B981)
                        : const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isSelected ? Icons.check : Icons.check_circle_outline,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isSelected ? 'Selected' : 'Select Template',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
