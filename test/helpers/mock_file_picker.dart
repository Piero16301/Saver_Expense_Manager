import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFilePicker extends Mock
    with MockPlatformInterfaceMixin
    implements FilePickerPlatform {}

final class FakePlatformFile extends PlatformFile {
  FakePlatformFile({
    required this.name,
    required String path,
    this.bytes,
  }) : path = path,
       uri = Uri.file(path);

  @override
  final String name;

  @override
  final String? path;

  @override
  final Uri uri;

  final Uint8List? bytes;

  @override
  Never get xFile => throw UnimplementedError();

  @override
  Future<int> length() async => 100;

  @override
  int? lengthSync() => bytes?.length ?? 100;

  @override
  Future<Uint8List> readAsBytes() async => bytes ?? Uint8List(0);

  @override
  Stream<Uint8List> readAsByteStream() async* {}
}

When<Future<PlatformFile?>> whenPickFile(MockFilePicker mock) => when(
  () => mock.pickFile(
    dialogTitle: any(named: 'dialogTitle'),
    initialDirectory: any(named: 'initialDirectory'),
    type: any(named: 'type'),
    allowedExtensions: any(named: 'allowedExtensions'),
    onFileLoading: any(named: 'onFileLoading'),
    compressionQuality: any(named: 'compressionQuality'),
  ),
);
