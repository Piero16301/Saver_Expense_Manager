import 'package:rive/rive.dart';

class RiveSrc {
  RiveSrc({
    required this.src,
    required this.artboard,
    required this.stateMachineName,
    this.status,
  });

  final String src;
  final String artboard;
  final String stateMachineName;
  late SMIBool? status;
}
