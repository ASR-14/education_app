// import 'dart:io';

// import 'package:education_app/src/course/data/models/course_model.dart';
// import 'package:education_app/src/course/features/videos/data/datasources/video_remote_data_src.dart';
// import 'package:education_app/src/course/features/videos/data/models/video_model.dart';
// import 'package:education_app/src/course/features/videos/domain/entities/video.dart';
// import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
// import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:google_sign_in_mocks/google_sign_in_mocks.dart';

// void main() {
//   late VideoRemoteDataSrc remoteDataSource;
//   late FakeFirebaseFirestore firestore;
//   late MockFirebaseAuth auth;
//   late MockFirebaseStorage storage;

//   final tVideo = VideoModel.empty();

//   setUp(() async {
//     firestore = FakeFirebaseFirestore();
//     final user = MockUser(
//       uid: 'uid',
//       email: 'email',
//       displayName: 'displayName',
//     );

//     final googleSignIn = MockGoogleSignIn();
//     final signInAccount = await googleSignIn.signIn();
//     final googleAuth = await signInAccount!.authentication;
//     final credential = GoogleAuthProvider.credential(
//       accessToken: googleAuth.accessToken,
//       idToken: googleAuth.idToken,
//     );
//     auth = MockFirebaseAuth(mockUser: user);
//     await auth.signInWithCredential(credential);

//     storage = MockFirebaseStorage();
//     remoteDataSource = VideoRemoteDataSrcImpl(
//       auth: auth,
//       firestore: firestore,
//       storage: storage,
//     );

//     await firestore
//         .collection('courses')
//         .doc(tVideo.courseId)
//         .set(CourseModel.empty().copyWith(id: tVideo.courseId).toMap());
//   });

//   group('addVideo', () {
//     test(
//       'should add the provided [Video] to the firestore',
//       () async {
//         await remoteDataSource.addVideo(tVideo);

//         final videoCollectionRef = await firestore
//             .collection('courses')
//             .doc(tVideo.courseId)
//             .collection('videos')
//             .get();

//         expect(videoCollectionRef.docs.length, 1);
//         expect(videoCollectionRef.docs.first.data()['title'], tVideo.title);

//         final courseRef =
//             await firestore.collection('courses').doc(tVideo.courseId).get();
//         expect(courseRef.data()!['numberOfVideos'], 1);
//       },
//     );

//     test(
//       'should add the provided thumbnail to the storage if it is a file',
//       () async {
//         final thumbnailFile =
//             File('assets/images/auth_gradient_background.png');
//         final video = tVideo.copyWith(
//           thumbnailIsFile: true,
//           thumbnail: thumbnailFile.path,
//         );
//         await remoteDataSource.addVideo(video);

//         final videoCollectionRef = await firestore
//             .collection('courses')
//             .doc(tVideo.courseId)
//             .collection('videos')
//             .get();

//         expect(videoCollectionRef.docs.length, 1);

//         final savedVideo = videoCollectionRef.docs.first.data();

//         final thumbnaulURL = await storage
//             .ref()
//             .child(
//               'courses/${tVideo.courseId}/videos/${savedVideo['id']}/thumbnail',
//             )
//             .getDownloadURL();

//         expect(savedVideo['thumbnail'], equals(thumbnaulURL));
//       },
//     );
//   });

//   group('getVideos', () {
//     test(
//       'should return a list of [Video] from the firestore',
//       () async {
//         await remoteDataSource.addVideo(tVideo);

//         final result = await remoteDataSource.getVideos(tVideo.courseId);

//         expect(result, isA<List<Video>>());
//         expect(result.length, equals(1));
//         expect(result.first.thumbnail, equals(tVideo.thumbnail));
//       },
//     );

//     test(
//       'should return an empty list when there is an error',
//       () async {
//         final result = await remoteDataSource.getVideos(tVideo.courseId);

//         expect(result, isA<List<Video>>());
//         expect(result.isEmpty, isTrue);
//       },
//     );
//   });
// }
