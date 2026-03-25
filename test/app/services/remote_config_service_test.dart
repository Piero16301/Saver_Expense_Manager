import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/app.dart';

class MockRemoteConfigRepository extends Mock
    implements RemoteConfigRepository {}

void main() {
  late RemoteConfigService service;
  late MockRemoteConfigRepository mockRepository;

  setUp(() {
    mockRepository = MockRemoteConfigRepository();
    service = RemoteConfigService(remoteConfigRepository: mockRepository);
  });

  group('RemoteConfigService', () {
    test('can be instantiated', () {
      expect(service, isNotNull);
    });
  });
}
