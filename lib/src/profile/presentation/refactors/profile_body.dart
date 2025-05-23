import 'package:education_app/core/common/app/providers/user_provider.dart';
import 'package:education_app/core/extensions/context_extension.dart';
import 'package:education_app/core/res/colours.dart';
import 'package:education_app/core/res/media_res.dart';
import 'package:education_app/core/services/injection_container.dart';
import 'package:education_app/src/course/features/exams/presentation/views/add_exam_ui_view.dart';
import 'package:education_app/src/course/features/exams/presentation/views/add_exam_view.dart';
import 'package:education_app/src/course/features/materials/presentation/views/add_materials_view.dart';
import 'package:education_app/src/course/features/videos/presentation/views/add_video_view.dart';
import 'package:education_app/src/course/presentation/cubit/course_cubit.dart';
import 'package:education_app/src/course/presentation/widgets/add_course_sheet.dart';
import 'package:education_app/src/notifications/presentation/cubit/notification_cubit.dart';
import 'package:education_app/src/profile/presentation/widgets/admin_button.dart';
import 'package:education_app/src/profile/presentation/widgets/user_info_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';

class ProfileBody extends StatelessWidget {
  const ProfileBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (_, provider, __) {
        final user = provider.user;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: UserInfoCard(
                    infoThemeColour: Colours.physicsTileColour,
                    infoIcon: const Icon(
                      IconlyLight.document,
                      size: 24,
                      color: Color(0xFF767DFF),
                    ),
                    infoTitle: 'Courses',
                    infoValue: user!.enrolledCourseIds.length.toString(),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: UserInfoCard(
                    infoThemeColour: Colours.languageTileColour,
                    infoIcon: Image.asset(
                      MediaRes.scoreboard,
                      height: 24,
                      width: 24,
                    ),
                    infoTitle: 'Score',
                    infoValue: user.points.toString(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: UserInfoCard(
                    infoThemeColour: Colours.biologyTileColour,
                    infoIcon: const Icon(
                      IconlyLight.user,
                      color: Color(0xFF56AEFF),
                      size: 24,
                    ),
                    infoTitle: 'Followers',
                    infoValue: user.followers.length.toString(),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: UserInfoCard(
                    infoThemeColour: Colours.chemistryTileColour,
                    infoIcon: const Icon(
                      IconlyLight.user,
                      color: Color(0xFFFF84AA),
                      size: 24,
                    ),
                    infoTitle: 'Following',
                    infoValue: user.following.length.toString(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            if (context.currentUser!.isAdmin) ...[
              AdminButton(
                label: 'Add Course',
                icon: IconlyLight.paper_upload,
                onPressed: () {
                  showModalBottomSheet<void>(
                    context: context,
                    backgroundColor: Colors.white,
                    isScrollControlled: true,
                    showDragHandle: true,
                    elevation: 0,
                    useSafeArea: true,
                    builder: (_) => MultiBlocProvider(
                      providers: [
                        BlocProvider.value(value: sl<CourseCubit>()),
                        BlocProvider(create: (_) => sl<NotificationCubit>()),
                      ],
                      child: const AddCourseSheet(),
                    ),
                  );
                },
              ),
              AdminButton(
                label: 'Add Video',
                icon: IconlyLight.video,
                onPressed: () {
                  Navigator.pushNamed(context, AddVideoView.routeName);
                },
              ),
              AdminButton(
                label: 'Add Materials',
                icon: IconlyLight.paper_download,
                onPressed: () {
                  Navigator.pushNamed(context, AddMaterialsView.routeName);
                },
              ),
              AdminButton(
                label: 'Add Exam',
                icon: IconlyLight.document,
                onPressed: () {
                  Navigator.pushNamed(context, AddExamView.routeName);
                },
              ),
              AdminButton(
                label: 'Add Exam UI',
                icon: IconlyLight.edit,
                onPressed: () {
                  Navigator.pushNamed(context, AddExamUIView.routeName);
                },
              ),
            ],
          ],
        );
      },
    );
  }
}
