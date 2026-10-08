import 'package:saver_expense_manager/app/app.dart';

class RemoteConfigService {
  RemoteConfigService({required this._remoteConfigRepository});

  final RemoteConfigRepository _remoteConfigRepository;

  Future<void> initialize() async => await _remoteConfigRepository.initialize();

  int get geminiAntLookbackDays =>
      _remoteConfigRepository.geminiAntLookbackDays;
  String get geminiModelName => _remoteConfigRepository.geminiModelName;
  String get geminiPromptDetectAntExpense =>
      _remoteConfigRepository.geminiPromptDetectAntExpense;
  String get geminiPromptExtractReceiptData =>
      _remoteConfigRepository.geminiPromptExtractReceiptData;
  int get paginationLimit => _remoteConfigRepository.paginationLimit;
  int get summaryLastMonths => _remoteConfigRepository.summaryLastMonths;

  String get homeInitialTab => _remoteConfigRepository.homeInitialTab;
}
