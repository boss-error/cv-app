import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class TemplateService {
  static const String _metaPath = 'assets/templates/meta.json';
  
  Future<List<CVTemplate>> loadTemplates() async {
    try {
      final String jsonString = await rootBundle.loadString(_metaPath);
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> templatesJson = jsonData['templates'];
      
      return templatesJson.map((json) => CVTemplate.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load templates: \$e');
    }
  }
  
  Future<Uint8List?> getTemplatePreviewImage(String templateId) async {
    try {
      // Try to load existing preview image
      final String imagePath = 'assets/templates/previews/\${templateId}_preview.png';
      try {
        final ByteData imageData = await rootBundle.load(imagePath);
        return imageData.buffer.asUint8List();
      } catch (e) {
        // If preview doesn't exist, generate it from PDF
        return await _generatePreviewFromPdf(templateId);
      }
    } catch (e) {
      print('Error loading template preview: \$e');
      return null;
    }
  }
  
  Future<Uint8List?> _generatePreviewFromPdf(String templateId) async {
    try {
      // Load the PDF template
      final String pdfPath = 'assets/templates/\${templateId}.pdf';
      final ByteData pdfData = await rootBundle.load(pdfPath);
      
      // Convert PDF to image (this is a simplified approach)
      // In a real app, you'd use a proper PDF rendering library
      return await _createSamplePreview(templateId);
    } catch (e) {
      print('Error generating preview from PDF: \$e');
      return await _createSamplePreview(templateId);
    }
  }
  
  Future<Uint8List> _createSamplePreview(String templateId) async {
    // Create a sample preview image using PDF widgets
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Container(
            width: double.infinity,
            height: double.infinity,
            decoration: pw.BoxDecoration(
              color: _getTemplateColor(templateId),
              border: pw.Border.all(color: PdfColors.grey300),
            ),
            child: pw.Padding(
              padding: const pw.EdgeInsets.all(20),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Header
                  pw.Container(
                    width: double.infinity,
                    height: 60,
                    color: _getAccentColor(templateId),
                    child: pw.Center(
                      child: pw.Text(
                        'JOHN DOE',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                      ),
                    ),
                  ),
                  
                  pw.SizedBox(height: 20),
                  
                  // Contact Info
                  pw.Text(
                    'john.doe@email.com | +1 (555) 123-4567',
                    style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
                  ),
                  
                  pw.SizedBox(height: 20),
                  
                  // Experience Section
                  pw.Text(
                    'EXPERIENCE',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: _getAccentColor(templateId),
                    ),
                  ),
                  pw.Divider(color: _getAccentColor(templateId)),
                  
                  pw.SizedBox(height: 10),
                  
                  pw.Text(
                    'Senior Software Engineer',
                    style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    'Tech Company Inc. | 2020 - Present',
                    style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                  ),
                  
                  pw.SizedBox(height: 15),
                  
                  // Education Section
                  pw.Text(
                    'EDUCATION',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: _getAccentColor(templateId),
                    ),
                  ),
                  pw.Divider(color: _getAccentColor(templateId)),
                  
                  pw.SizedBox(height: 10),
                  
                  pw.Text(
                    'Bachelor of Computer Science',
                    style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    'University Name | 2016 - 2020',
                    style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                  ),
                  
                  pw.SizedBox(height: 15),
                  
                  // Skills Section
                  pw.Text(
                    'SKILLS',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: _getAccentColor(templateId),
                    ),
                  ),
                  pw.Divider(color: _getAccentColor(templateId)),
                  
                  pw.SizedBox(height: 10),
                  
                  pw.Wrap(
                    spacing: 10,
                    runSpacing: 5,
                    children: [
                      'Flutter', 'Dart', 'JavaScript', 'React', 'Node.js'
                    ].map((skill) => pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: pw.BoxDecoration(
                        color: _getAccentColor(templateId).shade(0.1),
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Text(
                        skill,
                        style: pw.TextStyle(fontSize: 10),
                      ),
                    )).toList(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
    
    // Convert to image
    final Uint8List pdfBytes = await pdf.save();
    
    // Convert PDF to PNG (simplified - in real app use proper PDF renderer)
    return await Printing.convertHtml(
      format: PdfPageFormat.a4,
      html: '<div style="width: 210mm; height: 297mm; background: white;"></div>',
    );
  }
  
  PdfColor _getTemplateColor(String templateId) {
    switch (templateId) {
      case 'template1':
        return PdfColors.blue50;
      case 'template2':
        return PdfColors.grey50;
      case 'template3':
        return PdfColors.orange50;
      case 'template4':
        return PdfColors.grey900;
      case 'template5':
        return PdfColors.white;
      case 'template6':
        return PdfColors.green50;
      default:
        return PdfColors.white;
    }
  }
  
  PdfColor _getAccentColor(String templateId) {
    switch (templateId) {
      case 'template1':
        return PdfColors.blue;
      case 'template2':
        return PdfColors.grey700;
      case 'template3':
        return PdfColors.orange;
      case 'template4':
        return PdfColors.black;
      case 'template5':
        return PdfColors.grey800;
      case 'template6':
        return PdfColors.green;
      default:
        return PdfColors.blue;
    }
  }
}

class CVTemplate {
  final String id;
  final String name;
  final String description;
  final String file;
  final String checksum;

  CVTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.file,
    required this.checksum,
  });

  factory CVTemplate.fromJson(Map<String, dynamic> json) {
    return CVTemplate(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      file: json['file'],
      checksum: json['checksum'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'file': file,
      'checksum': checksum,
    };
  }
}
