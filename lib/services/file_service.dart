import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/cv_data.dart';

class FileService {
  static const List<String> allowedExtensions = ['pdf', 'doc', 'docx', 'txt'];

  Future<bool> requestStoragePermission() async {
    final status = await Permission.storage.request();
    return status.isGranted;
  }

  Future<File?> pickFile() async {
    try {
      // Request permission first
      final hasPermission = await requestStoragePermission();
      if (!hasPermission) {
        throw Exception('Storage permission denied');
      }

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = File(result.files.first.path!);
        
        // Validate file size (max 10MB)
        final fileSize = await file.length();
        if (fileSize > 10 * 1024 * 1024) {
          throw Exception('File size must be less than 10MB');
        }

        return file;
      }
      return null;
    } catch (e) {
      throw Exception('Failed to pick file: \$e');
    }
  }

  Future<CVData> parseFile(File file) async {
    try {
      final extension = file.path.split('.').last.toLowerCase();
      
      switch (extension) {
        case 'txt':
          return await _parseTxtFile(file);
        case 'pdf':
          return await _parsePdfFile(file);
        case 'doc':
        case 'docx':
          return await _parseDocFile(file);
        default:
          throw Exception('Unsupported file format: \$extension');
      }
    } catch (e) {
      throw Exception('Failed to parse file: \$e');
    }
  }

  Future<CVData> _parseTxtFile(File file) async {
    try {
      final content = await file.readAsString();
      return _extractDataFromText(content);
    } catch (e) {
      throw Exception('Failed to read text file: \$e');
    }
  }

  Future<CVData> _parsePdfFile(File file) async {
    // For PDF parsing, you would typically use a library like pdf_text
    // For now, we'll return a basic structure
    try {
      // This is a placeholder - in a real app, you'd use a PDF parsing library
      return CVData(
        personalInfo: PersonalInfo(
          fullName: 'Extracted from PDF',
          email: 'email@example.com',
          phone: '+1234567890',
          address: 'Address from PDF',
        ),
      );
    } catch (e) {
      throw Exception('Failed to parse PDF file: \$e');
    }
  }

  Future<CVData> _parseDocFile(File file) async {
    // For DOC/DOCX parsing, you would typically use a library
    // For now, we'll return a basic structure
    try {
      // This is a placeholder - in a real app, you'd use a DOC parsing library
      return CVData(
        personalInfo: PersonalInfo(
          fullName: 'Extracted from DOC',
          email: 'email@example.com',
          phone: '+1234567890',
          address: 'Address from DOC',
        ),
      );
    } catch (e) {
      throw Exception('Failed to parse DOC file: \$e');
    }
  }

  CVData _extractDataFromText(String content) {
    // Basic text parsing logic
    final lines = content.split('\n').where((line) => line.trim().isNotEmpty).toList();
    
    String fullName = '';
    String email = '';
    String phone = '';
    String address = '';
    List<String> skills = [];
    List<Education> education = [];
    List<Experience> experience = [];

    // Simple pattern matching for common CV elements
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      final lowerLine = line.toLowerCase();

      // Extract email
      if (line.contains('@') && email.isEmpty) {
        final emailRegex = RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b');
        final match = emailRegex.firstMatch(line);
        if (match != null) {
          email = match.group(0)!;
        }
      }

      // Extract phone
      if (phone.isEmpty && (lowerLine.contains('phone') || lowerLine.contains('mobile') || lowerLine.contains('tel'))) {
        final phoneRegex = RegExp(r'[+]?[0-9][0-9\s\-\(\)]{8,}');
        final match = phoneRegex.firstMatch(line);
        if (match != null) {
          phone = match.group(0)!.replaceAll(RegExp(r'[^+0-9]'), '');
        }
      }

      // Extract name (usually first non-empty line)
      if (fullName.isEmpty && line.length > 2 && !line.contains('@') && !lowerLine.contains('cv') && !lowerLine.contains('resume')) {
        fullName = line;
      }

      // Extract skills
      if (lowerLine.contains('skill') || lowerLine.contains('competenc') || lowerLine.contains('technolog')) {
        // Look for the next few lines for skills
        for (int j = i + 1; j < lines.length && j < i + 5; j++) {
          final skillLine = lines[j].trim();
          if (skillLine.isNotEmpty && !skillLine.toLowerCase().contains('experience') && !skillLine.toLowerCase().contains('education')) {
            final skillItems = skillLine.split(RegExp(r'[,;|]')).map((s) => s.trim()).where((s) => s.isNotEmpty);
            skills.addAll(skillItems);
          }
        }
      }
    }

    // If no specific address found, use a placeholder
    if (address.isEmpty) {
      address = 'Address not specified';
    }

    return CVData(
      personalInfo: PersonalInfo(
        fullName: fullName.isNotEmpty ? fullName : 'Name not found',
        email: email.isNotEmpty ? email : 'email@example.com',
        phone: phone.isNotEmpty ? phone : '+1234567890',
        address: address,
      ),
      skills: skills.take(10).toList(), // Limit to 10 skills
      education: education,
      experience: experience,
    );
  }

  String getFileExtension(String filePath) {
    return filePath.split('.').last.toLowerCase();
  }

  bool isValidFileType(String filePath) {
    final extension = getFileExtension(filePath);
    return allowedExtensions.contains(extension);
  }

  String formatFileSize(int bytes) {
    if (bytes < 1024) return '\$bytes B';
    if (bytes < 1024 * 1024) return '\${(bytes / 1024).toStringAsFixed(1)} KB';
    return '\${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
