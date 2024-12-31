import 'package:education_app/core/utils/typdefs.dart';
import 'package:education_app/src/on_boarding/data/datasources/on_boarding_local_data_source.dart';
import 'package:education_app/src/on_boarding/domain/repos/on_boarding_repo.dart';

class OnBoardingRepoImpl implements OnBoardingRepo {
  const OnBoardingRepoImpl(this._localDataSource);

  final OnBoardingLocalDataSource _localDataSource;
  @override
  ResultFuture<void> cacheFirstTimer() {
    throw UnimplementedError();
  }

  @override
  ResultFuture<bool> checkIfUserIsFirstTimer() {
    throw UnimplementedError();
  }
}
