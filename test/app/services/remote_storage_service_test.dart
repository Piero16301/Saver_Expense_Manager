import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/app.dart';

class FakeFile extends Fake implements File;

class MockRemoteStorageRepository extends Mock
    implements RemoteStorageRepository;

class MockCrashService extends Mock implements CrashService;

class MockTrace extends Mock implements Trace;

class MockPerformanceService extends Mock implements PerformanceService;

void main() {
  late RemoteStorageService service;
  late MockRemoteStorageRepository mockRepository;
  late MockCrashService mockCrashService;
  late MockTrace mockTrace;
  late MockPerformanceService mockPerformanceService;

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
    registerFallbackValue(MockTrace());
  });

  setUp(() async {
    mockRepository = MockRemoteStorageRepository();
    mockCrashService = MockCrashService();
    mockTrace = MockTrace();
    mockPerformanceService = MockPerformanceService();

    await getIt.reset();
    getIt
      ..registerSingleton<CrashService>(mockCrashService)
      ..registerSingleton<PerformanceService>(mockPerformanceService);

    when(() => mockPerformanceService.startTrace(any<String>()))
        .thenReturn(mockTrace);
    when(() => mockPerformanceService.stopTrace(any<Trace>())).thenReturn(null);

    service = RemoteStorageService(remoteStorageRepository: mockRepository);
  });

  group('RemoteStorageService', () {
    test('can be instantiated', () {
      expect(service, isNotNull);
    });

    test('deleteFile calls repository', () async {
      when(() => mockRepository.deleteFile(any<String>()))
          .thenAnswer((_) async => true);
      final result = await service.deleteFile('path');
      expect(result, isTrue);
      verify(() => mockRepository.deleteFile('path')).called(1);
      verify(() => mockPerformanceService.startTrace('storage_delete_file'))
          .called(1);
      verify(() => mockPerformanceService.stopTrace(mockTrace)).called(1);
    });

    test('uploadFile calls repository', () async {
      final bytes = Uint8List(0);
      when(() => mockRepository.uploadFile(any<Uint8List>(), any<String>()))
          .thenAnswer((_) async => 'url');
      final result = await service.uploadFile(bytes, 'path');
      expect(result, equals('url'));
      verify(() => mockRepository.uploadFile(bytes, 'path')).called(1);
      verify(() => mockPerformanceService.startTrace('storage_upload_file'))
          .called(1);
      verify(() => mockPerformanceService.stopTrace(mockTrace)).called(1);
    });

    test('getData calls repository', () async {
      final data = Uint8List(0);
      when(() => mockRepository.getData(any<String>()))
          .thenAnswer((_) async => data);
      final result = await service.getData('path');
      expect(result, equals(data));
      verify(() => mockRepository.getData('path')).called(1);
      verify(() => mockPerformanceService.startTrace('storage_get_data'))
          .called(1);
      verify(() => mockPerformanceService.stopTrace(mockTrace)).called(1);
    });

    test('getDownloadURL calls repository', () async {
      when(() => mockRepository.getDownloadURL(any<String>()))
          .thenAnswer((_) async => 'https://example.com/file.pdf');
      final result = await service.getDownloadURL('path');
      expect(result, equals('https://example.com/file.pdf'));
      verify(() => mockRepository.getDownloadURL('path')).called(1);
      verify(
        () => mockPerformanceService.startTrace('storage_get_download_url'),
      ).called(1);
      verify(() => mockPerformanceService.stopTrace(mockTrace)).called(1);
    });

    test('deleteFile records error and returns false on exception', () async {
      when(() => mockRepository.deleteFile(any<String>()))
          .thenThrow(Exception('Delete Fail'));
      final result = await service.deleteFile('path');
      expect(result, isFalse);
      verify(
        () => mockCrashService.recordError(
          any<Object>(),
          any<StackTrace?>(),
          reason: 'RemoteStorageService deleteFile error',
        ),
      ).called(1);
    });

    test('uploadFile records error and returns null on exception', () async {
      when(() => mockRepository.uploadFile(any<Uint8List>(), any<String>()))
          .thenThrow(Exception('Upload Fail'));
      final result = await service.uploadFile(Uint8List(0), 'path');
      expect(result, isNull);
      verify(
        () => mockCrashService.recordError(
          any<Object>(),
          any<StackTrace?>(),
          reason: 'RemoteStorageService uploadFile error',
        ),
      ).called(1);
    });

    test('getData records error and returns null on exception', () async {
      when(() => mockRepository.getData(any<String>()))
          .thenThrow(Exception('Get Data Fail'));
      final result = await service.getData('path');
      expect(result, isNull);
      verify(
        () => mockCrashService.recordError(
          any<Object>(),
          any<StackTrace?>(),
          reason: 'RemoteStorageService getData error',
        ),
      ).called(1);
    });

    test(
      'getDownloadURL records error and returns null on exception',
      () async {
        when(() => mockRepository.getDownloadURL(any<String>()))
            .thenThrow(Exception('Download URL Fail'));
        final result = await service.getDownloadURL('path');
        expect(result, isNull);
        verify(
          () => mockCrashService.recordError(
            any<Object>(),
            any<StackTrace?>(),
            reason: 'RemoteStorageService getDownloadURL error',
          ),
        ).called(1);
      },
    );
  });
}
