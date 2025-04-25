import 'package:dartz/dartz.dart';
import 'package:education_app/core/errors/exceptions.dart';
import 'package:education_app/core/errors/failures.dart';
import 'package:education_app/src/auth/data/models/user_model.dart';
import 'package:education_app/src/auth/domain/entities/user.dart';
import 'package:education_app/src/chat/data/datasources/chat_remote_data_source.dart';
import 'package:education_app/src/chat/data/models/group_model.dart';
import 'package:education_app/src/chat/data/models/message_model.dart';
import 'package:education_app/src/chat/data/repos/chat_repo_impl.dart';
import 'package:education_app/src/chat/domain/entities/group.dart';
import 'package:education_app/src/chat/domain/entities/message.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockChatRemoteDataSource extends Mock implements ChatRemoteDataSource {}

void main() {
  late MockChatRemoteDataSource remoteDataSource;
  late ChatRepoImpl repoImpl;

  final tMessage = Message.empty();

  const tLocalUser = LocalUserModel.empty();

  const tUserId = 'id';

  setUpAll(() => registerFallbackValue(tMessage));

  setUp(() {
    remoteDataSource = MockChatRemoteDataSource();
    repoImpl = ChatRepoImpl(remoteDataSource);
  });

  group('getMessages', () {
    final expectedMessages = [
      MessageModel.empty(),
      MessageModel.empty().copyWith(id: '1', message: 'Message 1'),
    ];
    const groupId = 'sampleGroupId';

    final serverFailure = ServerFailure(
      message: 'Server error',
      statusCode: '500',
    );
    test(
      'should return a stream of Right<List<Message>> when remote data source '
      'is successful',
      () {
        when(() => remoteDataSource.getMessages(any())).thenAnswer(
          (_) => Stream.value(expectedMessages),
        );

        final stream = repoImpl.getMessages(groupId);

        expect(
          stream,
          emits(Right<Failure, List<Message>>(expectedMessages)),
        );

        verify(() => remoteDataSource.getMessages(groupId)).called(1);
        verifyNoMoreInteractions(remoteDataSource);
      },
    );

    test(
      'should return a stream of Left<Failure> when remote data source throws '
      'an error',
      () {
        when(() => remoteDataSource.getMessages(any())).thenAnswer(
          (_) => Stream.error(
            ServerException(
              message: serverFailure.message,
              statusCode: serverFailure.statusCode.toString(),
            ),
          ),
        );

        final stream = repoImpl.getMessages(groupId);

        expect(
          stream,
          emits(equals(Left<Failure, List<Message>>(serverFailure))),
        );

        verify(() => remoteDataSource.getMessages(groupId)).called(1);
        verifyNoMoreInteractions(remoteDataSource);
      },
    );
  });

  group('getGroups', () {
    final expectedGroups = [
      GroupModel.empty(),
      GroupModel.empty().copyWith(id: '1', name: 'Group 1'),
    ];
    // const groupId = 'sampleGroupId';

    final serverFailure = ServerFailure(
      message: 'Server error',
      statusCode: '500',
    );
    test(
      'should return a stream of Right<List<Group>> when remote data source '
      'is successful',
      () {
        when(() => remoteDataSource.getGroups()).thenAnswer(
          (_) => Stream.value(expectedGroups),
        );

        final stream = repoImpl.getGroups();

        expect(
          stream,
          emits(Right<Failure, List<Group>>(expectedGroups)),
        );

        verify(() => remoteDataSource.getGroups()).called(1);
        verifyNoMoreInteractions(remoteDataSource);
      },
    );

    test(
      'should return a stream of Left<Failure> when remote data source throws '
      'an error',
      () {
        when(() => remoteDataSource.getGroups()).thenAnswer(
          (_) => Stream.error(
            ServerException(
              message: serverFailure.message,
              statusCode: serverFailure.statusCode.toString(),
            ),
          ),
        );

        final stream = repoImpl.getGroups();

        expect(
          stream,
          emits(equals(Left<Failure, List<Group>>(serverFailure))),
        );

        verify(() => remoteDataSource.getGroups()).called(1);
        verifyNoMoreInteractions(remoteDataSource);
      },
    );
  });

  group('sendMessage', () {
    test(
      'should complete successfully when call to remote source is successful',
      () async {
        when(() => remoteDataSource.sendMessage(any())).thenAnswer(
          (_) async => Future.value(),
        );

        final result = await repoImpl.sendMessage(tMessage);

        expect(result, equals(const Right<dynamic, void>(null)));

        verify(() => remoteDataSource.sendMessage(tMessage)).called(1);

        verifyNoMoreInteractions(remoteDataSource);
      },
    );

    test(
      'should return [ServerFailure] when call to remote source is '
      'unsuccessful',
      () async {
        when(() => remoteDataSource.sendMessage(any())).thenThrow(
          const ServerException(message: 'message', statusCode: 'statusCode'),
        );

        final result = await repoImpl.sendMessage(tMessage);

        expect(
          result,
          equals(
            Left<ServerFailure, dynamic>(
              ServerFailure(message: 'message', statusCode: 'statusCode'),
            ),
          ),
        );

        verify(() => remoteDataSource.sendMessage(tMessage)).called(1);
        verifyNoMoreInteractions(remoteDataSource);
      },
    );
  });

  group('joinGroup', () {
    const groupId = 'sampleGroupId';
    const userId = 'sampleUserId';

    test(
      'should complete successfully when call to remote source is successful',
      () async {
        when(
          () => remoteDataSource.joinGroup(
            groupId: any(named: 'groupId'),
            userId: any(named: 'userId'),
          ),
        ).thenAnswer(
          (_) async => Future.value(),
        );

        final result =
            await repoImpl.joinGroup(groupId: groupId, userId: userId);

        expect(result, equals(const Right<dynamic, void>(null)));

        verify(
          () => remoteDataSource.joinGroup(
            groupId: groupId,
            userId: userId,
          ),
        ).called(1);

        verifyNoMoreInteractions(remoteDataSource);
      },
    );

    test(
      'should return [ServerFailure] when call to remote source is '
      'unsuccessful',
      () async {
        when(
          () => remoteDataSource.joinGroup(
            groupId: any(named: 'groupId'),
            userId: any(named: 'userId'),
          ),
        ).thenThrow(
          const ServerException(message: 'message', statusCode: 'statusCode'),
        );

        final result =
            await repoImpl.joinGroup(groupId: groupId, userId: userId);

        expect(
          result,
          equals(
            Left<ServerFailure, dynamic>(
              ServerFailure(message: 'message', statusCode: 'statusCode'),
            ),
          ),
        );

        verify(
          () => remoteDataSource.joinGroup(
            groupId: groupId,
            userId: userId,
          ),
        ).called(1);
        verifyNoMoreInteractions(remoteDataSource);
      },
    );
  });

  group('leaveGroup', () {
    const groupId = 'sampleGroupId';
    const userId = 'sampleUserId';

    test(
      'should complete successfully when call to remote source is successful',
      () async {
        when(
          () => remoteDataSource.leaveGroup(
            groupId: any(named: 'groupId'),
            userId: any(named: 'userId'),
          ),
        ).thenAnswer(
          (_) async => Future.value(),
        );

        final result =
            await repoImpl.leaveGroup(groupId: groupId, userId: userId);

        expect(result, equals(const Right<dynamic, void>(null)));

        verify(
          () => remoteDataSource.leaveGroup(
            groupId: groupId,
            userId: userId,
          ),
        ).called(1);

        verifyNoMoreInteractions(remoteDataSource);
      },
    );

    test(
      'should return [ServerFailure] when call to remote source is '
      'unsuccessful',
      () async {
        when(
          () => remoteDataSource.leaveGroup(
            groupId: any(named: 'groupId'),
            userId: any(named: 'userId'),
          ),
        ).thenThrow(
          const ServerException(message: 'message', statusCode: 'statusCode'),
        );

        final result =
            await repoImpl.leaveGroup(groupId: groupId, userId: userId);

        expect(
          result,
          equals(
            Left<ServerFailure, dynamic>(
              ServerFailure(message: 'message', statusCode: 'statusCode'),
            ),
          ),
        );

        verify(
          () => remoteDataSource.leaveGroup(
            groupId: groupId,
            userId: userId,
          ),
        ).called(1);
        verifyNoMoreInteractions(remoteDataSource);
      },
    );
  });

  group('getUserById', () {
    test(
      'should complete successfully when call to remote source is successful',
      () async {
        when(
          () => remoteDataSource.getUserById(any()),
        ).thenAnswer((_) async => tLocalUser);

        final result = await repoImpl.getUserById(tUserId);

        expect(result, equals(const Right<dynamic, LocalUser>(tLocalUser)));

        verify(() => remoteDataSource.getUserById(tUserId)).called(1);

        verifyNoMoreInteractions(remoteDataSource);
      },
    );

    test(
      'should return [ServerFailure] when call to remote source is '
      'unsuccessful',
      () async {
        when(
          () => remoteDataSource.getUserById(
            any(),
          ),
        ).thenThrow(
          const ServerException(message: 'message', statusCode: 'statusCode'),
        );

        final result = await repoImpl.getUserById(tUserId);

        expect(
          result,
          equals(
            Left<dynamic, LocalUser>(
              ServerFailure(message: 'message', statusCode: 'statusCode'),
            ),
          ),
        );

        verify(() => remoteDataSource.getUserById(tUserId)).called(1);

        verifyNoMoreInteractions(remoteDataSource);
      },
    );
  });
}
