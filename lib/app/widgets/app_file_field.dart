import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';
import 'package:uuid/uuid.dart';

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
  final Future<void> Function(String) onRemove;
  final Future<void> Function(String) openFile;
  final List<String> attachments;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final appLoader = AppLoader(context);

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
                        onTap: () async {
                          unawaited(
                            appLoader.showLoading(),
                          );
                          await openFile(attachments[i]);
                          if (appLoader.isLoading) {
                            appLoader.hideLoading();
                          }
                        },
                        child: Chip(
                          label: Text(
                            getAttachmentName(attachments[i], i + 1, l10n),
                          ),
                          avatar: HugeIcon(
                            icon: getAttachmentIcon(attachments[i]),
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          onDeleted: () => _showRemoveConfirmationDialog(
                            context,
                            attachments[i],
                            l10n,
                          ),
                        ),
                      ),
                    ),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () => _handleUpload(context, appLoader),
                      icon: const HugeIcon(
                        icon: HugeIcons.strokeRoundedUpload04,
                      ),
                      label: Text(labelAdd),
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

  List<List<dynamic>> getAttachmentIcon(String path) {
    switch (path.split('.').last) {
      case 'pdf':
        return HugeIcons.strokeRoundedPdf01;
      case 'png':
      case 'jpg':
      case 'jpeg':
        return HugeIcons.strokeRoundedImage01;
      default:
        return HugeIcons.strokeRoundedAttachment;
    }
  }

  void _showRemoveConfirmationDialog(
    BuildContext context,
    String attachment,
    AppLocalizations l10n,
  ) {
    unawaited(
      showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(l10n.confirmRemoveAttachmentTitle),
            content: Text(l10n.confirmRemoveAttachmentMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(l10n.removeAttachmentCancel),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(l10n.removeAttachmentConfirm),
              ),
            ],
          );
        },
      ).then((shouldRemove) {
        if (shouldRemove ?? false) {
          unawaited(onRemove(attachment));
        }
      }),
    );
  }

  Future<void> _handleUpload(BuildContext context, AppLoader appLoader) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: AppVariables.allowedExtensions,
      );

      if (result != null) {
        unawaited(appLoader.showLoading());
        final file = result.files.single;
        final ext = file.path!.split('.').last;
        final path = '${const Uuid().v4()}.$ext';
        final name = await getIt<StorageService>().uploadFile(
          File(file.path!),
          path,
        );

        if (appLoader.isLoading) {
          appLoader.hideLoading();
        }
        onAdd(name);
      }
    } on Exception catch (e) {
      if (appLoader.isLoading) {
        appLoader.hideLoading();
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              behavior: SnackBarBehavior.floating,
            ),
          );
      }
    }
  }
}
