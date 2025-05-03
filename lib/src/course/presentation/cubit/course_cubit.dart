import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:education_app/core/errors/failures.dart';
import 'package:education_app/src/course/domain/entities/course.dart';
import 'package:education_app/src/course/domain/usecases/add_course.dart';
import 'package:education_app/src/course/domain/usecases/get_courses.dart';
import 'package:equatable/equatable.dart';

part 'course_state.dart';

class CourseCubit extends Cubit<CourseState> {
  CourseCubit({
    required GetCourses getCourses,
    required AddCourse addCourse,
  })  : _getCourses = getCourses,
        _addCourse = addCourse,
        super(const CourseInitial());

  final GetCourses _getCourses;
  final AddCourse _addCourse;

  Future<void> addCourse(Course course) async {
    emit(const AddingCourse());
    final result = await _addCourse(course);
    result.fold(
      (failure) => emit(CourseError(failure.errorMessage)),
      (_) => emit(const CourseAdded()),
    );
  }

  void getCourses() {
    emit(const LoadingCourses());

    StreamSubscription<Either<Failure, List<Course>>>? subscription;

    subscription = _getCourses().listen(
      (result) {
        result.fold(
          (failure) => emit(CourseError(failure.errorMessage)),
          (courses) => emit(CoursesLoaded(courses)),
        );
      },
      onError: (dynamic error) {
        emit(CourseError(error.toString()));
        subscription?.cancel();
      },
      onDone: () => subscription?.cancel(),
    );
  }
}
