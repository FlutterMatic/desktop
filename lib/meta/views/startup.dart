import 'dart:async';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:manager/app/constants/constants.dart';
import 'package:manager/app/constants/enum.dart';
import 'package:manager/core/libraries/api.dart';
import 'package:manager/core/libraries/checks.dart';
import 'package:manager/core/libraries/notifiers.dart';
import 'package:manager/meta/views/home.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class Startup extends StatefulWidget {
  final ThemeChangeNotifier themeChangeNotifier;
  Startup(
    this.themeChangeNotifier, {
    Key? key,
  }) : super(key: key);

  @override
  _StartupState createState() => _StartupState();
}

class _StartupState extends State<Startup> with WidgetsBindingObserver {
  late bool reverse;
  int easterEggThemeCount = 0;

  Future<void> exponentialBackoff(Function callback,
      [int failDuration = 5]) async {
    try {
      await callback();
    } catch (e) {
      await exponentialBackoff(callback);
    }
  }

  Future<void> initCalls() async {
    await exponentialBackoff(() async {
      await context.read<FlutterMaticAPINotifier>().fetchAPIData();
    });
    apiData = context.read<FlutterMaticAPINotifier>().apiMap!;
    reverse = context.read<ThemeChangeNotifier>().isDarkTheme;
    await context.read<FlutterSDKNotifier>().fetchSDKData(apiData);
    sdkData = context.read<FlutterSDKNotifier>().sdkMap!;
    await context.read<VSCodeAPINotifier>().fetchAPIData();
    tag_name = context.read<VSCodeAPINotifier>().tag_name!;
    sha = context.read<VSCodeAPINotifier>().sha!;
    await context
        .read<MainChecksNotifier>()
        .startChecking(context, apiData, sdk: sdkData);
  }

  @override
  void initState() {
    Provider.of<ConnectionNotifier>(context, listen: false).startMonitoring();
    initCalls();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String? get _text {
    {
      switch (context.watch<MainChecksNotifier>().value) {
        case ApplicationCheckType.FLUTTER_CHECK:
          return context.watch<FlutterChangeNotifier>().value;
        case ApplicationCheckType.JAVA_CHECK:
          return context.watch<JavaChangeNotifier>().value;
        case ApplicationCheckType.GIT_CHECK:
          return context.watch<GitChangeNotifier>().value;
        case ApplicationCheckType.ADB_CHECK:
          return context.watch<ADBChangeNotifier>().value;
        case ApplicationCheckType.ANDROID_STUDIO_CHECK:
          return context.watch<AndroidStudioChangeNotifier>().value;
        case ApplicationCheckType.VSC_CHECK:
          return context.watch<VSCodeChangeNotifier>().value;
        default:
      }
    }
  }

  String? get _asset {
    {
      switch (context.watch<MainChecksNotifier>().value) {
        case ApplicationCheckType.FLUTTER_CHECK:
          return 'assets/images/icons/flutter.png';
        case ApplicationCheckType.JAVA_CHECK:
          return 'assets/images/icons/java.png';
        case ApplicationCheckType.GIT_CHECK:
          return 'assets/images/icons/git.png';
        case ApplicationCheckType.ADB_CHECK:
          return 'assets/images/icons/adb.png';
        case ApplicationCheckType.ANDROID_STUDIO_CHECK:
          return 'assets/images/icons/studio.png';
        case ApplicationCheckType.VSC_CHECK:
          return 'assets/images/icons/vscode.png';
        default:
      }
    }
  }

  Future<void> _onPointerDown(PointerDownEvent event) async {
    // Check if right mouse button clicked
    if (event.kind == PointerDeviceKind.mouse &&
        event.buttons == kSecondaryMouseButton) {
      RenderBox? overlay =
          Overlay.of(context)!.context.findRenderObject() as RenderBox?;
      int? menuItem = await showMenu<int>(
        context: context,
        items: <PopupMenuEntry<int>>[
          const PopupMenuItem<int>(
              value: 1, height: 25, child: Text('minimize')),
          const PopupMenuItem<int>(
              value: 2, height: 25, child: Text('Report issue')),
          const PopupMenuItem<int>(
              value: 3, height: 25, child: Text('About App')),
        ],
        position: RelativeRect.fromSize(
            event.position & const Size(10.0, 58.0), overlay!.size),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(7.0),
          ),
        ),
      );
      // Check if menu item clicked
      switch (menuItem) {
        case 1:
          appWindow.maximizeOrRestore();
          break;
        case 2:
          await _launchURL();
          break;
        case 3:
          showAboutDialog(context: context);
          break;
        default:
      }
    }
  }

  Future<void> _launchURL() async => await canLaunch(reportIssueUrl)
      ? await launch(reportIssueUrl)
      : throw 'Could not launch $reportIssueUrl';
  @override
  Widget build(BuildContext context) {
    return context.watch<MainChecksNotifier>().value ==
            ApplicationCheckType.DONE
        ? const HomeScreen()
        : Listener(
            onPointerDown: _onPointerDown,
            child: Scaffold(
              body: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onPanStart: (DragStartDetails details) {
                  appWindow.startDragging();
                },
                child: Center(
                  child: Stack(
                    children: <Widget>[
                      Consumer<ConnectionNotifier>(builder:
                          (BuildContext context, ConnectionNotifier connection,
                              Widget? _) {
                        return !connection.isOnline
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Image.asset(
                                    'assets/images/no_internet.png',
                                    height: 100,
                                  ),
                                  const SizedBox(
                                    height: 30,
                                  ),
                                  const SelectableText(
                                    'Sorry, No internet',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10.0,
                                      vertical: 8.0,
                                    ),
                                    child: SelectableText(
                                      'You haven\'t connected to internet it seems. Please do check your connection and come back. Mean while we will check the system.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Image.asset(
                                    _asset!,
                                    height: 100,
                                  ),
                                  const SizedBox(
                                    height: 30,
                                  ),
                                  Container(
                                    width: double.infinity,
                                    child: Center(
                                      child: SelectableText(
                                        _text!,
                                        style: const TextStyle(
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w300,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Consumer<DownloadNotifier>(
                                    builder: (BuildContext context,
                                        DownloadNotifier downloadNotifier, _) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 15.0,
                                          horizontal: 100.0,
                                        ),
                                        child: downloadNotifier.progress == null
                                            ? const SizedBox.shrink()
                                            : ClipRRect(
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(10)),
                                                child: LinearProgressIndicator(
                                                  value: downloadNotifier
                                                          .progress! /
                                                      100,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                              Color>(
                                                          downloadNotifier
                                                              .progressColor),
                                                  backgroundColor:
                                                      downloadNotifier
                                                          .progressColor
                                                          .withOpacity(0.2),
                                                  minHeight: 5,
                                                ),
                                              ),
                                      );
                                    },
                                  ),
                                ],
                              );
                      }),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: IconButton(
                          onPressed: () => appWindow.minimize(),
                          splashColor: Colors.transparent,
                          splashRadius: 0.01,
                          focusColor: Colors.grey,
                          hoverColor: Colors.grey,
                          highlightColor: Colors.grey,
                          color: Colors.black,
                          icon: const Icon(
                            Icons.remove_rounded,
                            size: 15,
                          ),
                        ),
                      ),
                      const Positioned(
                        bottom: 10,
                        right: 0,
                        left: 0,
                        child: Center(
                          child: SelectableText(
                            'Made with 💙',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
