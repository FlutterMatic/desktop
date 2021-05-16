import 'channel_controller.dart';
import 'filter_group.dart';
import 'result.dart';

Future<FileChooserResult> showOpenPanel({
  String? initialDirectory,
  List<FileTypeFilterGroup>? allowedFileTypes,
  bool? allowsMultipleSelection,
  bool? canSelectDirectories,
  String? confirmButtonText,
}) async {
  FileChooserConfigurationOptions options = FileChooserConfigurationOptions(
    initialDirectory: initialDirectory,
    allowedFileTypes: allowedFileTypes,
    allowsMultipleSelection: allowsMultipleSelection,
    canSelectDirectories: canSelectDirectories,
    confirmButtonText: confirmButtonText,
  );
  return FileChooserChannelController.instance
      .show(FileChooserType.open, options);
}

Future<FileChooserResult> showSavePanel(
    {String? initialDirectory,
    String? suggestedFileName,
    List<FileTypeFilterGroup>? allowedFileTypes,
    String? confirmButtonText}) async {
  FileChooserConfigurationOptions options = FileChooserConfigurationOptions(
    initialDirectory: initialDirectory,
    initialFileName: suggestedFileName,
    allowedFileTypes: allowedFileTypes,
    confirmButtonText: confirmButtonText,
  );
  return FileChooserChannelController.instance
      .show(FileChooserType.save, options);
}
