import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:saver_expense_manager/app/app.dart';

class SharedFile extends Equatable {
  const new({
    required this.path,
    required this.name,
    required this.movementType,
    this.bytes,
  });

  factory fromMap(Map<Object?, Object?> map) {
    return SharedFile(
      path: map['path'] as String? ?? '',
      name: map['name'] as String? ?? '',
      movementType: CategoryType.categoryTypeFromJson(
        map['movementType'] as String? ?? '',
      ),
    );
  }

  final String path;
  final String name;
  final CategoryType movementType;
  final Uint8List? bytes;

  String get extension {
    final source = name.isNotEmpty ? name : path;
    final dotIndex = source.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == source.length - 1) {
      return '';
    }
    return source.substring(dotIndex + 1).toLowerCase();
  }

  bool get isSupported =>
      (path.isNotEmpty || bytes != null) &&
      AppVariables.allowedExtensions.contains(extension);

  @override
  List<Object?> get props => [path, name, movementType, bytes];
}
