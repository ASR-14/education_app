import 'package:education_app/src/course/data/datasources/course_remote_data_src.dart';
import 'package:education_app/src/course/data/models/course_model.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in_mocks/google_sign_in_mocks.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sp;

class MockSupabase extends Mock implements sp.Supabase {}

void main() {
  late CourseRemoteDataSrc remoteDataSource;
  late FakeFirebaseFirestore firestore;
  late MockFirebaseAuth auth;
  late MockSupabase storage;

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

    storage = MockSupabase();
    remoteDataSource = CourseRemoteDataSrcImpl(
      firestore: firestore,
      storage: storage,
      auth: auth,
    );
  });

  group('addCourse', () {
    test('should add course to firestore', () async {
      // arrange
      final course = CourseModel.empty();

      // act
      await remoteDataSource.addCourse(course);

      // assert
      final firestoreData = await firestore.collection('courses').get();
      expect(firestoreData.docs.length, 1);

      final courseRef = firestoreData.docs.first;
      expect(courseRef.data()['id'], courseRef.id);

      final groupData = await firestore.collection('groups').get();
      expect(groupData.docs.length, 1);

      final groupRef = groupData.docs.first;
      expect(groupRef.data()['id'], groupRef.id);

      expect(courseRef.data()['groupId'], groupRef.id);
      expect(groupRef.data()['courseId'], courseRef.id);
    });
  });

  group('getCourse', () {
    test(
      'should return a List<Course> when the call is successful',
      () async {
        // Arrange
        final firstDate = DateTime.now();
        final secondDate = DateTime.now().add(const Duration(days: 1));
        final expectedCourses = [
          CourseModel.empty().copyWith(createdAt: firstDate),
          CourseModel.empty().copyWith(
            createdAt: secondDate,
            id: '1',
            title: 'Course 1',
          ),
        ];

        for (final course in expectedCourses) {
          await firestore.collection('courses').add(course.toMap());
        }

        // Act

        final result = await remoteDataSource.getCourses();

        // Assert
        expect(result, expectedCourses);
      },
    );
  });
}
