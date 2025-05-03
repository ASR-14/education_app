import 'package:education_app/core/usecases/usecases.dart';
import 'package:education_app/core/utils/typedefs.dart';
import 'package:education_app/src/course/domain/entities/course.dart';
import 'package:education_app/src/course/domain/repos/course_repo.dart';

class GetCourses {
  const GetCourses(this._repo);

  final CourseRepo _repo;

  Stream<List<Course>> call() => _repo.getCourses();
}
