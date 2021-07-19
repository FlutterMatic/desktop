import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:manager/app/constants/constants.dart';
import 'package:manager/app/constants/enum.dart';
import 'package:manager/core/libraries/api.dart';
import 'package:manager/core/libraries/checks.dart';
import 'package:manager/core/libraries/notifiers.dart';
import 'package:provider/provider.dart';

class Startup extends StatefulWidget {
  final ThemeChangeNotifier themeChangeNotifier;
  Startup(
    this.themeChangeNotifier, {
    Key? key,
  }) : super(key: key);

  @override
  _StartupState createState() => _StartupState();
}

class _StartupState extends State<Startup> {
  late bool reverse;
  int easterEggThemeCount = 0;
  Future<void> initCalls() async {
    reverse = context.read<ThemeChangeNotifier>().isDarkTheme;
    await context.read<FlutterMaticAPINotifier>().fetchAPIData();
    apiData = context.read<FlutterMaticAPINotifier>().apiMap!;
    await context.read<FlutterSDKNotifier>().fetchSDKData(apiData);
    sdkData = context.read<FlutterSDKNotifier>().sdkMap!;
    await context
        .read<MainChecksNotifier>()
        .startChecking(context, apiData, sdk: sdkData);
  }

  @override
  void initState() {
    initCalls();
    super.initState();
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
          return null;
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
          const PopupMenuItem<int>(value: 1, child: Text('open')),
          const PopupMenuItem<int>(value: 2, child: Text('close')),
        ],
        position: RelativeRect.fromSize(
            event.position & const Size(48.0, 48.0), overlay!.size),
      );
      // Check if menu item clicked
      switch (menuItem) {
        case 1:
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Copy clicked'),
            behavior: SnackBarBehavior.floating,
          ));
          break;
        case 2:
          appWindow.minimize();
          break;
        default:
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
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
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CircularProgressIndicator(
                      color: widget.themeChangeNotifier.isDarkTheme
                          ? Colors.lightBlueAccent.withOpacity(0.6)
                          : Colors.lightBlueAccent,
                      strokeWidth: 3,
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
                          child: downloadNotifier.progress == null ||
                                  downloadNotifier.progress == 0
                              ? const SizedBox.shrink()
                              : ClipRRect(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10)),
                                  child: LinearProgressIndicator(
                                    value: downloadNotifier.progress! / 100,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        downloadNotifier.progressColor),
                                    backgroundColor: downloadNotifier
                                        .progressColor
                                        .withOpacity(0.2),
                                    minHeight: 3,
                                  ),
                                ),
                        );
                      },
                    ),
                  ],
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
