import 'package:saver_expense_manager/app/app.dart';

class RemoteConfigService {
  RemoteConfigService({required RemoteConfigRepository remoteConfigRepository})
      : _remoteConfigRepository = remoteConfigRepository;

  final RemoteConfigRepository _remoteConfigRepository;

  Future<void> initialize() async {
    await _remoteConfigRepository.initialize();
  }

  String get homeInitialTab => _remoteConfigRepository.homeInitialTab;
  String get geminiModelId => _remoteConfigRepository.geminiModelId;
  String get geminiPromptExtractReceiptData =>
      _remoteConfigRepository.geminiPromptExtractReceiptData;
  String get geminiPromptDetectAntExpense =>
      _remoteConfigRepository.geminiPromptDetectAntExpense;
  int get geminiAntLookbackDays =>
      _remoteConfigRepository.geminiAntLookbackDays;
  int get paginationLimit => _remoteConfigRepository.paginationLimit;
}
