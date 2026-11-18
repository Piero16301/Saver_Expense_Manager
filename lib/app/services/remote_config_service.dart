import 'package:saver_expense_manager/app/app.dart';

class RemoteConfigService {
  new({required this._remoteConfigRepository});

  final RemoteConfigRepository _remoteConfigRepository;

  Future<void> initialize() async {
    final performance = getIt<PerformanceService>();
    final trace = performance.startTrace('remote_config_init');
    try {
      await _remoteConfigRepository.initialize();
    } on Exception catch (e, stackTrace) {
      getIt<CrashService>().recordError(
        e,
        stackTrace,
        reason: 'RemoteConfig initialization failed',
      );
    } finally {
      performance.stopTrace(trace);
    }
  }

  int get geminiAntLookbackDays =>
      _remoteConfigRepository.geminiAntLookbackDays;
  String get geminiModelName => _remoteConfigRepository.geminiModelName;
  String get geminiPromptDetectAntExpense =>
      _remoteConfigRepository.geminiPromptDetectAntExpense;
  String get geminiPromptExtractReceiptData =>
      _remoteConfigRepository.geminiPromptExtractReceiptData;
  int get paginationLimit => _remoteConfigRepository.paginationLimit;
  int get summaryLastMonths => _remoteConfigRepository.summaryLastMonths;
  int get summaryLastYears => _remoteConfigRepository.summaryLastYears;

  String get homeInitialTab => _remoteConfigRepository.homeInitialTab;
}
