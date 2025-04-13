import 'package:dartz/dartz.dart';
import 'package:education_app/src/notifications/domain/repos/notification_repo.dart';
import 'package:education_app/src/notifications/domain/usecases/clear.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'notification_repo.mock.dart';

void main() {
  late NotificationRepo repo;
  late Clear usecase;
  setUp(() {
    repo = MockNotificationRepo();
    usecase = Clear(repo);
  });

  test(
    'should call the [NotificationRepo.clear]',
    () async {
      when(() => repo.clear(any())).thenAnswer((_) async => const Right(null));

      final result = await usecase('id');

      expect(result, const Right<dynamic, void>(null));

      verify(() => repo.clear('id')).called(1);

      verifyNoMoreInteractions(repo);
    },
  );
}
