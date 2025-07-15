import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../providers/cv_provider.dart';
import '../services/file_service.dart';
import 'education_screen.dart';

class FileUploadScreen extends StatefulWidget {
  const FileUploadScreen({super.key});

  @override
  State<FileUploadScreen> createState() => _FileUploadScreenState();
}

class _FileUploadScreenState extends State<FileUploadScreen> {
  final FileService _fileService = FileService();
  File? _selectedFile;
  bool _isUploading = false;
  bool _isProcessing = false;
  String? _error;

  Future<void> _pickFile() async {
    try {
      setState(() {
        _error = null;
      });

      final file = await _fileService.pickDocument();
      if (file != null) {
        setState(() {
          _selectedFile = file;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  Future<void> _processFile() async {
    if (_selectedFile == null) return;

    setState(() {
      _isProcessing = true;
      _error = null;
    });

    try {
      final cvData = await _fileService.parseDocument(_selectedFile!);
      
      // Update the CV provider with parsed data
      final cvProvider = Provider.of<CVProvider>(context, listen: false);
      cvProvider.updatePersonalInfo(cvData.personalInfo);
      
      // Add education if available
      for (final education in cvData.education) {
        cvProvider.addEducation(education);
      }
      
      // Add experience if available
      for (final experience in cvData.experience) {
        cvProvider.addExperience(experience);
      }
      
      // Add skills if available
      if (cvData.skills.isNotEmpty) {
        cvProvider.updateSkills(cvData.skills);
      }

      // Navigate to next screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const EducationScreen(),
        ),
      );
    } catch (e) {
      setState(() {
        _error = 'Failed to process file: \$e';
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _removeFile() {
    setState(() {
      _selectedFile = null;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF111827) : const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text('Upload CV'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
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
                // Header
                Text(
                  'Upload Your Existing CV',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Upload your CV in PDF, DOC, or TXT format and we\'ll extract the information for you',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Supported formats
                _buildSupportedFormats(isDark),
                
                const SizedBox(height: 32),
                
                // Upload area
                _buildUploadArea(isDark),
                
                const SizedBox(height: 24),
                
                // Selected file display
                if (_selectedFile != null) _buildSelectedFile(isDark),
                
                // Error display
                if (_error != null) _buildErrorMessage(isDark),
                
                const SizedBox(height: 32),
                
                // Action buttons
                _buildActionButtons(isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSupportedFormats(bool isDark) {
    final formats = [
      {'icon': Icons.picture_as_pdf, 'name': 'PDF', 'color': const Color(0xFFEF4444)},
      {'icon': Icons.description, 'name': 'DOC', 'color': const Color(0xFF3B82F6)},
      {'icon': Icons.description_outlined, 'name': 'DOCX', 'color': const Color(0xFF3B82F6)},
      {'icon': Icons.text_snippet, 'name': 'TXT', 'color': const Color(0xFF10B981)},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Supported Formats',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: formats.map((format) {
            return Expanded(
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1F2937) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      format['icon'] as IconData,
                      color: format['color'] as Color,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      format['name'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF374151),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildUploadArea(bool isDark) {
    return GestureDetector(
      onTap: _isProcessing ? null : _pickFile,
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F2937) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _selectedFile != null 
                ? const Color(0xFF6366F1)
                : isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(32),
              ),
              child: const Icon(
                Icons.cloud_upload_outlined,
                color: Color(0xFF6366F1),
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _selectedFile != null ? 'File Selected' : 'Tap to Upload File',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedFile != null 
                  ? 'Tap to select a different file'
                  : 'Choose a PDF, DOC, DOCX, or TXT file',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedFile(bool isDark) {
    final fileName = _selectedFile!.path.split('/').last;
    final fileSize = _selectedFile!.lengthSync();
    final extension = _fileService.getFileExtension(_selectedFile!.path);
    
    IconData fileIcon;
    Color fileColor;
    
    switch (extension) {
      case 'pdf':
        fileIcon = Icons.picture_as_pdf;
        fileColor = const Color(0xFFEF4444);
        break;
      case 'doc':
      case 'docx':
        fileIcon = Icons.description;
        fileColor = const Color(0xFF3B82F6);
        break;
      case 'txt':
        fileIcon = Icons.text_snippet;
        fileColor = const Color(0xFF10B981);
        break;
      default:
        fileIcon = Icons.insert_drive_file;
        fileColor = const Color(0xFF6B7280);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: fileColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              fileIcon,
              color: fileColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF1F2937),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _fileService.formatFileSize(fileSize),
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _isProcessing ? null : _removeFile,
            icon: const Icon(Icons.close),
            color: isDark ? Colors.white70 : const Color(0xFF6B7280),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFEF4444).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: Color(0xFFEF4444),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _error!,
              style: const TextStyle(
                color: Color(0xFFEF4444),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isDark) {
    return Column(
      children: [
        if (_selectedFile != null)
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isProcessing ? null : _processFile,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isProcessing
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Processing...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Process File',
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
        
        const SizedBox(height: 16),
        
        // Manual input option
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const EducationScreen(),
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
            child: const Text(
              'Skip and Enter Manually',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
