import 'package:education_app/core/utils/typedefs.dart';

abstract class UsecaseWithParams<Type, Params> {
  const UsecaseWithParams();

  ResultFuture<Type> call(Params params);
}

abstract class UsecaseWithoutParams<Type> {
  const UsecaseWithoutParams();

  ResultFuture<Type> call();
}

abstract class StreamUsecaseWithoutParams<Type> {
  const StreamUsecaseWithoutParams();

  ResultStream<Type> call();
}

abstract class StreamUsecaseWithParams<Type, Params> {
  const StreamUsecaseWithParams();

  ResultStream<Type> call(Params params);
}
