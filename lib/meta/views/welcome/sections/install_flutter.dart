import 'package:flutter/material.dart';
import 'package:manager/app/constants/constants.dart';
import 'package:manager/app/constants/enum.dart';
import 'package:manager/components/widgets/ui/round_container.dart';
import 'package:manager/meta/views/welcome/components/button.dart';
import 'package:manager/meta/views/welcome/components/header_title.dart';
import 'package:manager/meta/views/welcome/components/progress_indicator.dart';

Widget installFlutter(
  Function() onInstall, {
  required Function() onCancel,
  // required bool doneInstalling,
  // required bool isInstalling,
  required PROGRESS progress,
}) {
  return Column(
    children: <Widget>[
      welcomeHeaderTitle(
        Assets.flutter,
        'Install Flutter',
        'You will need to install Flutter in your machine to start using Flutter.',
      ),
      const SizedBox(height: 50),
      // TODO(@ZiyadF296) : Don't use opacity, instead shrink the space and when
      // user click install show them the checks happening and if the flutter sdk
      // not found then show the download progress.
      progress == PROGRESS.DOWNLOADING
          ? installProgressIndicator(
              objectSize: '1.8 GB',
              disabled: (progress != PROGRESS.CHECKING &&
                  progress != PROGRESS.DOWNLOADING &&
                  progress != PROGRESS.STARTED),
            )
          : RoundContainer(
              padding: const EdgeInsets.all(15),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(Icons.check_rounded, color: Color(0xff40CAFF)),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text(
                          'Flutter Installed',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Flutter was installed successfully on your machine. Continue to the next step.',
                          style: TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      const SizedBox(height: 50),
      WelcomeButton(
        progress == PROGRESS.DONE
            ? 'Next'
            : (progress != PROGRESS.DONE)
                ? 'Cancel'
                : 'Install',
        (progress != PROGRESS.DOWNLOADING &&
                progress != PROGRESS.EXTRACTING &&
                progress != PROGRESS.STARTED)
            ? onInstall
            : (progress != PROGRESS.DONE)
                ? onCancel
                : null,
        disabled: (progress != PROGRESS.CHECKING &&
            progress != PROGRESS.DOWNLOADING &&
            progress != PROGRESS.STARTED),
      ),
    ],
  );
}
