import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:education_app/core/utils/typedefs.dart';
import 'package:education_app/src/course/data/models/course_model.dart';
import 'package:education_app/src/course/features/videos/data/models/video_model.dart';
import 'package:education_app/src/course/features/videos/domain/entities/video.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../../fixtures/fixture_reader.dart';

// class MockFieldValue extends Mock implements FieldValue {}

void main() {
  final timestampData = {
    '_seconds': 1739473992,
    '_nanoseconds': 12347843,
  };

  final date = DateTime.fromMillisecondsSinceEpoch(timestampData['_seconds']!)
      .add(Duration(microseconds: timestampData['_nanoseconds']!));

  final timestamp = Timestamp.fromDate(date);

  final tVideoModel = VideoModel.empty();

  final tMap = jsonDecode(fixture('video.json')) as DataMap;
  tMap['uploadDate'] = timestamp;

  test(
    'should be a subclass of [Video] entity',
    () {
      expect(tVideoModel, isA<Video>());
    },
  );

  group('fromMap', () {
    test(
      'should return a [VideoModel] with the correct data',
      () async {
        final result = VideoModel.fromMap(tMap);
        expect(result, equals(tVideoModel));
      },
    );
  });

  group('toMap', () {
    test(
      'should return a [Map] with the proper data',
      () {
        final result = tVideoModel.toMap()..remove('uploadDate');

        final map = DataMap.from(tMap)..remove('uploadDate');

        expect(result, equals(map));
      },
    );
  });

  group('copyWith', () {
    test('should return a [VideoModel] with the new data', () {
      final result = tVideoModel.copyWith(
        tutor: 'New Tutor',
      );
      expect(result.tutor, 'New Tutor');
    });
  });
}
