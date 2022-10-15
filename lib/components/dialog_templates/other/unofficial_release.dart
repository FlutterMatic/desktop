// 🎯 Dart imports:
import 'dart:io';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/ui/round_container.dart';

class UnofficialReleaseDialog extends StatelessWidget {
  const UnofficialReleaseDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 400,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SvgPicture.asset(Assets.error),
              VSeparators.large(),
              const Text(
                'Unofficial Release',
                style: TextStyle(fontSize: 20),
              ),
              VSeparators.normal(),
              const Text(
                'This release of the app is not an official release. It wasn\'t built the right way. The app may be modified by an untrusted source.',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              VSeparators.normal(),
              RoundContainer(
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Text('Get the official release'),
                          VSeparators.xSmall(),
                          const Text(
                            'You can find the official release on GitHub or in your OS store if available.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    HSeparators.normal(),
                    RectangleButton(
                      width: 100,
                      child: const Text('GitHub'),
                      onPressed: () async {
                        await launchUrl(Uri.parse(
                            'https://github.com/FlutterMatic/desktop/releases'));
                        exit(0);
                      },
                    ),
                  ],
                ),
              ),
              VSeparators.normal(),
              RectangleButton(
                width: double.infinity,
                child: const Text('Close'),
                onPressed: () => exit(0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
