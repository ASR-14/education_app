import 'package:flutter/material.dart';

extension IntExtensions on int {
  SizedBox get sb => SizedBox(width: toDouble(), height: toDouble());
}
