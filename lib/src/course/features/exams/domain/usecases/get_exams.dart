import 'package:education_app/core/usecases/usecases.dart';
import 'package:education_app/core/utils/typedefs.dart';
import 'package:education_app/src/course/features/exams/domain/entities/exam.dart';
import 'package:education_app/src/course/features/exams/domain/repos/exam_repo.dart';

class GetExams extends FutureUsecaseWithParams<List<Exam>, String> {
  const GetExams(this._repo);

  final ExamRepo _repo;

  @override
  ResultFuture<List<Exam>> call(String params) => _repo.getExams(params);
}
