class CVData {
  PersonalInfo personalInfo;
  List<Education> education;
  List<Experience> experience;
  List<String> skills;
  String? jobTitle;
  String? jobRequirements;
  String? selectedTemplate;

  CVData({
    required this.personalInfo,
    this.education = const [],
    this.experience = const [],
    this.skills = const [],
    this.jobTitle,
    this.jobRequirements,
    this.selectedTemplate,
  });

  Map<String, dynamic> toJson() {
    return {
      'personalInfo': personalInfo.toJson(),
      'education': education.map((e) => e.toJson()).toList(),
      'experience': experience.map((e) => e.toJson()).toList(),
      'skills': skills,
      'jobTitle': jobTitle,
      'jobRequirements': jobRequirements,
      'selectedTemplate': selectedTemplate,
    };
  }

  factory CVData.fromJson(Map<String, dynamic> json) {
    return CVData(
      personalInfo: PersonalInfo.fromJson(json['personalInfo']),
      education: (json['education'] as List?)
          ?.map((e) => Education.fromJson(e))
          .toList() ?? [],
      experience: (json['experience'] as List?)
          ?.map((e) => Experience.fromJson(e))
          .toList() ?? [],
      skills: List<String>.from(json['skills'] ?? []),
      jobTitle: json['jobTitle'],
      jobRequirements: json['jobRequirements'],
      selectedTemplate: json['selectedTemplate'],
    );
  }
}

class PersonalInfo {
  String fullName;
  String email;
  String phone;
  String address;
  String? profileSummary;
  String? linkedIn;
  String? website;
  String? profilePhotoPath;
  String? github;
  String? portfolio;

  PersonalInfo({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.address,
    this.profileSummary,
    this.linkedIn,
    this.website,
    this.profilePhotoPath,
    this.github,
    this.portfolio,
  });

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'address': address,
      'profileSummary': profileSummary,
      'linkedIn': linkedIn,
      'website': website,
      'profilePhotoPath': profilePhotoPath,
      'github': github,
      'portfolio': portfolio,
    };
  }

  factory PersonalInfo.fromJson(Map<String, dynamic> json) {
    return PersonalInfo(
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      profileSummary: json['profileSummary'],
      linkedIn: json['linkedIn'],
      website: json['website'],
      profilePhotoPath: json['profilePhotoPath'],
      github: json['github'],
      portfolio: json['portfolio'],
    );
  }
}

class Education {
  String institution;
  String degree;
  String fieldOfStudy;
  String startDate;
  String endDate;
  String? gpa;
  String? description;

  Education({
    required this.institution,
    required this.degree,
    required this.fieldOfStudy,
    required this.startDate,
    required this.endDate,
    this.gpa,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'institution': institution,
      'degree': degree,
      'fieldOfStudy': fieldOfStudy,
      'startDate': startDate,
      'endDate': endDate,
      'gpa': gpa,
      'description': description,
    };
  }

  factory Education.fromJson(Map<String, dynamic> json) {
    return Education(
      institution: json['institution'] ?? '',
      degree: json['degree'] ?? '',
      fieldOfStudy: json['fieldOfStudy'] ?? '',
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      gpa: json['gpa'],
      description: json['description'],
    );
  }
}

class Experience {
  String company;
  String position;
  String startDate;
  String endDate;
  String? location;
  List<String> responsibilities;
  bool isCurrentJob;

  Experience({
    required this.company,
    required this.position,
    required this.startDate,
    required this.endDate,
    this.location,
    this.responsibilities = const [],
    this.isCurrentJob = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'company': company,
      'position': position,
      'startDate': startDate,
      'endDate': endDate,
      'location': location,
      'responsibilities': responsibilities,
      'isCurrentJob': isCurrentJob,
    };
  }

  factory Experience.fromJson(Map<String, dynamic> json) {
    return Experience(
      company: json['company'] ?? '',
      position: json['position'] ?? '',
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      location: json['location'],
      responsibilities: List<String>.from(json['responsibilities'] ?? []),
      isCurrentJob: json['isCurrentJob'] ?? false,
    );
  }
}

class TaskStatus {
  final String id;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;
  final String? downloadUrl;
  final String? errorMessage;
  final double progress;

  TaskStatus({
    required this.id,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.completedAt,
    this.downloadUrl,
    this.errorMessage,
    this.progress = 0.0,
  });

  bool get isPending => status == 'pending';
  bool get isProcessing => status == 'processing';
  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';

  factory TaskStatus.fromJson(Map<String, dynamic> json) {
    return TaskStatus(
      id: json['id'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      downloadUrl: json['downloadUrl'],
      errorMessage: json['errorMessage'],
      progress: (json['progress'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'downloadUrl': downloadUrl,
      'errorMessage': errorMessage,
      'progress': progress,
    };
  }
}

class CVTemplate {
  final String id;
  final String name;
  final String description;
  final String category;
  final bool isPremium;
  final String previewUrl;
  final List<String> supportedSections;
  final Map<String, dynamic> styles;
  final Map<String, dynamic> layout;

  CVTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    this.isPremium = false,
    required this.previewUrl,
    this.supportedSections = const [],
    this.styles = const {},
    this.layout = const {},
  });

  factory CVTemplate.fromJson(Map<String, dynamic> json) {
    return CVTemplate(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? 'general',
      isPremium: json['isPremium'] ?? false,
      previewUrl: json['preview'] ?? json['previewUrl'] ?? '',
      supportedSections: List<String>.from(json['supportedSections'] ?? []),
      styles: Map<String, dynamic>.from(json['styles'] ?? {}),
      layout: Map<String, dynamic>.from(json['layout'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'isPremium': isPremium,
      'previewUrl': previewUrl,
      'supportedSections': supportedSections,
      'styles': styles,
      'layout': layout,
    };
  }
}
