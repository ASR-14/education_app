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
        super(const CourseInitial()) {
    getCourses();
  }

  final AddCourse _addCourse;
  final GetCourses _getCourses;

  void getCourses() {
    _getCourses().listen(
      (List<Course> courses) => emit(CoursesLoaded(courses)),
      onError: (error) => emit(CourseError(error.toString())),
    );
  }

  Future<void> addCourse(Course course) async {
    emit(const AddingCourses());
    final result = await _addCourse(course);
    result.fold(
      (failure) => emit(CourseError(failure.errorMessage)),
      (_) => emit(const CourseAdded()),
    );
  }
}
