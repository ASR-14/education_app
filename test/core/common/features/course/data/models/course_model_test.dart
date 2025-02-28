import 'dart:convert';

import 'package:education_app/core/common/features/course/data/models/course_model.dart';
import 'package:education_app/core/common/features/course/domain/entities/course.dart';
import 'package:education_app/core/utils/typdefs.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../../fixtures/fixture_reader.dart';

void main() {
  final tCourseModel = CourseModel.empty();
  final tMap = jsonDecode(fixture('course.json')) as DataMap;

  test('should be a subclass of [Course] entity', () {
    expect(tCourseModel, isA<Course>());
  });
}
