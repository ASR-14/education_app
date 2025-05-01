import 'package:education_app/src/course/domain/entities/course.dart';
import 'package:education_app/src/search/domain/repos/search_repo.dart';
import 'package:flutter/foundation.dart';

class SearchProvider extends ChangeNotifier {
  SearchProvider(this._repository);
  final SearchRepo _repository;
  List<Course> _results = [];
  bool _isLoading = false;
  String _error = '';

  List<Course> get results => _results;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> search(String query) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _results = await _repository.search(query);
    } on Exception catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Course?> getCourseById(String courseId) async {
    try {
      return await _repository.getCourseById(courseId);
    } on Exception catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  void clearResults() {
    _results = [];
    _error = '';
    notifyListeners();
  }
}
