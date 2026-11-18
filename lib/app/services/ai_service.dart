import 'package:saver_expense_manager/app/app.dart';

class AiService {
  new({required this._aiRepository});

  final AiRepository _aiRepository;

  Future<void> initialize() async {
    await _aiRepository.initialize();
  }

  bool get isLocalModelAvailable => _aiRepository.isLocalModelAvailable;

  Future<String?> generateContentRemote({
    required List<PromptPart> prompt,
    String responseMimeType = 'text/plain',
  }) async {
    if (prompt.isEmpty) {
      return null;
    }

    final performance = getIt<PerformanceService>();
    final trace = performance.startTrace('gemini_generate_remote');

    try {
      final model = getIt<RemoteConfigService>().geminiModelName;
      return await _aiRepository.generateContentRemote(
        prompt: prompt,
        model: model,
        responseMimeType: responseMimeType,
      );
    } catch (e, stackTrace) {
      getIt<CrashService>().recordError(
        e,
        stackTrace,
        reason: 'AiService generateContentRemote error',
      );
      rethrow;
    } finally {
      performance.stopTrace(trace);
    }
  }

  Future<String?> generateContentLocal({
    required PromptPart textPrompt,
    PromptPart? imagePrompt,
  }) async {
    final performance = getIt<PerformanceService>();
    final trace = performance.startTrace('gemini_generate_local');
    try {
      return await _aiRepository.generateContentLocal(
        textPrompt: textPrompt,
        imagePrompt: imagePrompt,
      );
    } catch (e, stackTrace) {
      getIt<CrashService>().recordError(
        e,
        stackTrace,
        reason: 'AiService generateContentLocal error',
      );
      rethrow;
    } finally {
      performance.stopTrace(trace);
    }
  }
}
