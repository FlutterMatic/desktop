class FileChooserResult {
  const FileChooserResult({this.paths, this.canceled});
  final bool? canceled;
  final List<String>? paths;
}
