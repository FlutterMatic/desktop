import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:manager/app/constants/constants.dart';
import 'package:manager/app/constants/enum.dart';
import 'package:manager/core/libraries/api.dart';
import 'package:manager/core/libraries/checks.dart';
import 'package:manager/core/libraries/notifiers.dart';
import 'package:manager/meta/views/home.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

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

  Future<void> _exponentialBackOff(Function callback,
      [bool haveBackOff = false]) async {
    try {
      if (haveBackOff) {
        await Future<void>.delayed(const Duration(seconds: 5));
      }
      await callback();
    } catch (_) {
      await _exponentialBackOff(callback, true);
    }
  }

  Future<void> _initCalls() async {
    await _exponentialBackOff(() async {
      await context.read<FlutterMaticAPINotifier>().fetchAPIData();
    });
    apiData = context.read<FlutterMaticAPINotifier>().apiMap!;
    reverse = context.read<ThemeChangeNotifier>().isDarkTheme;
    await context.read<FlutterSDKNotifier>().fetchSDKData(apiData);
    sdkData = context.read<FlutterSDKNotifier>().sdkMap!;
    await context.read<VSCodeAPINotifier>().fetchVSCAPIData();
    tagName = context.read<VSCodeAPINotifier>().tag_name!;
    sha = context.read<VSCodeAPINotifier>().sha!;
    await context
        .read<MainChecksNotifier>()
        .startChecking(context, apiData, sdk: sdkData);
  }

  @override
  void initState() {
    Provider.of<ConnectionNotifier>(context, listen: false).startMonitoring();
    _initCalls();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String? get _asset {
    {
      switch (context.watch<MainChecksNotifier>().value) {
        case ApplicationCheckType.FLUTTER_CHECK:
          return 'assets/images/logos/flutter.svg';
        case ApplicationCheckType.JAVA_CHECK:
          return 'assets/images/logos/java.svg';
        case ApplicationCheckType.GIT_CHECK:
          return 'assets/images/logos/git.svg';
        case ApplicationCheckType.ADB_CHECK:
          return 'assets/images/logos/adb.svg';
        case ApplicationCheckType.ANDROID_STUDIO_CHECK:
          return 'assets/images/logos/android_studio.svg';
        case ApplicationCheckType.VSC_CHECK:
          return 'assets/images/logos/vs_code.svg';
        default:
      }
    }
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

  Future<void> _onPointerDown(PointerDownEvent event) async {
    // Check if right mouse button clicked
    if (event.kind == PointerDeviceKind.mouse &&
        event.buttons == kSecondaryMouseButton) {
      RenderBox? overlay =
          Overlay.of(context)!.context.findRenderObject() as RenderBox?;
      int? menuItem = await showMenu<int>(
        context: context,
        items: <PopupMenuEntry<int>>[
          PopupMenuItem<int>(
              value: 1,
              height: 25,
              child: Text(appWindow.isMaximized ? 'Minimize' : 'Maximize')),
          const PopupMenuItem<int>(
              value: 2, height: 25, child: Text('Report Issue')),
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
          await _launchReportIssue();
          break;
        case 3:
          showAboutDialog(context: context);
          break;
        default:
      }
    }
  }

  Future<void> _launchReportIssue() async => await canLaunch(reportIssueUrl)
      ? await launch(reportIssueUrl)
      : throw 'Could not launch $reportIssueUrl';

  @override
  Widget build(BuildContext context) {
    if (context.watch<MainChecksNotifier>().value ==
        ApplicationCheckType.DONE) {
      return const HomeScreen();
    } else {
      return Listener(
        onPointerDown: _onPointerDown,
        child: Scaffold(
          body: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onPanStart: (DragStartDetails details) => appWindow.startDragging(),
            child: Center(
              child: Stack(
                children: <Widget>[
                  Consumer<ConnectionNotifier>(builder: (BuildContext context,
                      ConnectionNotifier connection, Widget? _) {
                    if (!connection.isOnline) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const SelectableText(
                            'Uh Oh. Couldn\'t find an internet connection. To continue setting up Flutter, you will need to have an internet connection.',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 24,
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
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SvgPicture.asset(_asset!, height: 100),
                          const SizedBox(
                            height: 30,
                          ),
                          Container(
                            width: double.infinity,
                            child: Center(
                              child: SelectableText(
                                _text!,
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                          ),
                          Consumer<DownloadNotifier>(
                            builder: (BuildContext context,
                                DownloadNotifier downloadNotifier, _) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 15.0, horizontal: 100.0),
                                child: downloadNotifier.progress == null
                                    ? const SizedBox.shrink()
                                    : ClipRRect(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(10)),
                                        child: LinearProgressIndicator(
                                          value:
                                              downloadNotifier.progress! / 100,
                                          valueColor: AlwaysStoppedAnimation<
                                                  Color>(
                                              downloadNotifier.progressColor),
                                          backgroundColor: downloadNotifier
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
                    }
                  }),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Tooltip(
                      message: 'Minimize',
                      child: IconButton(
                        onPressed: () => appWindow.minimize(),
                        splashColor: Colors.transparent,
                        splashRadius: 10,
                        focusColor: Colors.grey[400],
                        hoverColor: Colors.grey[400],
                        highlightColor: Colors.grey,
                        color: Colors.black,
                        icon: const Icon(Icons.remove_rounded, size: 15),
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
}
