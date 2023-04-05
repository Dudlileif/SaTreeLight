import 'package:flutter/widgets.dart';

/// A configuration class to ensure that animations are the same and
/// easily configurable.
class AnimationConfig {
  static Duration get duration => const Duration(milliseconds: 1000);
  static Curve get curve => Curves.easeInOutSine;
}
