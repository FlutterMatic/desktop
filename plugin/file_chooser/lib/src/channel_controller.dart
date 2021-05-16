import 'package:flutter/services.dart';
import 'filter_group.dart';
import 'result.dart';

const String _kChannelName = 'flutter/filechooser';
const String _kShowOpenPanelMethod = 'FileChooser.Show.Open';
const String _kShowSavePanelMethod = 'FileChooser.Show.Save';
const String _kInitialDirectoryKey = 'initialDirectory';
const String _kInitialFileNameKey = 'initialFileName';
const String _kAllowedFileTypesKey = 'allowedFileTypes';
const String _kConfirmButtonTextKey = 'confirmButtonText';
const String _kAllowsMultipleSelectionKey = 'allowsMultipleSelection';
const String _kCanChooseDirectoriesKey = 'canChooseDirectories';

enum FileChooserType { open, save }

class FileChooserConfigurationOptions {
  const FileChooserConfigurationOptions(
      {this.initialDirectory,
      this.initialFileName,
      this.allowedFileTypes,
      this.allowsMultipleSelection,
      this.canSelectDirectories,
      this.confirmButtonText});

  final String? initialDirectory;
  final String? initialFileName;
  final List<FileTypeFilterGroup>? allowedFileTypes;
  final bool? allowsMultipleSelection;
  final bool? canSelectDirectories; 
  final String? confirmButtonText; 

  Map<String, dynamic> asInvokeMethodArguments() {
    Map<String, dynamic> args = <String, dynamic>{};
    if (initialDirectory != null && initialDirectory!.isNotEmpty) {
      args[_kInitialDirectoryKey] = initialDirectory;
    }
    if (allowsMultipleSelection != null) {
      args[_kAllowsMultipleSelectionKey] = allowsMultipleSelection;
    }
    if (canSelectDirectories != null) {
      args[_kCanChooseDirectoriesKey] = canSelectDirectories;
    }
    if (allowedFileTypes != null && allowedFileTypes!.isNotEmpty) {
      args[_kAllowedFileTypesKey] = allowedFileTypes!
          .map((filter) => [filter.label ?? '', filter.fileExtensions ?? []])
          .toList();
    }
    if (confirmButtonText != null && confirmButtonText!.isNotEmpty) {
      args[_kConfirmButtonTextKey] = confirmButtonText;
    }
    if (confirmButtonText != null && confirmButtonText!.isNotEmpty) {
      args[_kConfirmButtonTextKey] = confirmButtonText;
    }
    if (initialFileName != null && initialFileName!.isNotEmpty) {
      args[_kInitialFileNameKey] = initialFileName;
    }
    return args;
  }
}

class FileChooserChannelController {
  FileChooserChannelController._();
  final _channel = const MethodChannel(_kChannelName);
  static final FileChooserChannelController instance =
      FileChooserChannelController._();
  Future<FileChooserResult> show(
    FileChooserType type,
    FileChooserConfigurationOptions options,
  ) async {
    String methodName = type == FileChooserType.open
        ? _kShowOpenPanelMethod
        : _kShowSavePanelMethod;
    List<String>? paths = await _channel.invokeListMethod<String>(
        methodName, options.asInvokeMethodArguments());
    return FileChooserResult(paths: paths ?? [], canceled: paths == null);
  }
}
