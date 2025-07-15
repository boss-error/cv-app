import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import '../models/cv_data.dart';

class TemplateService {
  
  // Cache for loaded templates
  static List<Map<String, dynamic>>? _cachedTemplates;
  
  // Load templates from meta.json
  static Future<List<Map<String, dynamic>>> _loadTemplatesFromMeta() async {
    try {
      final jsonString = await rootBundle.loadString('assets/templates/meta.json');
      final jsonData = json.decode(jsonString);
      final templates = jsonData['templates'] as List;
      
      return templates.map((template) {
        return {
          'id': template['id'],
          'name': template['name'],
          'description': template['description'],
          'preview': 'assets/templates/previews/${template['id']}.png',
          'file': 'assets/templates/${template['file']}',
          'config': template['config'],
          'category': _getCategoryFromId(template['id']),
          'isPremium': _isPremiumTemplate(template['id']),
        };
      }).toList();
    } catch (e) {
      // Fallback to default templates if meta.json fails to load
      return _getDefaultTemplates();
    }
  }
  
  // Get category from template ID
  static String _getCategoryFromId(String id) {
    if (id.contains('modern')) return 'modern';
    if (id.contains('classic')) return 'classic';
    if (id.contains('creative')) return 'creative';
    if (id.contains('professional')) return 'professional';
    if (id.contains('minimalist')) return 'minimalist';
    if (id.contains('tech')) return 'tech';
    return 'general';
  }
  
  // Check if template is premium
  static bool _isPremiumTemplate(String id) {
    // For now, make templates 3, 5, 6 premium
    return ['template3', 'template5', 'template6'].contains(id);
  }
  
  // Fallback default templates
  static List<Map<String, dynamic>> _getDefaultTemplates() {
    return [
      {
        'id': 'template1',
        'name': 'Modern Blue',
        'description': 'A clean, modern template with blue accents',
        'preview': 'assets/templates/previews/template1.png',
        'file': 'assets/templates/template1.pdf',
        'config': 'meta-template1.json',
        'category': 'modern',
        'isPremium': false,
      },
      {
        'id': 'template2',
        'name': 'Classic Gray',
        'description': 'Traditional professional template in gray tones',
        'preview': 'assets/templates/previews/template2.png',
        'file': 'assets/templates/template2.pdf',
        'config': 'meta-template2.json',
        'category': 'classic',
        'isPremium': false,
      },
      {
        'id': 'template3',
        'name': 'Creative Colorful',
        'description': 'Vibrant template for creative professionals',
        'preview': 'assets/templates/previews/template3.png',
        'file': 'assets/templates/template3.pdf',
        'config': 'meta-template3.json',
        'category': 'creative',
        'isPremium': true,
      },
      {
        'id': 'template4',
        'name': 'Professional Black',
        'description': 'Elegant black and white professional template',
        'preview': 'assets/templates/previews/template4.png',
        'file': 'assets/templates/template4.pdf',
        'config': 'meta-template4.json',
        'category': 'professional',
        'isPremium': false,
      },
      {
        'id': 'template5',
        'name': 'Minimalist White',
        'description': 'Clean minimalist design with plenty of white space',
        'preview': 'assets/templates/previews/template5.png',
        'file': 'assets/templates/template5.pdf',
        'config': 'meta-template5.json',
        'category': 'minimalist',
        'isPremium': true,
      },
      {
        'id': 'template6',
        'name': 'Tech Green',
        'description': 'Modern template designed for tech professionals',
        'preview': 'assets/templates/previews/template6.png',
        'file': 'assets/templates/template6.pdf',
        'config': 'meta-template6.json',
        'category': 'tech',
        'isPremium': true,
      },
    ];
  }
  
  // Get all available templates
  static Future<List<Map<String, dynamic>>> getAllTemplates() async {
    if (_cachedTemplates == null) {
      _cachedTemplates = await _loadTemplatesFromMeta();
    }
    return List.from(_cachedTemplates!);
  }
  
  // Get templates by category
  static Future<List<Map<String, dynamic>>> getTemplatesByCategory(String category) async {
    final templates = await getAllTemplates();
    return templates
        .where((template) => template['category'] == category)
        .toList();
  }
  
  // Get free templates only
  static Future<List<Map<String, dynamic>>> getFreeTemplates() async {
    final templates = await getAllTemplates();
    return templates
        .where((template) => template['isPremium'] == false)
        .toList();
  }
  
  // Get premium templates only
  static Future<List<Map<String, dynamic>>> getPremiumTemplates() async {
    final templates = await getAllTemplates();
    return templates
        .where((template) => template['isPremium'] == true)
        .toList();
  }
  
  // Get template by ID
  static Future<Map<String, dynamic>?> getTemplateById(String templateId) async {
    try {
      final templates = await getAllTemplates();
      return templates.firstWhere(
        (template) => template['id'] == templateId,
      );
    } catch (e) {
      return null;
    }
  }
  
