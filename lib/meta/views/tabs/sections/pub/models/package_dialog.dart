// 🎯 Dart imports:
import 'dart:isolate';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 📦 Package imports:
import 'package:flutter_html/flutter_html.dart' as html;
import 'package:intl/intl.dart';
import 'package:pub_api_client/pub_api_client.dart';
import 'package:url_launcher/url_launcher.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants/constants.dart';
import 'package:fluttermatic/components/dialog_templates/dialog_header.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/ui/dialog_template.dart';
import 'package:fluttermatic/components/widgets/ui/information_widget.dart';
import 'package:fluttermatic/components/widgets/ui/markdown_view.dart';
import 'package:fluttermatic/components/widgets/ui/round_container.dart';
import 'package:fluttermatic/components/widgets/ui/shimmer.dart';
import 'package:fluttermatic/components/widgets/ui/snackbar_tile.dart';
import 'package:fluttermatic/components/widgets/ui/spinner.dart';
import 'package:fluttermatic/components/widgets/ui/stage_tile.dart';
import 'package:fluttermatic/core/services/logs.dart';
import 'package:fluttermatic/meta/utils/app_theme.dart';
import 'package:fluttermatic/meta/views/tabs/sections/pub/models/pkg_data.dart';

class PubPackageDialog extends StatefulWidget {
  final PkgViewData pkgInfo;

  const PubPackageDialog({Key? key, required this.pkgInfo}) : super(key: key);

  @override
  State<PubPackageDialog> createState() => _PubPackageDialogState();
}

class _PubPackageDialogState extends State<PubPackageDialog> {
  List<String>? _data;
  bool _hasReadme = true;

  // Pub Client
  final PubClient _pubClient = PubClient();

  // Package Information
  PackageOptions? _pkgOptions;

  bool _shouldDisplay = false;

  final ReceivePort _readMePort =
      ReceivePort('GET_PACKAGE_README_ISOLATE_PORT');

