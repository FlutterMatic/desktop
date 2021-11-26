// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 📦 Package imports:
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_api_client/pub_api_client.dart';

// 🌎 Project imports:
import 'package:manager/core/libraries/constants.dart';
import 'package:manager/core/libraries/models.dart';
import 'package:manager/core/libraries/utils.dart';
import 'package:manager/core/libraries/views.dart';
import 'package:manager/core/libraries/widgets.dart';

class PubFavoriteTile extends StatefulWidget {
  final String name;
  const PubFavoriteTile({Key? key, required this.name}) : super(key: key);

  @override
  _PubFavoriteTileState createState() => _PubFavoriteTileState();
}

class _PubFavoriteTileState extends State<PubFavoriteTile> {
  // Whether or not the user is hovering on the tile. We will show more details
  // if the user is hovering.
  bool _isHovering = false;

  PubPackage? _package;
  PackageMetrics? _metrics;
  PackagePublisher? _publisher;

  // If the package is migrated to null safety, then this will be true,
  // otherwise false.
  final bool _nullSafe = false;

  Future<void> _getPkgInfo() async {
    PubPackage _info = await PubClient().packageInfo(widget.name);
    PackageMetrics? _data = await PubClient().packageMetrics(widget.name);
    PackagePublisher _author = await PubClient().packagePublisher(widget.name);
    setState(() {
      _package = _info;
      _metrics = _data;
      _publisher = _author;
    });
  }

  @override
  void initState() {
    _getPkgInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_package == null) {
      return const RoundContainer(
        width: 250,
        height: 230,
        child: Spinner(thickness: 2),
      );
    }
    return MouseRegion(
      onHover: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: RectangleButton(
        width: 250,
        height: 230,
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => PubPackageDialog(pkgName: widget.name),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            widget.name,
                            style: TextStyle(
                              color: Theme.of(context).isDarkTheme
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 17,
                            ),
                          ),
                        ),
                        // Show a copy icon to copy the dependency directly on when
                        // hovering to avoid UI distraction.
                        if (_isHovering)
                          RectangleButton(
                            width: 22,
                            height: 22,
                            padding: EdgeInsets.zero,
                            color: Colors.transparent,
                            child: Icon(
                              Icons.content_copy,
                              size: 14,
                              color: (Theme.of(context).isDarkTheme
                                      ? Colors.white
                                      : Colors.black)
                                  .withOpacity(0.5),
                            ),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(
                                  text:
                                      widget.name + ': ^${_package!.version}'));
                              ScaffoldMessenger.of(context).showSnackBar(
                                snackBarTile(
                                  context,
                                  'Dependency has been copied to your clipboard.',
                                  type: SnackBarType.done,
                                  revert: true,
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                    VSeparators.small(),
                    Expanded(
                      child: Text(
                        _package?.description ??
                            'No package description provided.',
                        style: TextStyle(
                          color: Theme.of(context).isDarkTheme
                              ? Colors.white
                              : Colors.black,
                          fontSize: 13.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              VSeparators.small(),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          Icons.thumb_up_alt_rounded,
                          size: 13,
                          color: (Theme.of(context).isDarkTheme
                                  ? Colors.white
                                  : Colors.black)
                              .withOpacity(0.5),
                        ),
                        HSeparators.xSmall(),
                        Text(
                          NumberFormat.compact()
                              .format(_metrics?.score.likeCount ?? 0),
                          style: TextStyle(
                            color: (Theme.of(context).isDarkTheme
                                    ? Colors.white
                                    : Colors.black)
                                .withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          Icons.insights_rounded,
                          size: 13,
                          color: (Theme.of(context).isDarkTheme
                                  ? Colors.white
                                  : Colors.black)
                              .withOpacity(0.5),
                        ),
                        HSeparators.xSmall(),
                        Text(
                          (_metrics?.score.maxPoints ?? 0).toString(),
                          style: TextStyle(
                            color: (Theme.of(context).isDarkTheme
                                    ? Colors.white
                                    : Colors.black)
                                .withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          Icons.public_rounded,
                          size: 13,
                          color: (Theme.of(context).isDarkTheme
                                  ? Colors.white
                                  : Colors.black)
                              .withOpacity(0.5),
                        ),
                        HSeparators.xSmall(),
                        Text(
                          (_metrics?.score.maxPoints ?? 0).toString() + '%',
                          style: TextStyle(
                            color: (Theme.of(context).isDarkTheme
                                    ? Colors.white
                                    : Colors.black)
                                .withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              VSeparators.small(),
              ColorFiltered(
                colorFilter: ColorFilter.mode(
                    Theme.of(context).isDarkTheme
                        ? (_nullSafe ? kGreenColor : kYellowColor)
                        : (_nullSafe ? kGreenColor : Colors.redAccent),
                    BlendMode.srcATop),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      _nullSafe
                          ? Icons.done_all_rounded
                          : Icons.do_not_disturb_alt_rounded,
                      size: 13,
                    ),
                    HSeparators.xSmall(),
                    Text(_nullSafe ? 'Null safe' : 'Not null safe'),
                  ],
                ),
              ),
              VSeparators.small(),
              Row(
                children: <Widget>[
                  const Tooltip(
                    message: 'Verified Publisher',
                    child: Icon(Icons.verified, size: 15, color: kGreenColor),
                  ),
                  HSeparators.xSmall(),
                  Expanded(
                    child: Text(
                      _publisher?.publisherId ?? 'Unknown',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.5,
                        color: (Theme.of(context).isDarkTheme
                                ? Colors.white
                                : Colors.black)
                            .withOpacity(0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
