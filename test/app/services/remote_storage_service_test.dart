import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/app.dart';

class MockRemoteStorageRepository extends Mock
    implements RemoteStorageRepository {}

void main() {
  late RemoteStorageService service;
  late MockRemoteStorageRepository mockRepository;

  setUp(() {
    mockRepository = MockRemoteStorageRepository();
    service = RemoteStorageService(remoteStorageRepository: mockRepository);
  });

  group('RemoteStorageService', () {
    test('can be instantiated', () {
      expect(service, isNotNull);
    });
  });
}
