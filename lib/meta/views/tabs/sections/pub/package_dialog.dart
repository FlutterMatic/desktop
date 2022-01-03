// 🐦 Flutter imports:
import 'dart:isolate';

import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:manager/core/libraries/services.dart';
import 'package:pub_api_client/pub_api_client.dart';
import 'package:pub_api_client/src/models/package_like_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_html/flutter_html.dart' as html;

// 🌎 Project imports:
import 'package:manager/core/libraries/components.dart';
import 'package:manager/core/libraries/constants.dart';
import 'package:manager/core/libraries/utils.dart';
import 'package:manager/core/libraries/widgets.dart';

Future<void> _getPkgReadMe(List<dynamic> data) async {
  SendPort _port = data[0];
  String _pkgName = data[1];

  try {
    String _readMe = '';

    http.Response _response =
        await http.get(Uri.parse('https://pub.dev/packages/$_pkgName'));

    // Everything between `<section class="tab-content detail-tab-readme-content -active markdown-body">`
    // and `</section>` is the README.md markdown data.

    String _startTxt =
        '<section class="tab-content detail-tab-readme-content -active markdown-body">';
    String _endTxt = '</section>';

    int _start = _response.body.indexOf(_startTxt) + _startTxt.length;

    int _end = 0;

    while (_end < _start) {
      _end = _response.body.indexOf(_endTxt, _end + 1);
    }

    _readMe = _response.body.substring(_start, _end);

    _port.send(_readMe);
  } catch (_, s) {
    await logger.file(
        LogTypeTag.error, 'Failed to fetch README for package: $_pkgName',
        stackTraces: s);
    _port.send(false);
  }
}

class PubPackageDialog extends StatefulWidget {
  final String pkgName;

  const PubPackageDialog({Key? key, required this.pkgName}) : super(key: key);

  @override
  State<PubPackageDialog> createState() => _PubPackageDialogState();
}

class _PubPackageDialogState extends State<PubPackageDialog> {
  String? _data;
  bool _hasReadme = true;

  // Pub Client
  final PubClient _pubClient = PubClient();

  // Package Information
  PubPackage? _info;
  PackageMetrics? _metrics;
  PackageLike? _userLikeStatus;
  PackagePublisher? _publisher;
  PackageOptions? _options;

  bool _shouldDisplay = false;

  final ReceivePort _readMePort = ReceivePort();

  Future<void> _loadData() async {
    // Gets the package metrics information.
    PackageMetrics? _pkgScore = await _pubClient.packageMetrics(widget.pkgName);

    // Gets the package information.
    PubPackage _pkgInfo = await _pubClient.packageInfo(widget.pkgName);

    // Gets the publisher information.
    PackagePublisher _pkgPublisher =
        await _pubClient.packagePublisher(widget.pkgName);

    PackageOptions _pkgOptions =
        await _pubClient.packageOptions(widget.pkgName);

    Isolate _isolate = await Isolate.spawn(_getPkgReadMe, <dynamic>[
      _readMePort.sendPort,
      widget.pkgName,
    ]);

    _readMePort.listen((dynamic _readMe) {
      if (_readMe is String) {
        setState(() => _data = _readMe);
      } else {
        setState(() => _hasReadme = false);
      }
      setState(() {
        _info = _pkgInfo;
        _metrics = _pkgScore;
        _publisher = _pkgPublisher;
        _options = _pkgOptions;
        _shouldDisplay = true;
      });
      _isolate.kill();
    });
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
      width: 800,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const DialogHeader(title: 'Pub Package'),
          if (_shouldDisplay && _options?.isDiscontinued == true)
            informationWidget(
              'Attention: This package is currently discontinued and will not receive any future updates.${_options?.replacedBy != null ? '\nSuggested replacement: ${_options!.replacedBy}' : ''}',
              type: InformationType.warning,
            ),
          VSeparators.normal(),
          if (!_shouldDisplay)
            const CustomLinearProgressIndicator()
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: _size.width > 1000 ? 500 : 450,
                    maxWidth: _size.width > 1000 ? 500 : 450,
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
                          return SingleChildScrollView(
                            child: html.Html(
                              data: _data,
                              onImageError: (_, __) async {
                                await logger.file(LogTypeTag.error,
                                    'Failed to load README.md image for package ${widget.pkgName}',
                                    stackTraces: __);
                              },
                              onMathError: (_, __, ___) {
                                return const SizedBox.shrink();
                              },
                              onLinkTap: (String? url, _, __, ___) async {
                                if (url != null) {
                                  bool _canLaunch = await canLaunch(url);
                                  if (_canLaunch) {
                                    await launch(url);
                                  }
                                }
                              },
                            ),
                          );
                        }
                      } catch (_) {
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
                      if (_shouldDisplay) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: RoundContainer(
                                    color: Colors.blueGrey.withOpacity(0.2),
                                    child: Column(
                                      children: <Widget>[
                                        Text(_metrics!.score.grantedPoints
                                            .toString()),
                                        VSeparators.small(),
                                        const Text('Pub Points'),
                                      ],
                                    ),
                                  ),
                                ),
                                HSeparators.small(),
                                Expanded(
                                  child: RoundContainer(
                                    color: Colors.blueGrey.withOpacity(0.2),
                                    child: Column(
                                      children: <Widget>[
                                        Text(NumberFormat.percentPattern()
                                            .format(_metrics!
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
                              color: Colors.blueGrey.withOpacity(0.2),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(NumberFormat.compact()
                                            .format(_metrics!.score.likeCount)),
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
                                      if (_userLikeStatus != null &&
                                          _userLikeStatus!.liked) {
                                        await _pubClient
                                            .unlikePackage(widget.pkgName);
                                      } else if (_userLikeStatus != null &&
                                          !_userLikeStatus!.liked) {
                                        await _pubClient
                                            .likePackage(widget.pkgName);
                                      } else {
                                        // Show snackbar to ask the user to sign
                                        // in to like the package.
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          snackBarTile(context,
                                              'Please sign in to like and view all of your package inventory.',
                                              type: SnackBarType.warning,
                                              revert: true),
                                        );
                                      }
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
                              color: Colors.blueGrey.withOpacity(0.2),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    _info!.description,
                                  ),
                                  VSeparators.small(),
                                  Text(
                                    'Version ' + _info!.version,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            VSeparators.normal(),
                            RoundContainer(
                              width: double.infinity,
                              color: Colors.blueGrey.withOpacity(0.2),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                      _publisher!.publisherId ??
                                          'Unknown Publisher',
                                    ),
                                  ),
                                  HSeparators.small(),
                                  // Shows verified icon if the publisher is verified.
                                  // TODO: Check if the publisher is verified first.
                                  // Dumbest code I had to write in my career.
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
                              onPressed: () {
                                launch(_info?.url ?? 'https://pub.dev');
                              },
                            ),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