  // Load template metadata
  static Future<Map<String, dynamic>> loadTemplateMetadata(String templateId) async {
    try {
      final metaPath = 'assets/templates/meta-$templateId.json';
      final jsonString = await rootBundle.loadString(metaPath);
      return json.decode(jsonString);
    } catch (e) {
      // Fallback to default metadata
      return _getDefaultMetadata(templateId);
    }
  }
  
  // Generate template-specific styling
  static Map<String, dynamic> getTemplateStyles(String templateId) {
    switch (templateId) {
      case 'modern_blue':
        return {
          'primaryColor': '#2563EB',
          'secondaryColor': '#F3F4F6',
          'textColor': '#1F2937',
          'accentColor': '#3B82F6',
          'fontFamily': 'Inter',
          'headerFontSize': 24.0,
          'bodyFontSize': 12.0,
          'lineHeight': 1.4,
          'sectionSpacing': 16.0,
          'borderRadius': 8.0,
        };
      case 'classic_gray':
        return {
          'primaryColor': '#4B5563',
          'secondaryColor': '#F9FAFB',
          'textColor': '#111827',
          'accentColor': '#6B7280',
          'fontFamily': 'Times',
          'headerFontSize': 22.0,
          'bodyFontSize': 11.0,
          'lineHeight': 1.5,
          'sectionSpacing': 14.0,
          'borderRadius': 0.0,
        };
      case 'creative_colorful':
        return {
          'primaryColor': '#7C3AED',
          'secondaryColor': '#FEF3C7',
          'textColor': '#1F2937',
          'accentColor': '#F59E0B',
          'fontFamily': 'Inter',
          'headerFontSize': 26.0,
          'bodyFontSize': 12.0,
          'lineHeight': 1.3,
          'sectionSpacing': 18.0,
          'borderRadius': 12.0,
        };
      case 'professional_black':
        return {
          'primaryColor': '#000000',
          'secondaryColor': '#FFFFFF',
          'textColor': '#1F2937',
          'accentColor': '#374151',
          'fontFamily': 'Inter',
          'headerFontSize': 24.0,
          'bodyFontSize': 11.0,
          'lineHeight': 1.4,
          'sectionSpacing': 16.0,
          'borderRadius': 4.0,
        };
      case 'minimalist_white':
        return {
          'primaryColor': '#F9FAFB',
          'secondaryColor': '#FFFFFF',
          'textColor': '#374151',
          'accentColor': '#9CA3AF',
          'fontFamily': 'Inter',
          'headerFontSize': 20.0,
          'bodyFontSize': 10.0,
          'lineHeight': 1.6,
          'sectionSpacing': 20.0,
          'borderRadius': 0.0,
        };
      case 'tech_green':
        return {
          'primaryColor': '#059669',
          'secondaryColor': '#ECFDF5',
          'textColor': '#1F2937',
          'accentColor': '#10B981',
          'fontFamily': 'Inter',
          'headerFontSize': 24.0,
          'bodyFontSize': 12.0,
          'lineHeight': 1.4,
          'sectionSpacing': 16.0,
          'borderRadius': 8.0,
        };
      default:
        return _getDefaultStyles();
    }
  }
  
  // Generate template layout configuration
  static Map<String, dynamic> getTemplateLayout(String templateId) {
    switch (templateId) {
      case 'modern_blue':
        return {
          'layout': 'two_column',
          'leftColumnWidth': 0.35,
          'rightColumnWidth': 0.65,
          'showProfilePhoto': true,
          'photoPosition': 'top_left',
          'photoSize': 'medium',
          'headerStyle': 'centered',
          'sectionOrder': [
            'personal_info',
            'profile_summary',
            'experience',
            'education',
            'skills',
          ],
          'leftSections': ['personal_info', 'skills'],
          'rightSections': ['profile_summary', 'experience', 'education'],
        };
      case 'classic_gray':
        return {
          'layout': 'single_column',
          'showProfilePhoto': false,
          'headerStyle': 'left_aligned',
          'sectionOrder': [
            'personal_info',
            'profile_summary',
            'experience',
            'education',
            'skills',
          ],
        };
      case 'creative_colorful':
        return {
          'layout': 'two_column',
          'leftColumnWidth': 0.4,
          'rightColumnWidth': 0.6,
          'showProfilePhoto': true,
          'photoPosition': 'top_center',
          'photoSize': 'large',
          'headerStyle': 'creative',
          'sectionOrder': [
            'personal_info',
            'profile_summary',
            'skills',
            'experience',
            'education',
          ],
          'leftSections': ['personal_info', 'skills'],
          'rightSections': ['profile_summary', 'experience', 'education'],
        };
      case 'professional_black':
        return {
          'layout': 'single_column',
          'showProfilePhoto': true,
          'photoPosition': 'top_right',
          'photoSize': 'small',
          'headerStyle': 'professional',
          'sectionOrder': [
            'personal_info',
            'profile_summary',
            'experience',
            'education',
            'skills',
          ],
        };
      case 'minimalist_white':
        return {
          'layout': 'single_column',
          'showProfilePhoto': false,
          'headerStyle': 'minimal',
          'sectionOrder': [
            'personal_info',
            'experience',
            'education',
            'skills',
            'profile_summary',
          ],
        };
      case 'tech_green':
        return {
          'layout': 'two_column',
          'leftColumnWidth': 0.3,
          'rightColumnWidth': 0.7,
          'showProfilePhoto': true,
          'photoPosition': 'top_left',
          'photoSize': 'medium',
          'headerStyle': 'tech',
          'sectionOrder': [
            'personal_info',
            'skills',
            'profile_summary',
            'experience',
            'education',
          ],
          'leftSections': ['personal_info', 'skills'],
          'rightSections': ['profile_summary', 'experience', 'education'],
        };
      default:
        return _getDefaultLayout();
    }
  }
  
