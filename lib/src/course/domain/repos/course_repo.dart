import 'package:education_app/src/course/domain/entities/course.dart';
import 'package:education_app/core/utils/typedefs.dart';

abstract class CourseRepo {
  const CourseRepo();

  Stream<List<Course>> getCourses();

  ResultFuture<void> addCourse(Course course);
}
