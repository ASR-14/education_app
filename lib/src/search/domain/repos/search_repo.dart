import 'package:education_app/src/course/domain/entities/course.dart';

abstract class SearchRepo {
  Future<List<Course>> search(String query);
  Future<Course?> getCourseById(String courseId);
}
