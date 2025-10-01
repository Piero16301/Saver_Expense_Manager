import 'package:firebase_ui_storage/firebase_ui_storage.dart';
import 'package:flutter/material.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';

class AppFileField extends StatelessWidget {
  const AppFileField({
    required this.label,
    required this.labelAdd,
    required this.onAdd,
    required this.onRemove,
    required this.openFile,
    required this.attachments,
    super.key,
  });

  final String label;
  final String labelAdd;
  final void Function(String) onAdd;
  final void Function(String) onRemove;
  final void Function(String) openFile;
  final List<String> attachments;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (var i = 0; i < attachments.length; i++)
                    SizedBox(
                      child: GestureDetector(
                        onTap: () => openFile(attachments[i]),
                        child: Chip(
                          label: Text(
                            getAttachmentName(attachments[i], i + 1, l10n),
                          ),
                          avatar: Icon(getAttachmentIcon(attachments[i])),
                          onDeleted: () => onRemove(attachments[i]),
                        ),
                      ),
                    ),
                  Center(
                    child: UploadButton(
                      onError: (error, stackTrace) {
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            SnackBar(
                              content: Text('Error: $error'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                      },
                      onUploadComplete: (ref) => onAdd(ref.name),
                      extensions: const ['pdf', 'png', 'jpg', 'jpeg'],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  String getAttachmentName(String path, int index, AppLocalizations l10n) {
    switch (path.split('.').last) {
      case 'pdf':
        return l10n.movementPdfType;
      case 'png':
      case 'jpg':
      case 'jpeg':
        return l10n.movementImageType;
      default:
        return l10n.movementCustomType;
    }
  }

  IconData getAttachmentIcon(String path) {
    switch (path.split('.').last) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'png':
      case 'jpg':
      case 'jpeg':
        return Icons.image;
      default:
        return Icons.attach_file;
    }
  }
}
