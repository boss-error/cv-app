
import 'dart:io';
import 'lib/services/file_service.dart';

void main() async {
  final fileService = FileService();
  
  // Test text extraction with sample CV text
  final sampleCVText = """
John Doe
Software Engineer
Email: john.doe@example.com
Phone: +1234567890
Address: 123 Main St, City, Country

SUMMARY
Experienced software engineer with 5+ years in mobile app development.

SKILLS
Flutter, Dart, JavaScript, Python, React Native, Firebase

EXPERIENCE
Senior Flutter Developer
Tech Company Inc.
2022 - Present
- Developed mobile applications using Flutter
- Led a team of 3 developers
- Implemented CI/CD pipelines

Junior Developer
StartUp Co.
2020 - 2022
- Built web applications using React
- Collaborated with design team

EDUCATION
Bachelor of Computer Science
University of Technology
2016 - 2020
Computer Science
""";

  try {
    // Create a temporary text file to test the extraction
    final tempFile = File('/tmp/test_cv.txt');
    await tempFile.writeAsString(sampleCVText);
    
    final cvData = await fileService.parseDocument(tempFile);
    
    print('=== TEXT EXTRACTION TEST RESULTS ===');
    print('Name: \${cvData.personalInfo.fullName}');
    print('Email: \${cvData.personalInfo.email}');
    print('Phone: \${cvData.personalInfo.phone}');
    print('Address: \${cvData.personalInfo.address}');
    print('Summary: \${cvData.personalInfo.profileSummary}');
    print('Skills: \${cvData.skills.join(", ")}');
    print('Education count: \${cvData.education.length}');
    print('Experience count: \${cvData.experience.length}');
    
    if (cvData.education.isNotEmpty) {
      print('First Education: \${cvData.education.first.degree} at \${cvData.education.first.institution}');
    }
    
    if (cvData.experience.isNotEmpty) {
      print('First Experience: \${cvData.experience.first.position} at \${cvData.experience.first.company}');
    }
    
    print('\n✅ Text extraction test completed successfully!');
  } catch (e) {
    print('❌ Text extraction test failed: \$e');
  }
}
