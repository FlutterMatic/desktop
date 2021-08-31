import 'package:pub_semver/pub_semver.dart';


/// [AppData] global object.
AppData appData = AppData();

/// [AppData] class which holds the app version, app name, app release type, build type,
class AppData {
  Version? version;
  String? releaseType;
  String? buildMode;
  String? platform;
}