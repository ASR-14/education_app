import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:education_app/core/errors/exceptions.dart';
import 'package:education_app/src/auth/data/models/user_model.dart';
import 'package:education_app/src/chat/data/datasources/chat_remote_data_source.dart';
import 'package:education_app/src/chat/data/models/group_model.dart';
import 'package:education_app/src/chat/data/models/message_model.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in_mocks/google_sign_in_mocks.dart';

void main() {
  late ChatRemoteDataSourceImpl remoteDataSource;
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

    remoteDataSource = ChatRemoteDataSourceImpl(
      firestore: firestore,
      auth: auth,
    );
  });

  Future<DocumentReference> addMessage(
      MessageModel message,
      ) async {
    return firestore
        .collection('groups')
        .doc(message.groupId)
        .collection('messages')
        .add(message.toMap());
  }


  group('sendMessage', () {
    test('should complete successfully when the call is successful', () async {
      // Arrange
      final message = MessageModel.empty().copyWith(
        id: '1',
        message: 'Message 1',
      );

      // create group for [remoteDataSource.sendMessage] to work
      await firestore
          .collection('groups')
          .doc(message.groupId)
          .set(GroupModel.empty().copyWith(id: message.groupId).toMap());

      // Act
      await remoteDataSource.sendMessage(message);

      // Assert
      final messageDoc = await firestore
          .collection('groups')
          .doc(message.groupId)
          .collection('messages')
          .get();
      expect(messageDoc.docs.length, equals(1));
      expect(messageDoc.docs.first.data()['message'], equals(message.message));
    });
  });

  group('getMessages', () {
    test('should return a stream of messages when the call is successful', ()
        async {
      // Arrange
      const groupId = 'groupId';
      final expectedMessages = [
        MessageModel.empty().copyWith(groupId: groupId),
        MessageModel.empty().copyWith(
          id: '1',
          message: 'Message 1',
          groupId: groupId,
        ),
      ];

      // Create a fake collection, document, and query with the expected
      // messages
      await firestore
          .collection('groups')
          .doc(groupId).set(GroupModel.empty().copyWith(id: groupId).toMap());

      for(final message in expectedMessages) {
        await addMessage(message);
      }

      // Act
      final result = remoteDataSource.getMessages(groupId);

      // Assert
      expect(result, emitsInOrder([equals(expectedMessages)]));
    });

    test('should return a stream of empty list when an error occurs', () {
      // Arrange
      const groupId = 'groupId';

      // Act
      final result = remoteDataSource.getMessages(groupId);

      // Assert
      expect(
        result,
        emits(equals(<MessageModel>[])),
      );
    });
  });

  group('getGroups', () {
    test('should return a stream of groups when the call is successful', () {
      // Arrange
      final expectedGroups = [
        GroupModel.empty().copyWith(
          id: '1',
          courseId: '1',
          name: 'Group 1',
        ),
        GroupModel.empty().copyWith(
          id: '2',
          courseId: '2',
          name: 'Group 2',
        ),
      ];

      // Create a fake collection, document, and query with the expected
      // groups
      firestore.collection('groups').add(expectedGroups[0].toMap());
      firestore.collection('groups').add(expectedGroups[1].toMap());
      // Act
      final result = remoteDataSource.getGroups();

      // Assert
      expect(result, emitsInOrder([equals(expectedGroups)]));
    });

    test('should return a stream of empty list when there are no groups', () {
      // Arrange

      // Act
      final result = remoteDataSource.getGroups();

      // Assert
      expect(
        result,
        emits(equals(<GroupModel>[])),
      );
    });
  });


  group('joinGroup', () {
    test('should complete successfully when the call is successful', () async {
      // Arrange
      final groupDocRef = await firestore.collection('groups').add({
        'members': <String>[],
      });

      final userDocRef = await firestore.collection('users').add({
        'groups': <String>[],
      });

      final groupId = groupDocRef.id;
      final userId = userDocRef.id;

      // Act
      await remoteDataSource.joinGroup(groupId: groupId, userId: userId);

      // Assert
      final groupDoc = await firestore.collection('groups').doc(groupId).get();
      final userDoc = await firestore.collection('users').doc(userId).get();
      expect(groupDoc.data()!['members'], contains(userId));
      expect(userDoc.data()!['groups'], contains(groupId));
    });
  });

  group('leaveGroup', () {
    test('should complete successfully when the call is successful', () async {
      // Arrange

      final groupDocRef = firestore.collection('groups').doc();
      final userDocRef = firestore.collection('users').doc();

      final groupId = groupDocRef.id;
      final userId = userDocRef.id;

      await groupDocRef.set({
        'id': groupId,
      'members': <String>[userId],
      });


      await userDocRef.set({
        'id': userId,
        'groups': [groupId],
      });

      var groupDoc = await firestore.collection('groups').doc(groupId).get();
      var userDoc = await firestore.collection('users').doc(userId).get();
      expect(groupDoc.data()!['members'], contains(userId));
      expect(userDoc.data()!['groups'], contains(groupId));

      // Act
      await remoteDataSource.leaveGroup(
        groupId: groupId,
        userId: userId,
      );

      // Assert
      groupDoc = await firestore.collection('groups').doc(groupId).get();
      userDoc = await firestore.collection('users').doc(userId).get();
      expect(groupDoc.data()!['members'], isNot(contains(userId)));
      expect(userDoc.data()!['groups'], isNot(contains(groupId)));
    });
  });

  group('getUserById', () {
    test('should return a user when the call is successful', () async {
      // Arrange
      const userId = 'uid';
      final expectedUser = const LocalUserModel.empty().copyWith(uid: userId);
      await firestore.collection('users').doc(userId).set(expectedUser.toMap());

      // Act
      final result = await remoteDataSource.getUserById(userId);

      // Assert
      expect(result, equals(expectedUser));
    });

    test(
      'should throw ServerException when the call is unsuccessful',
          () async {
        // Arrange
        const userId = 'asdfaosidjfpsdiojf';

        // Act
        final call = remoteDataSource.getUserById;

        // Assert
        expect(() => call(userId), throwsA(isA<ServerException>()));
      },
    );
  });
}
