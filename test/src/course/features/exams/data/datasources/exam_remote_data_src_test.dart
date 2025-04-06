import 'package:education_app/src/auth/data/models/user_model.dart';
import 'package:education_app/src/course/data/models/course_model.dart';
import 'package:education_app/src/course/features/exams/data/datasources/exam_remote_data_src.dart';
import 'package:education_app/src/course/features/exams/data/models/exam_model.dart';
import 'package:education_app/src/course/features/exams/data/models/exam_question_model.dart';
import 'package:education_app/src/course/features/exams/data/models/user_choice_model.dart';
import 'package:education_app/src/course/features/exams/data/models/user_exam_model.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in_mocks/google_sign_in_mocks.dart';

void main() {
  late ExamRemoteDataSrc remoteDataSource;
  late FakeFirebaseFirestore firestore;
  late MockFirebaseAuth auth;

  setUp(() async {
    firestore = FakeFirebaseFirestore();

    final user = MockUser(
      uid: 'uid',
      email: 'email',
      displayName: 'displayName',
    );

    final googleSignIn = MockGoogleSignIn();
    final signInAccount = await googleSignIn.signIn();
    final googleAuth = await signInAccount!.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    auth = MockFirebaseAuth(mockUser: user);
    await auth.signInWithCredential(credential);

    remoteDataSource = ExamRemoteDataSrcImpl(
      firestore: firestore,
      auth: auth,
    );
  });

  group('uploadExam', () {
    test(
      'should upload the given [Exam] to the firestore and separate the '
      '[Exam] and the [Exam.questions]',
      () async {
        // Arrange
        final exam = const ExamModel.empty().copyWith(
          questions: [const ExamQuestionModel.empty()],
        );

        await firestore.collection('courses').doc(exam.courseId).set(
              CourseModel.empty().copyWith(id: exam.courseId).toMap(),
            );

        // Act
        await remoteDataSource.uploadExam(exam);

        // Assert
        final examDocs = await firestore
            .collection('courses')
            .doc(exam.courseId)
            .collection('exams')
            .get();

        expect(examDocs.docs, isNotEmpty);
        final examModel = ExamModel.fromMap(examDocs.docs.first.data());
        expect(examModel.courseId, exam.courseId);

        final questionDocs = await firestore
            .collection('courses')
            .doc(examModel.courseId)
            .collection('exams')
            .doc(examModel.id)
            .collection('questions')
            .get();

        expect(questionDocs.docs, isNotEmpty);
        final questionModel =
            ExamQuestionModel.fromMap(questionDocs.docs.first.data());
        expect(questionModel.courseId, exam.courseId);
        expect(questionModel.examId, examModel.id);
      },
    );
  });
  group('getExamQuestions', () {
    test('should return the questions of the given exam', () async {
      // arrange
      final exam = const ExamModel.empty().copyWith(
        questions: [const ExamQuestionModel.empty()],
      );

      await firestore.collection('courses').doc(exam.courseId).set(
            CourseModel.empty().copyWith(id: exam.courseId).toMap(),
          );
      await remoteDataSource.uploadExam(exam);
      // No need to assert the uploadExam method because it's already tested
      final examsCollection = await firestore
          .collection('courses')
          .doc(exam.courseId)
          .collection('exams')
          .get();
      final examModel = ExamModel.fromMap(examsCollection.docs.first.data());
      // act
      final result = await remoteDataSource.getExamQuestions(examModel);
      // assert
      expect(result, isA<List<ExamQuestionModel>>());
      expect(result, hasLength(1));
      expect(result.first.courseId, exam.courseId);
    });
  });
  group('getExams', () {
    test('should return the exams of the given course', () async {
      // arrange
      final exam = const ExamModel.empty().copyWith(
        questions: [const ExamQuestionModel.empty()],
      );

      await firestore.collection('courses').doc(exam.courseId).set(
            CourseModel.empty().copyWith(id: exam.courseId).toMap(),
          );
      await remoteDataSource.uploadExam(exam);
      // No need to assert the uploadExam method because it's already tested
      // act
      final result = await remoteDataSource.getExams(exam.courseId);
      // assert
      expect(result, isA<List<ExamModel>>());
      expect(result, hasLength(1));
      expect(result.first.courseId, exam.courseId);
    });
  });
  group('updateExam', () {
    test('should update the given exam', () async {
      // arrange
      final exam = const ExamModel.empty().copyWith(
        questions: [const ExamQuestionModel.empty()],
      );
      await firestore.collection('courses').doc(exam.courseId).set(
            CourseModel.empty().copyWith(id: exam.courseId).toMap(),
          );
      await remoteDataSource.uploadExam(exam);
      // No need to assert the uploadExam method because it's already tested
      // act
      final examsCollection = await firestore
          .collection('courses')
          .doc(exam.courseId)
          .collection('exams')
          .get();
      final examModel = ExamModel.fromMap(examsCollection.docs.first.data());
      await remoteDataSource.updateExam(examModel.copyWith(timeLimit: 100));
      // assert
      final updatedExam = await firestore
          .collection('courses')
          .doc(exam.courseId)
          .collection('exams')
          .doc(examModel.id)
          .get();
      expect(updatedExam.data(), isNotEmpty);
      final updatedExamModel = ExamModel.fromMap(updatedExam.data()!);
      expect(updatedExamModel.courseId, exam.courseId);
      expect(updatedExamModel.timeLimit, 100);
    });
  });
  group('submitExam', () {
    test(
      'should submit the given exam',
      () async {
        // Arrange
        final userExam = UserExamModel.empty().copyWith(
          totalQuestions: 2,
          answers: [const UserChoiceModel.empty()],
        );
        await firestore.collection('users').doc(auth.currentUser!.uid).set(
              const LocalUserModel.empty()
                  .copyWith(uid: auth.currentUser!.uid, points: 1)
                  .toMap(),
            );
        // Act
        await remoteDataSource.submitExam(userExam);

        // Assert
        final submittedExam = await firestore
            .collection('users')
            .doc(auth.currentUser!.uid)
            .collection('courses')
            .doc(userExam.courseId)
            .collection('exams')
            .doc(userExam.examId)
            .get();

        expect(submittedExam.data(), isNotEmpty);
        final submittedExamModel = UserExamModel.fromMap(submittedExam.data()!);
        expect(submittedExamModel.courseId, userExam.courseId);

        final userDoc = await firestore
            .collection('users')
            .doc(auth.currentUser!.uid)
            .get();

        expect(userDoc.data(), isNotEmpty);
        final userModel = LocalUserModel.fromMap(userDoc.data()!);
        expect(userModel.points, 51);

        expect(userModel.enrolledCourseIds, contains(userExam.courseId));
      },
    );
  });
  group('getUserCourseExams', () {
    test(
      'should return the exams of the given course',
      () async {
        // Arrange
        final exam = UserExamModel.empty();
        await firestore.collection('users').doc(auth.currentUser!.uid).set(
              const LocalUserModel.empty()
                  .copyWith(uid: auth.currentUser!.uid, points: 1)
                  .toMap(),
            );
        await remoteDataSource.submitExam(exam);

        // Act
        final result = await remoteDataSource.getUserCourseExams(exam.courseId);

        // Assert
        expect(result, isA<List<UserExamModel>>());
        expect(result, hasLength(1));
        expect(result.first.courseId, exam.courseId);
      },
    );
  });
  group('getUserExams', () {
    test('should return the exams of the current user', () async {
      // arrange
      final exam = UserExamModel.empty();
      await firestore.collection('users').doc(auth.currentUser!.uid).set(
            const LocalUserModel.empty()
                .copyWith(uid: auth.currentUser!.uid, points: 1)
                .toMap(),
          );
      await firestore
          .collection('users')
          .doc(auth.currentUser!.uid)
          .collection('courses')
          .doc(exam.courseId)
          .set(
            CourseModel.empty().copyWith(id: exam.courseId).toMap(),
          );
      await remoteDataSource.submitExam(exam);
      // No need to assert the submitExam method because it's already tested
      // act
      final result = await remoteDataSource.getUserExams();
      // assert
      expect(result, isA<List<UserExamModel>>());
      expect(result, hasLength(1));
      expect(result.first.courseId, exam.courseId);
    });
  });
}
