import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:education_app/core/utils/typedefs.dart';
import 'package:education_app/src/chat/data/models/group_model.dart';
import 'package:education_app/src/chat/domain/entities/group.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../fixtures/fixture_reader.dart';

void main() {
  final timestampData = {
    '_seconds': 1677483548,
    '_nanoseconds': 123456000,
  };

  final date =
  DateTime.fromMillisecondsSinceEpoch(timestampData['_seconds']!).add(
    Duration(microseconds: timestampData['_nanoseconds']!),
  );

  final timestamp = Timestamp.fromDate(date);
  final tGroupModel = GroupModel.empty();

  final tMap = jsonDecode(fixture('group.json')) as DataMap;
  tMap['lastMessageTimestamp'] = timestamp;

  test('should be a subclass of Group entity', () {
    expect(tGroupModel, isA<Group>());
  });

  group('fromMap', () {
    test(
      'should return a valid model when the map is valid',
      () async {
        final result = GroupModel.fromMap(tMap);

        expect(result, isA<GroupModel>());

        expect(result, tGroupModel);
      },
    );
  });

  group('toMap', () {
    test(
      'should return a JSON map containing the proper data',
      () async {
        final result = tGroupModel.toMap()..remove('lastMessageTimestamp');
        expect(result, tMap..remove('lastMessageTimestamp'));
      },
    );
  });

  group('copyWith', () {
    test(
      'should return a copy of the model with the given fields',
      () async {
        final result = tGroupModel.copyWith(name: 'New name');
        expect(result, isA<GroupModel>());
        expect(result.name, 'New name');
      },
    );
  });
}
