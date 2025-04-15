part of 'injection_container.dart';

final sl = GetIt.instance;

Future<void> init() async {
  await _initOnBoarding();
  await _initAuth();
  await _initCourse();
  await _initVideo();
  await _initMaterial();
  await _initExam();
  await _initNotifications();
}

Future<void> _initNotifications() async {
  sl
    ..registerFactory(
      () => NotificationCubit(
        clear: sl(),
        clearAll: sl(),
        getNotifications: sl(),
        markAsRead: sl(),
        sendNotification: sl(),
      ),
    )
    ..registerLazySingleton(() => Clear(sl()))
    ..registerLazySingleton(() => ClearAll(sl()))
    ..registerLazySingleton(() => GetNotifications(sl()))
    ..registerLazySingleton(() => MarkAsRead(sl()))
    ..registerLazySingleton(() => SendNotification(sl()))
    ..registerLazySingleton<NotificationRepo>(() => NotificationRepoImpl(sl()))
    ..registerLazySingleton<NotificationRemoteDataSrc>(
      () => NotificationRemoteDataSrcImpl(firestore: sl(), auth: sl()),
    );
}

Future<void> _initExam() async {
  sl
    ..registerFactory(
      () => ExamCubit(
        getExamQuestions: sl(),
        getExams: sl(),
        submitExam: sl(),
        updateExam: sl(),
        uploadExam: sl(),
        getUserCourseExams: sl(),
        getUserExams: sl(),
      ),
    )
    ..registerLazySingleton(() => GetExamQuestions(sl()))
    ..registerLazySingleton(() => GetExams(sl()))
    ..registerLazySingleton(() => SubmitExam(sl()))
    ..registerLazySingleton(() => UpdateExam(sl()))
    ..registerLazySingleton(() => UploadExam(sl()))
    ..registerLazySingleton(() => GetUserCourseExams(sl()))
    ..registerLazySingleton(() => GetUserExams(sl()))
    ..registerLazySingleton<ExamRepo>(() => ExamRepoImpl(sl()))
    ..registerLazySingleton<ExamRemoteDataSrc>(
      () => ExamRemoteDataSrcImpl(auth: sl(), firestore: sl()),
    );
}

Future<void> _initMaterial() async {
  sl
    ..registerFactory(
      () => MaterialCubit(
        addMaterial: sl(),
        getMaterials: sl(),
      ),
    )
    ..registerLazySingleton(() => AddMaterial(sl()))
    ..registerLazySingleton(() => GetMaterials(sl()))
    ..registerLazySingleton<MaterialRepo>(() => MaterialRepoImpl(sl()))
    ..registerLazySingleton<MaterialRemoteDataSrc>(
      () => MaterialRemoteDataSrcImpl(
        firestore: sl(),
        auth: sl(),
        storage: sl(),
      ),
    )
    ..registerFactory(() => ResourceController(storage: sl(), prefs: sl()));
}

Future<void> _initVideo() async {
  sl
    ..registerFactory(
      () => VideoCubit(addVideo: sl(), getVideos: sl()),
    )
    ..registerLazySingleton(() => AddVideo(sl()))
    ..registerLazySingleton(() => GetVideos(sl()))
    ..registerLazySingleton<VideoRepo>(() => VideoRepoImpl(sl()))
    ..registerLazySingleton<VideoRemoteDataSrc>(
      () => VideoRemoteDataSrcImpl(
        auth: sl(),
        firestore: sl(),
        storage: sl(),
      ),
    );
}

Future<void> _initCourse() async {
  sl
    ..registerFactory(
      () => CourseCubit(
        addCourse: sl(),
        getCourses: sl(),
      ),
    )
    ..registerLazySingleton(() => AddCourse(sl()))
    ..registerLazySingleton(() => GetCourses(sl()))
    ..registerLazySingleton<CourseRepo>(() => CourseRepoImpl(sl()))
    ..registerLazySingleton<CourseRemoteDataSrc>(
      () => CourseRemoteDataSrcImpl(
        firestore: sl(),
        storage: sl(),
        auth: sl(),
      ),
    );
}

Future<void> _initAuth() async {
  sl
    ..registerFactory(
      () => AuthBloc(
        signIn: sl(),
        signUp: sl(),
        forgotPassword: sl(),
        updateUser: sl(),
      ),
    )
    ..registerLazySingleton(() => SignIn(sl()))
    ..registerLazySingleton(() => SignUp(sl()))
    ..registerLazySingleton(() => ForgotPassword(sl()))
    ..registerLazySingleton(() => UpdateUser(sl()))
    ..registerLazySingleton<AuthRepo>(() => AuthRepoImpl(sl()))
    ..registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(
        authClient: sl(),
        cloudStoreClient: sl(),
        dbClient: sl(),
      ),
    )
    ..registerLazySingleton(() => FirebaseAuth.instance)
    ..registerLazySingleton(() => FirebaseFirestore.instance)
    ..registerLazySingleton(() => Supabase.instance);
}

Future<void> _initOnBoarding() async {
  final prefs = await SharedPreferences.getInstance();

  sl
    ..registerFactory(
      () =>
          OnBoardingCubit(cacheFirstTimer: sl(), checkIfUserIsFirstTimer: sl()),
    )
    ..registerLazySingleton(() => CacheFirstTimer(sl()))
    ..registerLazySingleton(() => CheckIfUserIsFirstTimer(sl()))
    ..registerLazySingleton<OnBoardingRepo>(() => OnBoardingRepoImpl(sl()))
    ..registerLazySingleton<OnBoardingLocalDataSource>(
      () => OnBoardingLocalDataSrcImpl(sl()),
    )
    ..registerLazySingleton(() => prefs);
}
