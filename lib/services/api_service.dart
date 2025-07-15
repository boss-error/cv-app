import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/cv_data.dart';

class ApiService {
  static const String baseUrl = 'https://api.cvgenerator.com'; // Replace with actual API
  late final Dio _dio;
  
  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    
    _setupInterceptors();
  }
  
  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add authentication token if available
          // options.headers['Authorization'] = 'Bearer \$token';
          handler.next(options);
        },
        onResponse: (response, handler) {
          handler.next(response);
        },
        onError: (error, handler) {
          _handleError(error);
          handler.next(error);
        },
      ),
    );
  }
  
  void _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw Exception('Connection timeout. Please check your internet connection.');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?['message'] ?? 'Server error occurred';
        throw Exception('Server error (\$statusCode): \$message');
      case DioExceptionType.cancel:
        throw Exception('Request was cancelled');
      case DioExceptionType.unknown:
        throw Exception('Network error occurred. Please try again.');
      default:
        throw Exception('An unexpected error occurred');
    }
  }
  
  // CV Management APIs
  Future<Map<String, dynamic>> saveCVData(CVData cvData) async {
    try {
      final response = await _dio.post('/cv/save', data: cvData.toJson());
      return response.data;
    } catch (e) {
      throw Exception('Failed to save CV data: \$e');
    }
  }
  
  Future<CVData> loadCVData(String cvId) async {
    try {
      final response = await _dio.get('/cv/\$cvId');
      return CVData.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load CV data: \$e');
    }
  }
  
  Future<List<Map<String, dynamic>>> getUserCVs(String userId) async {
    try {
      final response = await _dio.get('/cv/user/\$userId');
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      throw Exception('Failed to load user CVs: \$e');
    }
  }
  
  // Template APIs
  Future<List<Map<String, dynamic>>> getTemplates() async {
    try {
      final response = await _dio.get('/templates');
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      throw Exception('Failed to load templates: \$e');
    }
  }
  
  Future<Map<String, dynamic>> getTemplate(String templateId) async {
    try {
      final response = await _dio.get('/templates/\$templateId');
      return response.data;
    } catch (e) {
      throw Exception('Failed to load template: \$e');
    }
  }
  
  // PDF Generation APIs
  Future<File> generatePDF(CVData cvData, String templateId) async {
    try {
      final response = await _dio.post(
        '/cv/generate-pdf',
        data: {
          'cvData': cvData.toJson(),
          'templateId': templateId,
        },
        options: Options(responseType: ResponseType.bytes),
      );
      
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = 'cv_\${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File(path.join(appDir.path, 'generated', fileName));
      
      await file.parent.create(recursive: true);
      await file.writeAsBytes(response.data);
      
      return file;
    } catch (e) {
      throw Exception('Failed to generate PDF: \$e');
    }
  }
  
  // Job Matching APIs
  Future<Map<String, dynamic>> analyzeJobRequirements(String jobDescription) async {
    try {
      final response = await _dio.post('/jobs/analyze', data: {
        'description': jobDescription,
      });
      return response.data;
    } catch (e) {
      throw Exception('Failed to analyze job requirements: \$e');
    }
  }
  
  Future<Map<String, dynamic>> getOptimizationSuggestions(
    CVData cvData, 
    String jobDescription,
  ) async {
    try {
      final response = await _dio.post('/cv/optimize', data: {
        'cvData': cvData.toJson(),
        'jobDescription': jobDescription,
      });
      return response.data;
    } catch (e) {
      throw Exception('Failed to get optimization suggestions: \$e');
    }
  }
  
  // File Upload APIs
  Future<Map<String, dynamic>> uploadFile(File file) async {
    try {
      final fileName = path.basename(file.path);
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
      });
      
      final response = await _dio.post('/upload', data: formData);
      return response.data;
    } catch (e) {
      throw Exception('Failed to upload file: \$e');
    }
  }
  
  Future<CVData> parseUploadedFile(String fileId) async {
    try {
      final response = await _dio.post('/files/parse', data: {
        'fileId': fileId,
      });
      return CVData.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to parse uploaded file: \$e');
    }
  }
  
  // Skills and Industry APIs
  Future<List<String>> getSkillSuggestions(String query) async {
    try {
      final response = await _dio.get('/skills/suggestions', queryParameters: {
        'q': query,
        'limit': 10,
      });
      return List<String>.from(response.data);
    } catch (e) {
      throw Exception('Failed to get skill suggestions: \$e');
    }
  }
  
  Future<List<String>> getIndustrySuggestions() async {
    try {
      final response = await _dio.get('/industries');
      return List<String>.from(response.data);
    } catch (e) {
      throw Exception('Failed to get industry suggestions: \$e');
    }
  }
  
  // Analytics APIs
  Future<Map<String, dynamic>> getCVAnalytics(String cvId) async {
    try {
      final response = await _dio.get('/cv/\$cvId/analytics');
      return response.data;
    } catch (e) {
      throw Exception('Failed to get CV analytics: \$e');
    }
  }
  
  Future<void> trackCVView(String cvId) async {
    try {
      await _dio.post('/cv/\$cvId/view');
    } catch (e) {
      // Ignore tracking errors
    }
  }
  
  Future<void> trackCVDownload(String cvId) async {
    try {
      await _dio.post('/cv/\$cvId/download');
    } catch (e) {
      // Ignore tracking errors
    }
  }
  
  // Utility methods
  Future<bool> checkServerHealth() async {
    try {
      final response = await _dio.get('/health');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  // Task Status APIs
  Future<TaskStatus> getTaskStatus(String taskId) async {
    try {
      final response = await _dio.get('/tasks/\$taskId/status');
      return TaskStatus.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to get task status: \$e');
    }
  }
  
  Future<String> downloadCV(String downloadUrl, String fileName) async {
    try {
      final response = await _dio.get(
        downloadUrl,
        options: Options(responseType: ResponseType.bytes),
      );
      
      final appDir = await getApplicationDocumentsDirectory();
      final file = File(path.join(appDir.path, 'downloads', fileName));
      
      await file.parent.create(recursive: true);
      await file.writeAsBytes(response.data);
      
      return file.path;
    } catch (e) {
      throw Exception('Failed to download CV: \$e');
    }
  }

  void dispose() {
    _dio.close();
  }
}
