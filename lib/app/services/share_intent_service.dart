import 'package:saver_expense_manager/app/app.dart';

class ShareIntentService {
  new({required this._shareIntentRepository});

  final ShareIntentRepository _shareIntentRepository;

  Future<void> initialize() => _shareIntentRepository.initialize();

  SharedFile? consumePendingSharedFile() =>
      _shareIntentRepository.consumePendingSharedFile();

  Stream<SharedFile> get sharedFileStream =>
      _shareIntentRepository.sharedFileStream;

  Future<void> dispose() => _shareIntentRepository.dispose();
}
