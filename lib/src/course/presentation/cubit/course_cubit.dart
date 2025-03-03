import 'package:bloc/bloc.dart';
import 'package:education_app/src/course/domain/entities/course.dart';
import 'package:education_app/src/course/domain/usecases/add_course.dart';
import 'package:education_app/src/course/domain/usecases/get_courses.dart';
import 'package:equatable/equatable.dart';

part 'course_state.dart';

class CourseCubit extends Cubit<CourseState> {
  CourseCubit({
    required AddCourse addCourse,
    required GetCourses getCourses,
  })  : _addCourse = addCourse,
        _getCourses = getCourses,
        super(const CourseInitial());

  final AddCourse _addCourse;
  final GetCourses _getCourses;

  Future<void> addCourse(Course course) async {
    emit(const AddingCourses());
    final result = await _addCourse(course);
    result.fold(
      (failure) => emit(CourseError(failure.errorMessage)),
      (_) => emit(const CourseAdded()),
    );
  }

  Future<void> getCourses() async {
    emit(const LoadingCourses());
    final result = await _getCourses();
    result.fold(
      (failure) => emit(CourseError(failure.errorMessage)),
      (courses) => emit(CoursesLoaded(courses)),
    );
  }
}
