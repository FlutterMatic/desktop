class FileState {
  final bool checkDir;
  final bool fileExists;
  final String? searchFile;
  final bool setPath;
  final bool unzip;

  const FileState({
    this.checkDir = false, 
    this.fileExists = false, 
    this.searchFile, 
    this.setPath = false, 
    this.unzip =false,
  });

  factory FileState.initial() => const FileState();

  FileState copyWith({
    bool? checkDir, 
    bool? fileExists, 
    String? searchFile, 
    bool? setPath, 
    bool? unzip,
  }) {
    return FileState(
      checkDir: checkDir ?? this.checkDir,
      fileExists: fileExists ?? this.fileExists,
      searchFile: searchFile ?? this.searchFile,
      setPath: setPath ?? this.setPath,
      unzip: unzip ?? this.unzip,
    );
  }
}