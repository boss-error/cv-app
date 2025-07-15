import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/cv_data.dart';

class CVProvider with ChangeNotifier {
  CVData _cvData = CVData(
    personalInfo: PersonalInfo(
      fullName: '',
      email: '',
      phone: '',
      address: '',
    ),
  );

  String _currentStep = 'personal_info';
  bool _isLoading = false;
  String? _error;

  CVData get cvData => _cvData;
  String get currentStep => _currentStep;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize and load saved data
  Future<void> initialize() async {
    await _loadData();
  }

  // Save data to SharedPreferences
  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = json.encode(_cvData.toJson());
      await prefs.setString('cv_data', jsonString);
    } catch (e) {
      print('Error saving CV data: $e');
    }
  }

  // Load data from SharedPreferences
  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('cv_data');
      if (jsonString != null) {
        final jsonData = json.decode(jsonString);
        _cvData = CVData.fromJson(jsonData);
        notifyListeners();
      }
    } catch (e) {
      print('Error loading CV data: $e');
    }
  }

  void updatePersonalInfo(PersonalInfo personalInfo) {
    _cvData.personalInfo = personalInfo;
    _saveData();
    notifyListeners();
  }

  void updateProfilePhoto(String? photoPath) {
    _cvData.personalInfo.profilePhotoPath = photoPath;
    _saveData();
    notifyListeners();
  }

  void removeProfilePhoto() {
    _cvData.personalInfo.profilePhotoPath = null;
    _saveData();
    notifyListeners();
  }

  void addEducation(Education education) {
    _cvData.education.add(education);
    _saveData();
    notifyListeners();
  }

  void updateEducation(int index, Education education) {
    if (index < _cvData.education.length) {
      _cvData.education[index] = education;
      _saveData();
      notifyListeners();
    }
  }

  void removeEducation(int index) {
    if (index < _cvData.education.length) {
      _cvData.education.removeAt(index);
      _saveData();
      notifyListeners();
    }
  }

  void addExperience(Experience experience) {
    _cvData.experience.add(experience);
    _saveData();
    notifyListeners();
  }

  void updateExperience(int index, Experience experience) {
    if (index < _cvData.experience.length) {
      _cvData.experience[index] = experience;
      _saveData();
      notifyListeners();
    }
  }

  void removeExperience(int index) {
    if (index < _cvData.experience.length) {
      _cvData.experience.removeAt(index);
      _saveData();
      notifyListeners();
    }
  }

  void updateSkills(List<String> skills) {
    _cvData.skills = skills;
    _saveData();
    notifyListeners();
  }

  void addSkill(String skill) {
    if (!_cvData.skills.contains(skill)) {
      _cvData.skills.add(skill);
      _saveData();
      notifyListeners();
    }
  }

  void removeSkill(String skill) {
    _cvData.skills.remove(skill);
    _saveData();
    notifyListeners();
  }

  void updateJobInfo(String? jobTitle, String? jobRequirements) {
    _cvData.jobTitle = jobTitle;
    _cvData.jobRequirements = jobRequirements;
    _saveData();
    notifyListeners();
  }

  void selectTemplate(String templateName) {
    _cvData.selectedTemplate = templateName;
    _saveData();
    notifyListeners();
  }

  void setCurrentStep(String step) {
    _currentStep = step;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void resetCV() {
    _cvData = CVData(
      personalInfo: PersonalInfo(
        fullName: '',
        email: '',
        phone: '',
        address: '',
      ),
    );
    _currentStep = 'personal_info';
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  bool get isPersonalInfoComplete {
    return _cvData.personalInfo.fullName.isNotEmpty &&
           _cvData.personalInfo.email.isNotEmpty &&
           _cvData.personalInfo.phone.isNotEmpty &&
           _cvData.personalInfo.address.isNotEmpty;
  }

  bool get hasEducation => _cvData.education.isNotEmpty;
  bool get hasExperience => _cvData.experience.isNotEmpty;
  bool get hasSkills => _cvData.skills.isNotEmpty;
  bool get hasJobInfo => _cvData.jobTitle?.isNotEmpty == true;
  bool get hasSelectedTemplate => _cvData.selectedTemplate?.isNotEmpty == true;

  double get completionPercentage {
    int completed = 0;
    int total = 6;

    if (isPersonalInfoComplete) completed++;
    if (hasEducation) completed++;
    if (hasExperience) completed++;
    if (hasSkills) completed++;
    if (hasJobInfo) completed++;
    if (hasSelectedTemplate) completed++;

    return completed / total;
  }
}
