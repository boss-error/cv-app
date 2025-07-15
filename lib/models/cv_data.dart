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

  PersonalInfo({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.address,
    this.profileSummary,
    this.linkedIn,
    this.website,
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
