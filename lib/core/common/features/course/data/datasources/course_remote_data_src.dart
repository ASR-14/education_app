import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:education_app/core/common/features/course/data/models/course_model.dart';
import 'package:education_app/core/common/features/course/domain/entities/course.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

abstract class CourseRemoteDataSrc {
  const CourseRemoteDataSrc();
  Future<List<CourseModel>> getCourses();

  Future<void> addCourse(Course course);
}

class CourseRemoteDataSrcImpl implements CourseRemoteDataSrc {
  const CourseRemoteDataSrcImpl({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
    required FirebaseAuth auth,
  })  : _firestore = firestore,
        _storage = storage,
        _auth = auth;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final FirebaseAuth _auth;

  @override
  Future<void> addCourse(Course course) async {}
  
  @override
  Future<List<CourseModel>> getCourses() async{
    // TODO: implement getCourses
    throw UnimplementedError();
  }

  
}
