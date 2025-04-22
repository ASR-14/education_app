import 'package:education_app/core/common/widgets/gradient_background.dart';
import 'package:education_app/core/res/media_res.dart';
import 'package:education_app/src/quick_access/presentation/refactors/quick_access_app_bar.dart';
import 'package:education_app/src/quick_access/presentation/refactors/quick_access_header.dart';
import 'package:education_app/src/quick_access/presentation/refactors/quick_access_tab_bar.dart';
import 'package:education_app/src/quick_access/presentation/refactors/quick_access_tab_body.dart';
import 'package:flutter/material.dart';

class QuickAccessView extends StatelessWidget {
  const QuickAccessView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: QuickAccessAppBar(),
      body: GradientBackground(
        image: MediaRes.documentsGradientBackground,
        child: Center(
          child: Column(
            children: [
              Expanded(flex: 2, child: QuickAccessHeader()),
              Expanded(child: QuickAccessTabBar()),
              Expanded(flex: 2, child: QuickAccessTabBody()),
            ],
          ),
        ),
      ),
    );
  }
}
