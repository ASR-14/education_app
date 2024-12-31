import 'package:education_app/src/on_boarding/data/datasources/on_boarding_local_data_source.dart';
import 'package:education_app/src/on_boarding/data/repos/on_boarding_repo_impl.dart';
import 'package:education_app/src/on_boarding/domain/repos/on_boarding_repo.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockOnBoardingLocalDataSrc extends Mock
    implements OnBoardingLocalDataSource {}

void main() {
  late OnBoardingLocalDataSource localDataSource;
  late OnBoardingRepoImpl repoImpl;

  setUp(
    () {
      localDataSource = MockOnBoardingLocalDataSrc();
      repoImpl = OnBoardingRepoImpl(localDataSource);
    },
  );

  test(
    'should be a subclass of [OnboardingRepo]',
    () {
      expect(repoImpl, isA<OnBoardingRepo>());
    },
  );
}
