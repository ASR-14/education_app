part of 'course_cubit.dart';

abstract class CourseState extends Equatable {
  const CourseState();

  @override
  List<Object> get props => [];
}

class CourseInitial extends CourseState {
  const CourseInitial();
}

class LoadingCourses extends CourseState {
  const LoadingCourses();
}

class AddingCourses extends CourseState {
  const AddingCourses();
}

class CourseAdded extends CourseState {
  const CourseAdded();
}

class CoursesLoaded extends CourseState {
  const CoursesLoaded(this.courses);

  final List<Course> courses;

  @override
  List<Object> get props => [courses];
}

class CourseError extends CourseState {
  const CourseError(this.message);

  final String message;

  @override
  List<Object> get props => [message];
}
