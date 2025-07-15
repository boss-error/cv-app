import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:crypto/crypto.dart';
import 'package:image/image.dart' as img;
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../models/cv_data.dart';

class FileService {
  static const List<String> allowedDocumentExtensions = ['pdf', 'doc', 'docx', 'txt'];
  static const List<String> allowedImageExtensions = ['jpg', 'jpeg', 'png', 'webp'];
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  
  final ImagePicker _imagePicker = ImagePicker();

  Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      if (status.isDenied) {
        final manageStatus = await Permission.manageExternalStorage.request();
        return manageStatus.isGranted;
      }
      return status.isGranted;
    } else if (Platform.isIOS) {
      final status = await Permission.photos.request();
      return status.isGranted;
    }
    return true;
  }

  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<File?> pickDocument() async {
    try {
      final hasPermission = await requestStoragePermission();
      if (!hasPermission) {
        throw Exception('Storage permission denied');
      }

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedDocumentExtensions,
        allowMultiple: false,
        withData: false,
        withReadStream: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final platformFile = result.files.first;
        
        if (platformFile.path == null) {
          throw Exception('File path is null');
        }
        
        final file = File(platformFile.path!);
        
        // Validate file exists
        if (!await file.exists()) {
          throw Exception('Selected file does not exist');
        }
        
        // Validate file size
        final fileSize = await file.length();
        if (fileSize > maxFileSize) {
          throw Exception('File size must be less than 10MB');
        }

        // Validate file extension
        if (!isValidDocumentType(file.path)) {
          throw Exception('Unsupported file format');
        }

        return file;
      }
      return null;
    } catch (e) {
      throw Exception('Failed to pick document: \$e');
    }
  }

  Future<File?> pickImageFromGallery() async {
    try {
      final hasPermission = await requestStoragePermission();
      if (!hasPermission) {
        throw Exception('Storage permission denied');
      }

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        final file = File(image.path);
        
        // Validate file size
        final fileSize = await file.length();
        if (fileSize > maxImageSize) {
          throw Exception('Image size must be less than 5MB');
        }

        // Process and optimize image
        return await _processImage(file);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to pick image from gallery: \$e');
    }
  }

  Future<File?> pickImageFromCamera() async {
    try {
      final hasPermission = await requestCameraPermission();
      if (!hasPermission) {
        throw Exception('Camera permission denied');
      }

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        final file = File(image.path);
        
        // Validate file size
        final fileSize = await file.length();
        if (fileSize > maxImageSize) {
          throw Exception('Image size must be less than 5MB');
        }

        // Process and optimize image
        return await _processImage(file);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to capture image: \$e');
    }
  }

  Future<File> _processImage(File imageFile) async {
    try {
      // Read image
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Resize if needed (max 512x512 for profile photos)
      img.Image resized = image;
      if (image.width > 512 || image.height > 512) {
        resized = img.copyResize(
          image,
          width: image.width > image.height ? 512 : null,
          height: image.height > image.width ? 512 : null,
        );
      }

      // Convert to JPEG with compression
      final compressedBytes = img.encodeJpg(resized, quality: 85);
      
      // Save to app directory
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = 'profile_\${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedFile = File(path.join(appDir.path, 'images', fileName));
      
      // Create directory if it doesn't exist
      await savedFile.parent.create(recursive: true);
      
      // Write compressed image
      await savedFile.writeAsBytes(compressedBytes);
      
      return savedFile;
    } catch (e) {
      throw Exception('Failed to process image: \$e');
    }
  }

  Future<CVData> parseDocument(File file) async {
    try {
      final extension = getFileExtension(file.path);
      
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
      throw Exception('Failed to parse document: \$e');
    }
  }

  Future<CVData> _parseTxtFile(File file) async {
    try {
      final content = await file.readAsString();
      return extractDataFromText(content);
    } catch (e) {
      throw Exception('Failed to read text file: \$e');
    }
  }

  Future<CVData> _parsePdfFile(File file) async {
    try {
      // Load the PDF document using Syncfusion
      final Uint8List bytes = await file.readAsBytes();
      final PdfDocument document = PdfDocument(inputBytes: bytes);
      
      // Extract text from all pages
      String extractedText = '';
      
      // Create text extractor
      final PdfTextExtractor extractor = PdfTextExtractor(document);
      
      // Extract text from all pages
      for (int i = 0; i < document.pages.count; i++) {
        final String pageText = extractor.extractText(startPageIndex: i, endPageIndex: i);
        extractedText += pageText + '
';
      }
      
      // Dispose the document
      document.dispose();
      
      // If no text was extracted, return basic structure
      if (extractedText.trim().isEmpty) {
        return CVData(
          personalInfo: PersonalInfo(
            fullName: 'PDF Document Uploaded',
            email: 'email@example.com',
            phone: '+1234567890',
            address: 'Address from PDF',
            profileSummary: 'PDF document processed but text extraction failed',
          ),
        );
      }
      
      // Extract CV data from the text
      return _extractDataFromText(extractedText);
    } catch (e) {
      throw Exception('Failed to parse PDF file: \$e');
    }
  }

  Future<CVData> _parseDocFile(File file) async {
    try {
      // For now, return basic structure
      // In a real implementation, you would use docx_to_text package
      // final text = await DocxToText.fromFile(file.path);
      // return extractDataFromText(text);
      
      return CVData(
        personalInfo: PersonalInfo(
          fullName: 'DOC parsing not fully implemented',
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
    final lines = content.split('\n').where((line) => line.trim().isNotEmpty).toList();
    
    String fullName = '';
    String email = '';
    String phone = '';
    String address = '';
    String? profileSummary;
    String? linkedIn;
    String? website;
    String? github;
    List<String> skills = [];
    List<Education> education = [];
    List<Experience> experience = [];

    // Enhanced pattern matching for CV elements
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

      // Extract LinkedIn
      if (lowerLine.contains('linkedin')) {
        final linkedInRegex = RegExp(r'linkedin\.com/in/[\w\-]+', caseSensitive: false);
        final match = linkedInRegex.firstMatch(line);
        if (match != null) {
          linkedIn = 'https://\${match.group(0)}';
        }
      }

      // Extract GitHub
      if (lowerLine.contains('github')) {
        final githubRegex = RegExp(r'github\.com/[\w\-]+', caseSensitive: false);
        final match = githubRegex.firstMatch(line);
        if (match != null) {
          github = 'https://\${match.group(0)}';
        }
      }

      // Extract website
      if (website == null && (lowerLine.contains('http') || lowerLine.contains('www'))) {
        final urlRegex = RegExp(r'https?://[\w\-\._~:/?#\[\]@!\$&\(\)\*\+,;=]+');
        final match = urlRegex.firstMatch(line);
        if (match != null) {
          website = match.group(0);
        }
      }

      // Extract name (usually first non-empty line that doesn't contain common keywords)
      if (fullName.isEmpty && line.length > 2 && !line.contains('@') && 
          !lowerLine.contains('cv') && !lowerLine.contains('resume') &&
          !lowerLine.contains('curriculum') && !lowerLine.contains('vitae')) {
        fullName = line;
      }

      // Extract skills
      if (lowerLine.contains('skill') || lowerLine.contains('competenc') || lowerLine.contains('technolog')) {
        for (int j = i + 1; j < lines.length && j < i + 5; j++) {
          final skillLine = lines[j].trim();
          if (skillLine.isNotEmpty && !skillLine.toLowerCase().contains('experience') && 
              !skillLine.toLowerCase().contains('education')) {
            final skillItems = skillLine.split(RegExp(r'[,;|•]')).map((s) => s.trim()).where((s) => s.isNotEmpty);
            skills.addAll(skillItems);
          }
        }
      }

      // Extract summary/objective
      if (profileSummary == null && (lowerLine.contains('summary') || lowerLine.contains('objective') || 
          lowerLine.contains('profile') || lowerLine.contains('about'))) {
        for (int j = i + 1; j < lines.length && j < i + 3; j++) {
          final summaryLine = lines[j].trim();
          if (summaryLine.isNotEmpty && summaryLine.length > 20) {
            profileSummary = summaryLine;
            break;
          }
        }
      }
    }

    // Set default address if not found
    if (address.isEmpty) {
      address = 'Address not specified';
    }

    return CVData(
      personalInfo: PersonalInfo(
        fullName: fullName.isNotEmpty ? fullName : 'Name not found',
        email: email.isNotEmpty ? email : 'email@example.com',
        phone: phone.isNotEmpty ? phone : '+1234567890',
        address: address,
        profileSummary: profileSummary,
        linkedIn: linkedIn,
        website: website,
        github: github,
      ),
      skills: skills.take(15).toList(),
      education: education,
      experience: experience,
    );
  }

  String getFileExtension(String filePath) {
    return path.extension(filePath).toLowerCase().replaceFirst('.', '');
  }

  bool isValidDocumentType(String filePath) {
    final extension = getFileExtension(filePath);
    return allowedDocumentExtensions.contains(extension);
  }

  bool isValidImageType(String filePath) {
    final extension = getFileExtension(filePath);
    return allowedImageExtensions.contains(extension);
  }

  String formatFileSize(int bytes) {
    if (bytes < 1024) return '\$bytes B';
    if (bytes < 1024 * 1024) return '\${(bytes / 1024).toStringAsFixed(1)} KB';
    return '\${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String generateFileHash(File file) {
    final bytes = file.readAsBytesSync();
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Ignore deletion errors
    }
  }

  Future<String> saveFileToAppDirectory(File file, String subfolder) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = path.basename(file.path);
      final savedFile = File(path.join(appDir.path, subfolder, fileName));
      
      await savedFile.parent.create(recursive: true);
      await file.copy(savedFile.path);
      
      return savedFile.path;
    } catch (e) {
      throw Exception('Failed to save file: \$e');
    }
  }
}
