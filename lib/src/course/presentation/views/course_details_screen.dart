import 'package:education_app/core/common/widgets/gradient_background.dart';
import 'package:education_app/core/extensions/context_extension.dart';
import 'package:education_app/core/res/media_res.dart';
import 'package:education_app/src/course/domain/entities/course.dart';
import 'package:flutter/material.dart';

class CourseDetailsScreen extends StatelessWidget {
  const CourseDetailsScreen(this.course, {super.key});

  static const routeName = '/course-details';

  final Course course;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: Text(course.title)),
      body: GradientBackground(
        image: MediaRes.homeGradientBackground,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              SizedBox(
                height: context.height * 3,
                child: Center(
                  child: course.image != null
                      ? Image.network(course.image!)
                      : Image.asset(MediaRes.casualMeditation),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
