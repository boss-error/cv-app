import 'package:flutter_test/flutter_test.dart';
import 'package:cv_generator_app/services/file_service.dart';
import 'package:cv_generator_app/models/cv_data.dart';
import 'dart:io';

void main() {
  group('PDF Parsing Tests', () {
    late FileService fileService;

    setUp(() {
      fileService = FileService();
    });

    test('should validate PDF file extension', () {
      expect(fileService.isValidDocumentType('test.pdf'), true);
      expect(fileService.isValidDocumentType('test.doc'), true);
      expect(fileService.isValidDocumentType('test.docx'), true);
      expect(fileService.isValidDocumentType('test.txt'), true);
      expect(fileService.isValidDocumentType('test.jpg'), false);
    });

    test('should extract data from text content', () {
      const testText = """
John Doe
Software Engineer
john.doe@email.com
+1234567890
123 Main Street, City, State

SUMMARY
Experienced software engineer with 5+ years in mobile development.

SKILLS
Flutter, Dart, Android, iOS, Firebase

EXPERIENCE
Senior Developer at Tech Corp
2020 - Present
Developed mobile applications using Flutter

EDUCATION
Computer Science Degree
University of Technology
2016 - 2020
      """;

      final cvData = fileService.extractDataFromText(testText);
      
      expect(cvData.personalInfo.fullName, contains('John Doe'));
      expect(cvData.personalInfo.email, 'john.doe@email.com');
      expect(cvData.personalInfo.phone, '+1234567890');
      expect(cvData.skills.isNotEmpty, true);
    });

    test('should format file size correctly', () {
      expect(fileService.formatFileSize(500), '500 B');
      expect(fileService.formatFileSize(1536), '1.5 KB');
      expect(fileService.formatFileSize(2097152), '2.0 MB');
    });

    test('should get file extension correctly', () {
      expect(fileService.getFileExtension('test.pdf'), 'pdf');
      expect(fileService.getFileExtension('document.docx'), 'docx');
      expect(fileService.getFileExtension('file.TXT'), 'txt');
    });
  });
}
