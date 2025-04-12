import 'package:education_app/core/usecases/usecases.dart';
import 'package:education_app/core/utils/typedefs.dart';
import 'package:education_app/src/notifications/domain/repos/notification_repo.dart';

class ClearAll extends FutureUsecaseWithoutParams<void> {
  const ClearAll(this._repo);

  final NotificationRepo _repo;

  @override
  ResultFuture<void> call() => _repo.clearAll();
}
