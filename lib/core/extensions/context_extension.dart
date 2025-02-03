import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

extension ContextExt on BuildContext {
  ThemeData get theme => Theme.of(this);
}
