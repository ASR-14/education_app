import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:education_app/core/utils/typdefs.dart';
import 'package:education_app/src/auth/data/datasources/auth_remote_data_source.dart';
import 'package:education_app/src/auth/data/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseStorage extends Mock implements FirebaseStorage {}

class MockFirebaseAuth extends Mock implements FirebaseAuth {
  User? _user;
  @override
  User? get currentUser => null;

  set currentUser(User? value) {
    if (_user != value) _user = value;
  }
}

class MockFirebaseFirestorage extends Mock implements FirebaseFirestore {}

class MockUser extends Mock implements User {
  String _uid = 'Test uid';

  @override
  String get uid => _uid;

  set uid(String value) {
    if (_uid != value) _uid = value;
  }
}

class MockUserCredential extends Mock implements UserCredential {
  MockUserCredential([User? user]) : _user = user;

  User? _user;

  @override
  User? get user => _user;

  set user(User? value) {
    if (_user != value) _user = value;
  }
}

void main() {
  late FirebaseAuth authClient;
  late FirebaseFirestore cloudStoreClient;
  late FirebaseStorage dbClient;
  late AuthRemoteDataSource dataSource;
  late UserCredential userCredential;
  late DocumentReference<DataMap> documentReference;
  late MockUser mockUser;

  const tUser = LocalUserModel.empty();

  setUpAll(() async {
    mockUser = MockUser()..uid = documentReference.id;
    authClient = MockFirebaseAuth()..currentUser = mockUser;
    cloudStoreClient = MockFirebaseFirestorage();
    documentReference = await cloudStoreClient.collection('users').add(
          tUser.toMap(),
        );
    dbClient = MockFirebaseStorage();

    userCredential = MockUserCredential(mockUser);
    dataSource = AuthRemoteDataSourceImpl(
      authClient: authClient,
      cloudStoreClient: cloudStoreClient,
      dbClient: dbClient,
    );
  });

  group('signIn', () {
    test(
      'should complete successfully when call to the server is successful',
      () async {
        when(
          () => authClient.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer(
          (_) async => userCredential,
        );

        when(
          () => authClient.createUserWithEmailAndPassword(
            email: 'email',
            password: 'password',
          ),
        ).thenAnswer((_) async => userCredential);

        await dataSource.signUp(
          email: 'email',
          fullName: 'fullName',
          password: 'password',
        );

        //act
        final result = await dataSource.signIn(
          email: 'email',
          password: 'password',
        );

        expect(result.email, equals('email'));
      },
    );
  });
}
