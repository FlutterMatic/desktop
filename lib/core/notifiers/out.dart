// 📦 Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 🌎 Project imports:
import 'package:fluttermatic/core/notifiers/models/state/actions/dart.dart';
import 'package:fluttermatic/core/notifiers/models/state/actions/flutter.dart';
import 'package:fluttermatic/core/notifiers/models/state/api/flutter_sdk.dart';
import 'package:fluttermatic/core/notifiers/models/state/api/fm_api.dart';
import 'package:fluttermatic/core/notifiers/models/state/api/vscode_api.dart';
import 'package:fluttermatic/core/notifiers/models/state/checks/adb.dart';
import 'package:fluttermatic/core/notifiers/models/state/checks/flutter.dart';
import 'package:fluttermatic/core/notifiers/models/state/checks/git.dart';
import 'package:fluttermatic/core/notifiers/models/state/checks/java.dart';
import 'package:fluttermatic/core/notifiers/models/state/checks/studio.dart';
import 'package:fluttermatic/core/notifiers/models/state/checks/vsc.dart';
import 'package:fluttermatic/core/notifiers/models/state/general/connection.dart';
import 'package:fluttermatic/core/notifiers/models/state/general/download.dart';
import 'package:fluttermatic/core/notifiers/models/state/general/notifications.dart';
import 'package:fluttermatic/core/notifiers/models/state/general/space.dart';
import 'package:fluttermatic/core/notifiers/models/state/general/theme.dart';
import 'package:fluttermatic/core/notifiers/notifiers/actions/dart.dart';
import 'package:fluttermatic/core/notifiers/notifiers/actions/flutter.dart';
import 'package:fluttermatic/core/notifiers/notifiers/api/flutter_sdk.dart';
import 'package:fluttermatic/core/notifiers/notifiers/api/fluttermatic.dart';
import 'package:fluttermatic/core/notifiers/notifiers/api/vscode.dart';
import 'package:fluttermatic/core/notifiers/notifiers/checks/adb.dart';
import 'package:fluttermatic/core/notifiers/notifiers/checks/flutter.dart';
import 'package:fluttermatic/core/notifiers/notifiers/checks/git.dart';
import 'package:fluttermatic/core/notifiers/notifiers/checks/java.dart';
import 'package:fluttermatic/core/notifiers/notifiers/checks/studio.dart';
import 'package:fluttermatic/core/notifiers/notifiers/checks/vsc.dart';
import 'package:fluttermatic/core/notifiers/notifiers/general/connection.dart';
import 'package:fluttermatic/core/notifiers/notifiers/general/download.dart';
import 'package:fluttermatic/core/notifiers/notifiers/general/file.dart';
import 'package:fluttermatic/core/notifiers/notifiers/general/notifications.dart';
import 'package:fluttermatic/core/notifiers/notifiers/general/space.dart';
import 'package:fluttermatic/core/notifiers/notifiers/general/theme.dart';

// API Notifiers
final StateNotifierProvider<FlutterSDKNotifier, FlutterSDKState>
    flutterSdkAPIStateNotifier =
    StateNotifierProvider((_) => FlutterSDKNotifier(_.read));

final StateNotifierProvider<FlutterMaticAPINotifier, FlutterMaticAPIState>
    fmAPIStateNotifier =
    StateNotifierProvider((_) => FlutterMaticAPINotifier(_.read));

final StateNotifierProvider<VSCodeAPINotifier, VSCodeAPIState>
    vsCodeAPIStateNotifier =
    StateNotifierProvider((_) => VSCodeAPINotifier(_.read));

// Checks Notifiers
final StateNotifierProvider<FlutterNotifier, FlutterState>
    flutterNotifierController =
    StateNotifierProvider((_) => FlutterNotifier(_.read));

final StateNotifierProvider<JavaNotifier, JavaState> javaNotifierController =
    StateNotifierProvider((_) => JavaNotifier(_.read));

final StateNotifierProvider<GitNotifier, GitState> gitNotifierController =
    StateNotifierProvider((_) => GitNotifier(_.read));

final StateNotifierProvider<ADBNotifier, ADBState> adbNotifierController =
    StateNotifierProvider((_) => ADBNotifier(_.read));

final StateNotifierProvider<AndroidStudioNotifier, AndroidStudioState>
    androidStudioNotifierController =
    StateNotifierProvider((_) => AndroidStudioNotifier(_.read));

final StateNotifierProvider<VSCodeNotifier, VSCState> vscNotifierController =
    StateNotifierProvider((_) => VSCodeNotifier(_.read));

// General Notifiers
final StateNotifierProvider<ConnectionNotifier, NetworkState>
    connectionNotifierController =
    StateNotifierProvider((_) => ConnectionNotifier(_.read));

final StateNotifierProvider<DownloadNotifier, DownloadState>
    downloadStateController =
    StateNotifierProvider((_) => DownloadNotifier(_.read));

final StateNotifierProvider<NotificationsNotifier, NotificationsState>
    notificationStateController =
    StateNotifierProvider((_) => NotificationsNotifier(_.read));

final StateNotifierProvider<FileNotifier, void> fileStateNotifier =
    StateNotifierProvider((_) => FileNotifier(_.read));

final StateNotifierProvider<SpaceNotifier, SpaceState> spaceStateController =
    StateNotifierProvider((_) => SpaceNotifier(_.read));

final StateNotifierProvider<ThemeNotifier, ThemeState> themeStateController =
    StateNotifierProvider((_) => ThemeNotifier(_.read));

// Actions Notifiers
final StateNotifierProvider<FlutterActionsNotifier, FlutterActionsState>
    flutterActionsStateNotifier =
    StateNotifierProvider((_) => FlutterActionsNotifier(_.read));

final StateNotifierProvider<DartActionsNotifier, DartActionsState>
    dartActionsStateNotifier =
    StateNotifierProvider((_) => DartActionsNotifier(_.read));
