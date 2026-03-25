import 'package:saver_expense_manager/app/app.dart';

class AiService {
  AiService({required AiRepository aiRepository})
      : _aiRepository = aiRepository;

  final AiRepository _aiRepository;

  Future<void> initialize() async {
    await _aiRepository.initialize();
  }

  bool get isLocalModelAvailable => _aiRepository.isLocalModelAvailable;

  Future<String?> generateContentRemote({
    required List<PromptPart> prompt,
    String responseMimeType = 'text/plain',
  }) =>
      _aiRepository.generateContentRemote(
        prompt: prompt,
        responseMimeType: responseMimeType,
      );

  Future<String?> generateContentLocal({
    required PromptPart textPrompt,
    PromptPart? imagePrompt,
  }) =>
      _aiRepository.generateContentLocal(
        textPrompt: textPrompt,
        imagePrompt: imagePrompt,
      );
}
