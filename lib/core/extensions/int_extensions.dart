// extension IntExtensions on int {
//   SizedBox get sb => SizedBox(width: toDouble(), height: toDouble());
// }

// extension IntExt on int {
//   String get estimate {
//     if (this < 10) return '$this';
//     return 'over ${this ~/ 10 * 10}';
//   }
// }

extension IntExt on int {
  String get estimate {
    if (this <= 10) return '$this';
    var data = this - (this % 10);
    if (data == this) data = this - 5;
    return 'over $data';
  }
}
