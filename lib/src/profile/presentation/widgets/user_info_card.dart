import 'package:flutter/material.dart';

class UserInfoCard extends StatelessWidget {
  const UserInfoCard({
    required this.infoThemeColour,
    required this.infoIcon,
    required this.infoTitle,
    required this.infoValue,
    super.key,
  });

  final Color infoThemeColour;
  final dynamic infoIcon;
  final String infoTitle;
  final String infoValue;

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
