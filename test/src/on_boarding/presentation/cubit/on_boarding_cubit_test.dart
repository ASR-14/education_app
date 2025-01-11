import 'package:education_app/src/on_boarding/domain/usecases/cache_first_timer.dart';
import 'package:education_app/src/on_boarding/domain/usecases/check_if_user_is_first_timer.dart';
import 'package:education_app/src/on_boarding/presentation/cubit/on_boarding_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCacheFirstTimer extends Mock implements CacheFirstTimer {}

class MockCheckIfUserIsFirstTimer extends Mock
    implements CheckIfUserIsFirstTimer {}

void main() {
  late CacheFirstTimer cacheFirstTimer;
  late CheckIfUserIsFirstTimer checkIfUserIsFirstTimer;
  late OnBoardingCubit onBoardingCubit;

  setUp(
    () {
      cacheFirstTimer = MockCacheFirstTimer();
      checkIfUserIsFirstTimer = MockCheckIfUserIsFirstTimer();
      onBoardingCubit = OnBoardingCubit(
        cacheFirstTimer: cacheFirstTimer,
        checkIfUserIsFirstTimer: checkIfUserIsFirstTimer,
      );
    },
  );

  test(
    'initial state should be [OnBoardingInitial]',
    () {
      expect(onBoardingCubit.state, const OnBoardingInitial());
    },
  );
}
