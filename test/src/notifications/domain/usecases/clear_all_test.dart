import 'package:dartz/dartz.dart';
import 'package:education_app/src/notifications/domain/repos/notification_repo.dart';
import 'package:education_app/src/notifications/domain/usecases/clear_all.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'notification_repo.mock.dart';

void main() {
  late NotificationRepo repo;
  late ClearAll usecase;

  setUp(() {
    repo = MockNotificationRepo();
    usecase = ClearAll(repo);
  });

  test(
    'should call the [NotificationRepo.clearAll]',
    () async {
      when(() => repo.clearAll()).thenAnswer((_) async => const Right(null));

      final result = await usecase();

      expect(result, const Right<dynamic, void>(null));

      verify(() => repo.clearAll()).called(1);

      verifyNoMoreInteractions(repo);
    },
  );
}
