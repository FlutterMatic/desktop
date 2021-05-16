import 'package:flutter/material.dart';
import 'package:flutter_installer/components/dialog_templates/dialog_header.dart';
import 'package:flutter_installer/components/dialog_templates/flutter/change_channel.dart';
import 'package:flutter_installer/components/dialog_templates/flutter/flutter_upgrade.dart';
import 'package:flutter_installer/components/dialog_templates/flutter/install_flutter.dart';
import 'package:flutter_installer/components/dialog_templates/other/select_emulator.dart';
import 'package:flutter_installer/components/widgets/dialog_template.dart';
import 'package:flutter_installer/components/widgets/rectangle_button.dart';
import 'package:flutter_installer/components/widgets/round_container.dart';
import 'package:flutter_installer/components/widgets/square_button.dart';
import 'package:flutter_installer/components/widgets/title_section.dart';
import 'package:flutter_installer/services/themes.dart';
import 'package:flutter_installer/utils/constants.dart';
import 'package:process_run/shell.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

Shell _shell = Shell(
  verbose: false,
  commandVerbose: false,
  commentVerbose: false,
  runInShell: true,
);

class Controls extends StatefulWidget {
  @override
  _ControlsState createState() => _ControlsState();
}

class _ControlsState extends State<Controls> {
  @override
  Widget build(BuildContext context) {
    ThemeData customTheme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        titleSection('Controls', context),
        const SizedBox(height: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Software Development Kits',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Row(
              children: <Widget>[
                //Flutter
                Expanded(
                  child: ControlResourceTile(
                    flutterInstalled
                        ? 'Flutter ${flutterChannel![0].toUpperCase() + flutterChannel!.substring(1)}'
                        : 'Install Flutter',
                    flutterVersion,
                    [
                      // Change Flutter Channel
                      if (flutterInstalled)
                        Expanded(
                          child: RectangleButton(
                            color: currentTheme.isDarkTheme
                                ? null
                                : Colors.grey.withOpacity(0.4),
                            radius: BorderRadius.circular(5),
                            onPressed: () => showDialog(
                              context: context,
                              builder: (context) => ChangeChannelDialog(),
                            ),
                            child: _controlButton(
                                'Channel',
                                Icon(Iconsdata.changeChannel,
                                    color:
                                        customTheme.textTheme.bodyText1!.color,
                                    size: 20),
                                context),
                          ),
                        ),
                      const SizedBox(width: 8),
                      // Upgrade Flutter
                      Expanded(
                        child: RectangleButton(
                          color: currentTheme.isDarkTheme
                              ? null
                              : Colors.grey.withOpacity(0.4),
                          onPressed: () => showDialog(
                            context: context,
                            builder: (_) => flutterInstalled
                                ? UpgradeFlutterDialog()
                                : InstallFlutterDialog(),
                          ),
                          child: _controlButton(
                            'Upgrade',
                            Icon(Iconsdata.rocket,
                                color: customTheme.textTheme.bodyText1!.color,
                                size: 20),
                            context,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                //Java
                Expanded(
                  child: ControlResourceTile(
                    javaInstalled ? 'Java' : 'Install Java',
                    javaVersion,
                    [
                      // Download Java
                      if (!javaInstalled)
                        Expanded(
                          child: RectangleButton(
                            color: currentTheme.isDarkTheme
                                ? null
                                : Colors.grey.withOpacity(0.4),
                            onPressed: () {},
                            child: _controlButton(
                                'Install',
                                Icon(Iconsdata.download,
                                    color:
                                        customTheme.textTheme.bodyText1!.color,
                                    size: 20),
                                context),
                          ),
                        ),
                      // Open Java Docs
                      if (javaInstalled)
                        Expanded(
                          child: RectangleButton(
                            color: currentTheme.isDarkTheme
                                ? null
                                : Colors.grey.withOpacity(0.4),
                            onPressed: () =>
                                launch('https://docs.oracle.com/en/java/'),
                            child: _controlButton(
                              'Learn more',
                              Icon(Icons.book_rounded,
                                  color: customTheme.textTheme.bodyText1!.color,
                                  size: 20),
                              context,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'IDE Tools',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Row(
              children: <Widget>[
                //VSCode
                Expanded(
                  child: ControlResourceTile(
                    vscInstalled ? 'Visual Studio Code' : 'Install VSCode',
                    vscodeVersion,
                    [
                      // Download VS Code
                      if (!vscInstalled)
                        Expanded(
                          child: RectangleButton(
                            color: currentTheme.isDarkTheme
                                ? null
                                : Colors.grey.withOpacity(0.4),
                            onPressed: () => launch(
                                'https://code.visualstudio.com/Download'),
                            child: _controlButton(
                                'Download',
                                Icon(Iconsdata.download,
                                    color:
                                        customTheme.textTheme.bodyText1!.color,
                                    size: 20),
                                context),
                          ),
                        ),
                      // Open VS Code
                      if (vscInstalled)
                        Expanded(
                          child: RectangleButton(
                            color: currentTheme.isDarkTheme
                                ? null
                                : Colors.grey.withOpacity(0.4),
                            onPressed: () {
                              Shell _shell = Shell(verbose: false);
                              _shell.run('code .');
                            },
                            child: _controlButton(
                                'Open',
                                Icon(Icons.code,
                                    color:
                                        customTheme.textTheme.bodyText1!.color,
                                    size: 20),
                                context),
                          ),
                        ),
                      const SizedBox(width: 8),
                      // VS Code Docs
                      SquareButton(
                        color: currentTheme.isDarkTheme
                            ? null
                            : Colors.grey.withOpacity(0.4),
                        icon: Icon(
                          Icons.book_rounded,
                          color: customTheme.textTheme.bodyText1!.color,
                        ),
                        onPressed: () =>
                            launch('https://code.visualstudio.com/docs'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                //Android Studio
                Expanded(
                  child: ControlResourceTile(
                    studioInstalled
                        ? 'Android Studio'
                        : 'Install Android Studio',
                    androidSVersion,
                    [
                      // Open Emulator
                      if (emulatorInstalled)
                        Expanded(
                          child: RectangleButton(
                            color: currentTheme.isDarkTheme
                                ? null
                                : Colors.grey.withOpacity(0.4),
                            onPressed: () async {
                              SharedPreferences _pref =
                                  await SharedPreferences.getInstance();
                              List<ProcessResult> avdList = await _shell.run(
                                  '${_pref.getString('emulator_path')!} -list-avds');
                              if (avdList.length < 2) {
                                await _shell.run(
                                    '${_pref.getString('emulator_path')!} -avd ${avdList[0].stdout}');
                              } else if (avdList.length > 1) {
                                await showDialog(
                                    context: context,
                                    builder: (_) => SelectEmulatorDialog());
                              } else {
                                await showDialog(
                                  context: context,
                                  builder: (_) => DialogTemplate(
                                    child: Column(
                                      children: [
                                        DialogHeader(
                                            title: 'Couldn\'t Open Emulator'),
                                        const SizedBox(height: 20),
                                        const Text(
                                          'For some reason, we couldn\'t open your emulators. Please try again. If you continue to get this error, please report an issue,',
                                        ),
                                        const SizedBox(height: 20),
                                      ],
                                    ),
                                  ),
                                );
                              }
                            },
                            child: _controlButton(
                                'Emulator',
                                Icon(Icons.phone_android,
                                    color:
                                        customTheme.textTheme.bodyText1!.color,
                                    size: 20),
                                context),
                          ),
                        ),
                      if ((!studioInstalled || studioInstalled) &&
                          emulatorInstalled)
                        const SizedBox(width: 8),
                      // Install Android Studio
                      if (!studioInstalled)
                        Expanded(
                          child: RectangleButton(
                            color: currentTheme.isDarkTheme
                                ? null
                                : Colors.grey.withOpacity(0.4),
                            onPressed: () =>
                                launch('https://developer.android.com/studio/'),
                            child: _controlButton(
                                'Download',
                                Icon(Iconsdata.download,
                                    color:
                                        customTheme.textTheme.bodyText1!.color,
                                    size: 20),
                                context),
                          ),
                        ),
                      if (studioInstalled &&
                          !emulatorInstalled &&
                          !studioInstalled)
                        const SizedBox(width: 8),
                      // Download Emulator
                      if (studioInstalled && !emulatorInstalled)
                        Expanded(
                          child: RectangleButton(
                            color: currentTheme.isDarkTheme
                                ? null
                                : Colors.grey.withOpacity(0.4),
                            onPressed: () {},
                            child: _controlButton(
                                'Emulator',
                                Icon(Iconsdata.download,
                                    color:
                                        customTheme.textTheme.bodyText1!.color,
                                    size: 20),
                                context),
                          ),
                        ),
                      if (studioInstalled &&
                          studioInstalled &&
                          !emulatorInstalled)
                        const SizedBox(width: 8),
                      // Open Android Studio
                      if (studioInstalled)
                        Expanded(
                          child: RectangleButton(
                            color: currentTheme.isDarkTheme
                                ? null
                                : Colors.grey.withOpacity(0.4),
                            onPressed: () => launch('studio64'),
                            child: _controlButton(
                                'Open',
                                Icon(Icons.code,
                                    color:
                                        customTheme.textTheme.bodyText1!.color,
                                    size: 20),
                                context),
                          ),
                        ),
                    ],
                  ),
                ),
                if (Platform.isMacOS) const SizedBox(width: 15),
                //XCode
                if (Platform.isMacOS)
                  Expanded(
                    child: ControlResourceTile(
                      xCodeInstalled ? 'Xcode' : 'Install Xcode',
                      xcodeVersion,
                      [
                        Expanded(
                          child: RectangleButton(
                            color: currentTheme.isDarkTheme
                                ? null
                                : Colors.grey.withOpacity(0.4),
                            onPressed: () {},
                            child: _controlButton('Open', null, context),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class ControlResourceTile extends StatelessWidget {
  final String header;
  final String? version;
  final List<Widget>? actions;

  ControlResourceTile(this.header, this.version, this.actions);

  @override
  Widget build(BuildContext context) {
    ThemeData customTheme = Theme.of(context);
    return RoundContainer(
      radius: 5,
      color: currentTheme.isDarkTheme
          ? customTheme.primaryColorLight
          : Colors.grey.withOpacity(0.3),
      height: 160,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            header,
            softWrap: true,
            textAlign: TextAlign.center,
            overflow: TextOverflow.fade,
            style: TextStyle(
                color: customTheme.textTheme.bodyText1!.color, fontSize: 15),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                version != null ? ('v' + version!) : 'Unknown Version',
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
              ),
            ),
          ),
          Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: actions!),
        ],
      ),
    );
  }
}

Widget _controlButton(String title, Widget? icon, BuildContext context) {
  ThemeData customTheme = Theme.of(context);
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
      Text(
        title,
        softWrap: false,
        overflow: TextOverflow.fade,
        style: TextStyle(
            fontSize: 15, color: customTheme.textTheme.bodyText1!.color),
      ),
      if (icon != null) const SizedBox(width: 10),
      if (icon != null) icon
    ],
  );
}
