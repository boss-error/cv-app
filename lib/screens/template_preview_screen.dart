import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../providers/cv_provider.dart';
import '../providers/theme_provider.dart';
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
      // Try to load the preview image first
      final image = await TemplateService.getTemplatePreviewImage(widget.template.id);
      if (image != null) {
        setState(() {
          _previewImage = image;
          _isLoading = false;
        });
        return;
      }
      
      // If no preview image, try to load PDF from assets
      try {
        final pdfData = await rootBundle.load('assets/templates/template1.pdf');
        setState(() {
          _previewImage = pdfData.buffer.asUint8List();
          _isLoading = false;
        });
      } catch (pdfError) {
        setState(() {
          _isLoading = false;
        });
      }
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
          widget.template.name,
          style: TextStyle(
            color: isDark ? CupertinoColors.white : CupertinoColors.black,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Toggle preview mode
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                setState(() {
                  _showPdfPreview = !_showPdfPreview;
                });
              },
              child: Icon(
                _showPdfPreview ? CupertinoIcons.photo : CupertinoIcons.doc,
                color: const Color(0xFF007AFF),
                size: 22,
              ),
            ),
            
            // Select template
            Consumer<CVProvider>(
              builder: (context, cvProvider, child) {
                final isSelected = cvProvider.cvData.selectedTemplate == widget.template.id;
                return CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: _selectTemplate,
                  child: Icon(
                    isSelected ? CupertinoIcons.checkmark_circle_fill : CupertinoIcons.circle,
                    color: isSelected ? const Color(0xFF34C759) : const Color(0xFF007AFF),
                    size: 22,
                  ),
                );
              },
            ),
          ],
        ),
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
        child: CircularProgressIndicator(),
      );
    }

    if (_showPdfPreview) {
      // Show actual PDF preview or template image
      if (_previewImage != null) {
        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1F2937) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
            ),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark 
                      ? const Color(0xFF374151).withOpacity(0.5)
                      : const Color(0xFFF8FAFC),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.picture_as_pdf,
                      color: const Color(0xFFEF4444),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${widget.template.name} Template',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
              ),
              // Preview Image
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                  child: Image.memory(
                    _previewImage!,
                    fit: BoxFit.contain,
                    width: double.infinity,
                  ),
                ),
              ),
            ],
          ),
        );
      } else {
        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1F2937) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
            ),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.picture_as_pdf,
                  size: 64,
                  color: Color(0xFFEF4444),
                ),
                SizedBox(height: 16),
                Text(
                  'Loading Template Preview...',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } else {
      // Image preview mode
      if (_previewImage != null) {
        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1F2937) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(
              _previewImage!,
              fit: BoxFit.contain,
              width: double.infinity,
            ),
          ),
        );
      } else {
        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1F2937) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
            ),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.image_not_supported,
                  size: 64,
                  color: Color(0xFF9CA3AF),
                ),
                SizedBox(height: 16),
                Text(
                  'Preview not available',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }
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
                          ? const Color(0xFF10B981).withOpacity(0.1)
                          : const Color(0xFF6366F1).withOpacity(0.1),
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
