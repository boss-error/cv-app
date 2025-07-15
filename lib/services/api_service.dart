import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../models/cv_data.dart';

class ApiService {
  static const String baseUrl = 'https://api.cvgenerator.com'; // Replace with actual API URL
  late Dio _dio;

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

    // Add interceptors for logging
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => print(obj),
    ));
  }

  Future<String> generateCV({
    required CVData cvData,
    required String templateName,
  }) async {
    try {
      final response = await _dio.post(
        '/create-cv',
        data: {
          'data': cvData.toJson(),
          'template': templateName,
          'job_title': cvData.jobTitle ?? '',
          'requirements': cvData.jobRequirements ?? '',
        },
      );

      if (response.statusCode == 200) {
        return response.data['task_id'] as String;
      } else {
        throw Exception('Failed to generate CV: \${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: \${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: \$e');
    }
  }

  Future<TaskStatus> getTaskStatus(String taskId) async {
    try {
      final response = await _dio.get('/task/\$taskId');

      if (response.statusCode == 200) {
        return TaskStatus.fromJson(response.data);
      } else {
        throw Exception('Failed to get task status: \${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: \${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: \$e');
    }
  }

  Future<String> downloadCV(String downloadUrl, String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '\${directory.path}/\$fileName';

      await _dio.download(
        downloadUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            print('Download progress: \${(received / total * 100).toStringAsFixed(0)}%');
          }
        },
      );

      return filePath;
    } on DioException catch (e) {
      throw Exception('Download failed: \${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: \$e');
    }
  }

  Future<List<CVTemplate>> getTemplates() async {
    try {
      final response = await _dio.get('/templates');

      if (response.statusCode == 200) {
        final List<dynamic> templatesJson = response.data['templates'];
        return templatesJson.map((json) => CVTemplate.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get templates: \${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: \${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: \$e');
    }
  }
}

class TaskStatus {
  final String taskId;
  final String status; // 'pending', 'processing', 'completed', 'failed'
  final String? downloadUrl;
  final String? errorMessage;
  final DateTime createdAt;
  final DateTime? completedAt;

  TaskStatus({
    required this.taskId,
    required this.status,
    this.downloadUrl,
    this.errorMessage,
    required this.createdAt,
    this.completedAt,
  });

  factory TaskStatus.fromJson(Map<String, dynamic> json) {
    return TaskStatus(
      taskId: json['taskId'],
      status: json['status'],
      downloadUrl: json['downloadUrl'],
      errorMessage: json['errorMessage'],
      createdAt: DateTime.parse(json['createdAt']),
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt']) 
          : null,
    );
  }

  bool get isPending => status == 'pending';
  bool get isProcessing => status == 'processing';
  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';
}

class CVTemplate {
  final String id;
  final String name;
  final String description;
  final String previewUrl;
  final String category;
  final bool isPremium;

  CVTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.previewUrl,
    required this.category,
    this.isPremium = false,
  });

  factory CVTemplate.fromJson(Map<String, dynamic> json) {
    return CVTemplate(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      previewUrl: json['previewUrl'],
      category: json['category'],
      isPremium: json['isPremium'] ?? false,
    );
  }
}