  Future<void> _loadData() async {
    try {
      await _pubClient
          .packageOptions(widget.pkgInfo.name)
          .then((PackageOptions value) => setState(() => _pkgOptions = value));

      Isolate _i =
          await Isolate.spawn(PkgViewData.getPkgReadMeIsolate, <dynamic>[
        _readMePort.sendPort,
        widget.pkgInfo.name,
      ]).timeout(
        const Duration(seconds: 10),
        onTimeout: () async {
          await logger.file(LogTypeTag.error,
              'Failed to fetch README within timeout setting for package: ${widget.pkgInfo.name}');
          _readMePort.close();
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            snackBarTile(
              context,
              'Couldn\'t get README.md for package ${widget.pkgInfo.name}',
              type: SnackBarType.error,
            ),
          );

          Navigator.pop(context);
          return Isolate.current;
        },
      );

      _readMePort.listen((dynamic _readMe) {
        _i.kill();
        if (mounted) {
          setState(() {
            if (_readMe is List<String>) {
              _data = _readMe;
            } else {
              _hasReadme = false;
            }
            _shouldDisplay = true;
          });
        }
      });
    } catch (_, s) {
      await logger.file(LogTypeTag.error,
          'Failed to fetch README for package: ${widget.pkgInfo.name}',
          stackTraces: s);
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        snackBarTile(
          context,
          'Couldn\'t get README.md for package ${widget.pkgInfo.name}',
          type: SnackBarType.error,
        ),
      );
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
    Size _size = MediaQuery.of(context).size;
    return DialogTemplate(
      width: 1000,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          DialogHeader(
            title: widget.pkgInfo.name,
            leading: const StageTile(stageType: StageType.prerelease),
          ),
          if (_shouldDisplay && _pkgOptions?.isDiscontinued == true)
            informationWidget(
              'Attention: This package is currently discontinued and will not receive any future updates.${_pkgOptions?.replacedBy != null ? '\nSuggested replacement: ${_pkgOptions!.replacedBy}' : ''}',
              type: InformationType.warning,
            ),
          VSeparators.normal(),
          IgnorePointer(
            ignoring: !_shouldDisplay,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: _size.width > 1000 ? 700 : 450,
                    maxWidth: _size.width > 1000 ? 700 : 450,
                    maxHeight: 450,
                  ),
                  child: Builder(
                    builder: (BuildContext context) {
                      try {
                        if (!_hasReadme) {
                          return informationWidget(
                            'Couldn\'t find a README.md file for this package. Check it out in pub.dev',
                            type: InformationType.warning,
                          );
                        } else {
                          if (!_shouldDisplay) {
                            return Shimmer.fromColors(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Wrap(
                                    spacing: 15,
                                    runSpacing: 15,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.start,
                                    runAlignment: WrapAlignment.start,
                                    alignment: WrapAlignment.start,
                                    children: const <Widget>[
                                      RoundContainer(
                                        child: SizedBox.shrink(),
                                        width: 150,
                                        height: 30,
                                        radius: 50,
                                      ),
                                      RoundContainer(
                                        child: SizedBox.shrink(),
                                        width: 100,
                                        height: 30,
                                        radius: 50,
                                      ),
                                      RoundContainer(
                                        child: SizedBox.shrink(),
                                        width: 120,
                                        height: 30,
                                        radius: 50,
                                      ),
                                      RoundContainer(
                                        child: SizedBox.shrink(),
                                        width: 80,
                                        height: 30,
                                        radius: 50,
                                      ),
                                    ],
                                  ),
                                  VSeparators.normal(),
                                  const Expanded(
                                      child: Center(child: Spinner())),
                                ],
                              ),
                            );
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: <Widget>[
                                    RoundContainer(
                                      child: ColorFiltered(
                                        colorFilter: ColorFilter.mode(
                                            Theme.of(context).isDarkTheme
                                                ? (widget.pkgInfo.metrics!
                                                        .scorecard.derivedTags
                                                        .contains(
                                                            'is:null-safe')
                                                    ? kGreenColor
                                                    : kYellowColor)
                                                : (widget.pkgInfo.metrics!
                                                        .scorecard.derivedTags
                                                        .contains(
                                                            'is:null-safe')
                                                    ? kGreenColor
                                                    : Colors.redAccent),
                                            BlendMode.srcATop),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Icon(
                                              widget.pkgInfo.metrics!.scorecard
                                                      .derivedTags
                                                      .contains('is:null-safe')
                                                  ? Icons.done_all_rounded
                                                  : Icons
                                                      .do_not_disturb_alt_rounded,
                                              size: 13,
                                            ),
                                            HSeparators.xSmall(),
                                            Text(widget.pkgInfo.metrics!
                                                    .scorecard.derivedTags
                                                    .contains('is:null-safe')
                                                ? 'Null safe'
                                                : 'Not null safe'),
                                          ],
                                        ),
                                      ),
                                      radius: 50,
                                    ),
                                    HSeparators.xSmall(),
                                    ...<String>[
                                      'platform:android',
                                      'platform:ios',
                                      'platform:windows',
                                      'platform:linux',
                                      'platform:macos',
                                      'platform:web',
                                    ].map(
                                      (String e) {
                                        if (!widget.pkgInfo.metrics!.scorecard
                                            .derivedTags
                                            .contains(e)) {
                                          return const SizedBox.shrink();
                                        }
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(right: 5),
                                          child: RoundContainer(
                                            child: Text(e
                                                .substring(e.indexOf(':') + 1)),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              VSeparators.xSmall(),
                              Expanded(
                                child: SingleChildScrollView(
                                  // TODO: #62 Fix rendering of pub package documentation
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: _data!.length,
                                    itemBuilder: (_, int i) {
                                      if (_data![i].startsWith('<code>')) {
                                        return MarkdownBlock(
                                            data: _data![i].substring(5));
                                      } else {
                                        return html.Html(
                                          data: _data![i].substring(5),
                                          onImageError: (_, __) async {
                                            await logger.file(LogTypeTag.error,
                                                'Failed to load README.md image for package ${widget.pkgInfo}',
                                                stackTraces: __);
                                          },
                                          onMathError: (_, __, ___) {
                                            return const Text(
                                              'Failed to load due to math error.',
                                              style: TextStyle(
                                                  color: AppTheme.errorColor),
                                            );
                                          },
                                          onLinkTap:
                                              (String? url, _, __, ___) async {
                                            if (url != null) {
                                              bool _canLaunch =
                                                  await canLaunch(url);
                                              if (_canLaunch) {
                                                await launch(url);
                                              }
                                            }
                                          },
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                      } catch (_, s) {
                        logger.file(LogTypeTag.error,
                            'Failed to load README.md for package ${widget.pkgInfo.name}',
                            stackTraces: s);
                        return informationWidget(
                          'We found a README.md for this package. However, we are not able to display if for you at the moment.',
                          type: InformationType.warning,
                        );
                      }
                    },
                  ),
                ),
                HSeparators.normal(),
                Expanded(
                  child: Builder(
                    builder: (BuildContext context) {
                      return Shimmer.fromColors(
                        enabled: !_shouldDisplay,
                        child: Column(
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
                                            Text(widget.pkgInfo.metrics!.score
                                                .grantedPoints
                                                .toString()),
                                            const Text(
                                              ' of 130',
                                              style:
                                                  TextStyle(color: Colors.grey),
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
                                        Text(NumberFormat.percentPattern()
                                            .format(widget.pkgInfo.metrics!
                                                .score.popularityScore)),
                                        VSeparators.small(),
                                        const Text('Popularity'),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            VSeparators.normal(),
                            RoundContainer(
                              width: double.infinity,
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(NumberFormat.compact().format(
                                            widget.pkgInfo.metrics!.score
                                                .likeCount)),
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
                                      ScaffoldMessenger.of(context)
                                          .clearSnackBars();
                                      // Show snackbar to ask the user to sign
                                      // in to like the package.
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        snackBarTile(
                                          context,
                                          'Please sign in to like and view all of your package inventory.',
                                          type: SnackBarType.warning,
                                        ),
                                      );
                                    },
                                    icon: Icon(
                                      Icons.thumb_up_outlined,
                                      color: Theme.of(context).isDarkTheme
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            VSeparators.normal(),
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
                                          text: widget.pkgInfo.name +
                                              ': ^${widget.pkgInfo.info.version}'));
                                      ScaffoldMessenger.of(context)
                                          .clearSnackBars();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
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
                                            'Version ' +
                                                widget.pkgInfo.info.version,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        HSeparators.small(),
                                        const Icon(Icons.copy_rounded,
                                            size: 15),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            VSeparators.normal(),
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
                                  HSeparators.small(),
                                  // Shows verified icon if the publisher is verified.
                                  // TODO: Check if the publisher is verified first.
                                  if (1 == 2)
                                    const Tooltip(
                                      message: 'Verified Publisher',
                                      child: Icon(Icons.verified_rounded,
                                          size: 18, color: kGreenColor),
                                    ),
                                ],
                              ),
                            ),
                            VSeparators.normal(),
                            RectangleButton(
                              width: double.infinity,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    'Open in Pub.dev',
                                    style: TextStyle(
                                      color: Theme.of(context).isDarkTheme
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                  HSeparators.small(),
                                  Icon(
                                    Icons.open_in_new_rounded,
                                    size: 15,
                                    color: Theme.of(context).isDarkTheme
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ],
                              ),
                              onPressed: () => launch(widget.pkgInfo.info.url),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