  // Validate template compatibility with CV data
  static bool isTemplateCompatible(String templateId, CVData cvData) {
    final template = getTemplateById(templateId);
    if (template == null) return false;
    
    final layout = getTemplateLayout(templateId);
    
    // Check if template requires profile photo but none is provided
    if (layout['showProfilePhoto'] == true && 
        cvData.personalInfo.profilePhotoPath == null) {
      // Still compatible, just won't show photo
    }
    
    // Check if CV has minimum required data
    if (cvData.personalInfo.fullName.isEmpty ||
        cvData.personalInfo.email.isEmpty) {
      return false;
    }
    
    return true;
  }
  
  // Get template recommendations based on CV data
  static List<String> getRecommendedTemplates(CVData cvData) {
    final recommendations = <String>[];
    
    // Analyze CV data to suggest appropriate templates
    final hasPhoto = cvData.personalInfo.profilePhotoPath != null;
    final hasExperience = cvData.experience.isNotEmpty;
    
    // Tech-related skills suggest tech template
    final techSkills = ['Flutter', 'React', 'Python', 'JavaScript', 'Java', 'Swift'];
    final hasTechSkills = cvData.skills.any((skill) => 
        techSkills.any((techSkill) => 
            skill.toLowerCase().contains(techSkill.toLowerCase())));
    
    if (hasTechSkills) {
      recommendations.add('tech_green');
    }
    
    // Extensive experience suggests professional template
    if (hasExperience && cvData.experience.length >= 3) {
      recommendations.add('professional_black');
    }
    
    // Creative fields suggest creative template
    final creativeKeywords = ['design', 'creative', 'art', 'marketing', 'brand'];
    final isCreative = cvData.skills.any((skill) => 
        creativeKeywords.any((keyword) => 
            skill.toLowerCase().contains(keyword)));
    
    if (isCreative) {
      recommendations.add('creative_colorful');
    }
    
    // Default recommendations
    if (hasPhoto) {
      recommendations.add('modern_blue');
    } else {
      recommendations.add('classic_gray');
    }
    
    // Add minimalist for clean preference
    recommendations.add('minimalist_white');
    
    // Remove duplicates and return
    return recommendations.toSet().toList();
  }
  
  // Helper methods
  static Map<String, dynamic> _getDefaultMetadata(String templateId) {
    return {
      'id': templateId,
      'name': templateId.replaceAll('_', ' ').toUpperCase(),
      'description': 'Professional CV template',
      'version': '1.0.0',
      'author': 'CV Generator',
      'tags': ['professional', 'modern'],
      'supportedSections': [
        'personal_info',
        'profile_summary',
        'experience',
        'education',
        'skills',
      ],
    };
  }
  
  static Map<String, dynamic> _getDefaultStyles() {
    return {
      'primaryColor': '#2563EB',
      'secondaryColor': '#F3F4F6',
      'textColor': '#1F2937',
      'accentColor': '#3B82F6',
      'fontFamily': 'Inter',
      'headerFontSize': 24.0,
      'bodyFontSize': 12.0,
      'lineHeight': 1.4,
      'sectionSpacing': 16.0,
      'borderRadius': 8.0,
    };
  }
  
  static Map<String, dynamic> _getDefaultLayout() {
    return {
      'layout': 'single_column',
      'showProfilePhoto': true,
      'photoPosition': 'top_left',
      'photoSize': 'medium',
      'headerStyle': 'centered',
      'sectionOrder': [
        'personal_info',
        'profile_summary',
        'experience',
        'education',
        'skills',
      ],
    };
  }

  // Get templates as CVTemplate objects
  static Future<List<CVTemplate>> getTemplates() async {
    final templates = await getAllTemplates();
    return templates.map((template) => CVTemplate.fromJson(template)).toList();
  }

  // Get template preview image
  static Future<Uint8List?> getTemplatePreviewImage(String templateId) async {
    try {
      final template = await getTemplateById(templateId);
      if (template == null) return null;
      
      final previewPath = template['preview'] as String;
      final byteData = await rootBundle.load(previewPath);
      return byteData.buffer.asUint8List();
    } catch (e) {
      return null;
    }
  }
}
