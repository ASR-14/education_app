import 'package:education_app/core/common/app/providers/course_of_the_day_notifier.dart';
import 'package:education_app/core/extensions/context_extension.dart';
import 'package:education_app/core/res/media_res.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';

class TinderCard extends StatelessWidget {
  const TinderCard({
    required this.isFirst,
    this.colour,
    super.key,
  });

  final bool isFirst;
  final Color? colour;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: isFirst ? const EdgeInsets.only(top: 65) : null,
        color: isFirst ? Colors.red : null,
        child: Center(
          child: Stack(
            children: [
              Container(
                alignment: Alignment.bottomCenter,
                height: 137,
                padding: const EdgeInsets.only(left: 20),
                decoration: BoxDecoration(
                  gradient: isFirst
                      ? const LinearGradient(
                          colors: [
                            Color(0xFF8E96FF),
                            Color(0xFFA06AF9),
                          ],
                        )
                      : null,
                  color: colour,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .15),
                      offset: const Offset(0, 5),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: isFirst
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            '${context.courseOfTheDay?.title ?? 'Course '
                                'of the Day'} final\nexams',
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 20,
                            ),
                          ),
                          const Row(
                            children: [
                              Icon(
                                IconlyLight.notification,
                                color: Colors.white,
                              ),
                              SizedBox(width: 8),
                              Text(
                                '45 minutes',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          )
                        ],
                      )
                    : null,
              ),
              if (isFirst)
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: Image.asset(
                    MediaRes.microscope,
                    height: 180,
                    width: 149,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
