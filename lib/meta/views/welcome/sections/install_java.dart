import 'package:flutter/material.dart';
import 'package:manager/app/constants/constants.dart';
import 'package:manager/components/dialog_templates/dialog_header.dart';
import 'package:manager/components/widgets/buttons/rectangle_button.dart';
import 'package:manager/components/widgets/ui/bullet_point.dart';
import 'package:manager/components/widgets/ui/dialog_template.dart';
import 'package:manager/components/widgets/ui/info_widget.dart';
import 'package:manager/components/widgets/ui/warning_widget.dart';
import 'package:manager/core/libraries/notifiers.dart';
import 'package:manager/meta/utils/app_theme.dart';
import 'package:manager/meta/views/welcome/components/button.dart';
import 'package:provider/provider.dart';
import 'package:manager/meta/views/welcome/components/header_title.dart';
import 'package:manager/meta/views/welcome/components/progress_indicator.dart';

Widget installJava(
  BuildContext context,
  VoidCallback? onInstall,
  VoidCallback? onSkip, {
  required bool isInstalling,
  required bool doneInstalling,
}) {
  return Column(
    children: <Widget>[
      welcomeHeaderTitle(
        Assets.java,
        Install.java,
        InstallContent.java,
        iconHeight: 40,
      ),
      const SizedBox(height: 50),
      if (!doneInstalling)
        installProgressIndicator(
          disabled: !isInstalling,
          objectSize: '3.2 GB',
        )
      else
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: context.read<ThemeChangeNotifier>().isDarkTheme
                ? const Color(0xff1B2529)
                : const Color(0xffF4F8FA),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(Icons.check_rounded, color: Color(0xff40CAFF)),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(Installed.java, style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    const Text(InstalledContent.java,
                        style: TextStyle(fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        ),
      const SizedBox(height: 50),
      WelcomeButton(
          doneInstalling ? ButtonTexts.next : ButtonTexts.install, onInstall,
          disabled: isInstalling),
      const SizedBox(height: 20),
      if (!doneInstalling && !isInstalling)
        TextButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => DialogTemplate(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const DialogHeader(title: 'Are you sure?'),
                    const SizedBox(height: 10),
                    warningWidget(
                      'We recommend that you installed Java. This will help eliminate some issues you might face in the future with Flutter.',
                      Assets.warn,
                      kYellowColor,
                    ),
                    const SizedBox(height: 5),
                    infoWidget(
                        'You will still be able to install Java later if you change your mind.'),
                    const SizedBox(height: 20),
                    const Text('Tool Skipping:'),
                    const SizedBox(height: 15),
                    BulletPoint('Java 8 by Oracle', 2),
                    const SizedBox(height: 20),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: RectangleButton(
                            hoverColor: AppTheme.errorColor,
                            child: const Text('Skip',
                                style: TextStyle(color: Colors.white)),
                            onPressed: () {
                              Navigator.pop(context);
                              onSkip!();
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: RectangleButton(
                            child: const Text('Cancel',
                                style: TextStyle(color: Colors.white)),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              ButtonTexts.skip,
              style: TextStyle(fontSize: 12),
            ),
          ),
        ),
    ],
  );
}
