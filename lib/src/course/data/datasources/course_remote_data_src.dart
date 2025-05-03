import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:education_app/src/course/data/models/course_model.dart';
import 'package:education_app/src/course/domain/entities/course.dart';
import 'package:education_app/core/errors/exceptions.dart';
import 'package:education_app/src/chat/data/models/group_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sp;

abstract class CourseRemoteDataSrc {
  const CourseRemoteDataSrc();
  Stream<List<CourseModel>> getCourses();

  Future<void> addCourse(Course course);
}

class CourseRemoteDataSrcImpl implements CourseRemoteDataSrc {
  const CourseRemoteDataSrcImpl({
    required FirebaseFirestore firestore,
    required sp.Supabase storage,
    required FirebaseAuth auth,
  })  : _firestore = firestore,
        _storage = storage,
        _auth = auth;

  final FirebaseFirestore _firestore;
  // final FirebaseStorage _storage;
  final sp.Supabase _storage;
  final FirebaseAuth _auth;

  @override
  Future<void> addCourse(Course course) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw const ServerException(
          message: 'User is not authenticated',
          statusCode: '401',
        );
      }
      final courseRef = _firestore.collection('courses').doc();
      final groupRef = _firestore.collection('groups').doc();

      var courseModel = (course as CourseModel).copyWith(
        id: courseRef.id,
        groupId: groupRef.id,
      );

      if (courseModel.imageIsFile) {
        // final imageRef = _storage.ref().child(
        //       'courses/${courseModel.id}/profile_image/${courseModel.title}--pfp',
        //     );
        // await imageRef.putFile(File(courseModel.image!)).then((value) async {
        //   final url = await value.ref.getDownloadURL();
        //   courseModel = courseModel.copyWith(image: url);
        // });
        final path =
            'courses/${courseModel.id}/profile_image/${courseModel.title}--pfp';

        final ref = _storage.client.storage.from('storage');
        await ref.upload(path, File(courseModel.image!));
        final url = ref.getPublicUrl(path);
        courseModel = courseModel.copyWith(image: url);
      }

      await courseRef.set(courseModel.toMap());

      final group = GroupModel(
        id: groupRef.id,
        name: courseModel.title,
        members: const [],
        courseId: courseRef.id,
        groupImageUrl: courseModel.image,
      );

      return groupRef.set(group.toMap());
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Unknow error occurred',
        statusCode: e.code,
      );
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString(), statusCode: '505');
    }
  }

  @override
  Stream<List<CourseModel>> getCourses() {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw const ServerException(
          message: 'User is not authenticated',
          statusCode: '401',
        );
      }
      return _firestore.collection('courses').snapshots().map((snapshot) {
        return snapshot.docs
            .map((doc) => CourseModel.fromMap(doc.data()))
            .toList();
      });
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Unknown error occurred',
        statusCode: e.code,
      );
    } catch (e) {
      throw ServerException(message: e.toString(), statusCode: '505');
    }
  }
}
