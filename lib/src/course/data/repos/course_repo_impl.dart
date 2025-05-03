import 'package:dartz/dartz.dart';
import 'package:education_app/src/course/data/datasources/course_remote_data_src.dart';
import 'package:education_app/src/course/domain/entities/course.dart';
import 'package:education_app/src/course/domain/repos/course_repo.dart';
import 'package:education_app/core/errors/exceptions.dart';
import 'package:education_app/core/errors/failures.dart';
import 'package:education_app/core/utils/typedefs.dart';

class CourseRepoImpl implements CourseRepo {
  const CourseRepoImpl(this._remoteDataSrc);

  final CourseRemoteDataSrc _remoteDataSrc;

  @override
  ResultFuture<void> addCourse(Course course) async {
    try {
      await _remoteDataSrc.addCourse(course);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure.fromException(e));
    }
  }

  @override
  Stream<List<Course>> getCourses() {
    try {
      return _remoteDataSrc.getCourses();
    } on ServerException catch (e) {
      throw ServerFailure.fromException(e);
    }
  }
}
