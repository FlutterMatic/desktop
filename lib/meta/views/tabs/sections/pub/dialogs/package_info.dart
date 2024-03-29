// 🎯 Dart imports:
import 'dart:isolate';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 📦 Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pub_api_client/pub_api_client.dart';
import 'package:url_launcher/url_launcher.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants.dart';
import 'package:fluttermatic/components/dialog_templates/dialog_header.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/ui/dialog_template.dart';
import 'package:fluttermatic/components/widgets/ui/information_widget.dart';
import 'package:fluttermatic/components/widgets/ui/round_container.dart';
import 'package:fluttermatic/components/widgets/ui/snackbar_tile.dart';
import 'package:fluttermatic/components/widgets/ui/stage_tile.dart';
import 'package:fluttermatic/core/notifiers/models/state/general/theme.dart';
import 'package:fluttermatic/core/notifiers/out.dart';
import 'package:fluttermatic/core/services/logs.dart';
import 'package:fluttermatic/meta/views/tabs/sections/pub/models/pkg_data.dart';

class PubPackageDialog extends StatefulWidget {
  final PkgViewData pkgInfo;

  const PubPackageDialog({Key? key, required this.pkgInfo}) : super(key: key);

  @override
  State<PubPackageDialog> createState() => _PubPackageDialogState();
}

class _PubPackageDialogState extends State<PubPackageDialog> {
  // Pub Client
  final PubClient _pubClient = PubClient();

  // Package Information
  PackageOptions? _pkgOptions;

  final ReceivePort _readMePort =
      ReceivePort('GET_PACKAGE_README_ISOLATE_PORT');

  Future<void> _loadData() async {
    try {
      await _pubClient
          .packageOptions(widget.pkgInfo.name)
          .then((PackageOptions value) => setState(() => _pkgOptions = value));
    } catch (e, s) {
      await logger.file(LogTypeTag.error,
          'Failed to fetch package options for package: ${widget.pkgInfo.name}',
          stackTrace: s);

      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          snackBarTile(
            context,
            'Couldn\'t get package options for package ${widget.pkgInfo.name}',
            type: SnackBarType.error,
          ),
        );
      }
    }
  }

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  @override
  void dispose() {
    _readMePort.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (_, ref, __) {
        ThemeState themeState = ref.watch(themeStateController);

        return DialogTemplate(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              DialogHeader(
                title: widget.pkgInfo.name,
                leading: const StageTile(stageType: StageType.beta),
              ),
              if (_pkgOptions?.isDiscontinued == true)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: informationWidget(
                    'Attention: This package is currently discontinued and will not receive any future updates.${_pkgOptions?.replacedBy != null ? '\nSuggested replacement: ${_pkgOptions!.replacedBy}' : ''}',
                    type: InformationType.warning,
                  ),
                ),
              Builder(
                builder: (BuildContext context) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: RoundContainer(
                              child: Column(
                                children: <Widget>[
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Text(widget
                                          .pkgInfo.metrics!.score.grantedPoints
                                          .toString()),
                                      Text(
                                        ' of ${widget.pkgInfo.metrics?.score.maxPoints}',
                                        style:
                                            const TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                  VSeparators.small(),
                                  const Text('Pub Points'),
                                ],
                              ),
                            ),
                          ),
                          HSeparators.small(),
                          Expanded(
                            child: RoundContainer(
                              child: Column(
                                children: <Widget>[
                                  Text(NumberFormat.percentPattern().format(
                                      widget.pkgInfo.metrics!.score
                                          .popularityScore)),
                                  VSeparators.small(),
                                  const Text('Popularity'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      VSeparators.small(),
                      RoundContainer(
                        width: double.infinity,
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(NumberFormat.compact().format(
                                      widget.pkgInfo.metrics!.score.likeCount)),
                                  VSeparators.small(),
                                  const Text('Package Likes'),
                                ],
                              ),
                            ),
                            HSeparators.small(),
                            // Shows a like button for the user to like the
                            // package.
                            IconButton(
                              onPressed: () async {
                                ScaffoldMessenger.of(context).clearSnackBars();
                                // Show snackbar to ask the user to sign
                                // in to like the package.
                                ScaffoldMessenger.of(context).showSnackBar(
                                  snackBarTile(
                                    context,
                                    'Please sign in to like and view all of your package inventory.',
                                    type: SnackBarType.warning,
                                  ),
                                );
                              },
                              icon: Icon(
                                Icons.thumb_up_outlined,
                                color: themeState.darkTheme
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      VSeparators.small(),
                      RoundContainer(
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(widget.pkgInfo.info.description),
                            VSeparators.small(),
                            InkWell(
                              onTap: () {
                                Clipboard.setData(ClipboardData(
                                    text:
                                        '${widget.pkgInfo.name}: ^${widget.pkgInfo.info.version}'));
                                ScaffoldMessenger.of(context).clearSnackBars();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  snackBarTile(
                                    context,
                                    'Dependency has been copied to your clipboard.',
                                    type: SnackBarType.done,
                                  ),
                                );
                              },
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                      'Version ${widget.pkgInfo.info.version}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  HSeparators.small(),
                                  const Icon(Icons.copy_rounded, size: 15),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      VSeparators.small(),
                      RoundContainer(
                        width: double.infinity,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                widget.pkgInfo.publisher.publisherId ??
                                    'Unknown Publisher',
                              ),
                            ),
                          ],
                        ),
                      ),
                      VSeparators.small(),
                      RectangleButton(
                        width: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'Open in Pub.dev',
                              style: TextStyle(
                                color: themeState.darkTheme
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                            HSeparators.small(),
                            Icon(
                              Icons.open_in_new_rounded,
                              size: 15,
                              color: themeState.darkTheme
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ],
                        ),
                        onPressed: () =>
                            launchUrl(Uri.parse(widget.pkgInfo.info.url)),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
