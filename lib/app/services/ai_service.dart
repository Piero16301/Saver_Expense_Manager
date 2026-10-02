import 'package:saver_expense_manager/app/app.dart';

class AiService {
  AiService({required this._aiRepository});

  final AiRepository _aiRepository;

  Future<void> initialize() async {
    await _aiRepository.initialize();
  }

  bool get isLocalModelAvailable => _aiRepository.isLocalModelAvailable;

  Future<String?> generateContentFromTemplate({
    required String templateId,
    PromptPart? attachment,
    Map<String, Object?> inputs = const {},
  }) => _aiRepository.generateContentFromTemplate(
    templateId: templateId,
    attachment: attachment,
    inputs: inputs,
  );

  Future<String?> generateContentLocal({
    required PromptPart textPrompt,
    PromptPart? imagePrompt,
  }) => _aiRepository.generateContentLocal(
    textPrompt: textPrompt,
    imagePrompt: imagePrompt,
  );
}
