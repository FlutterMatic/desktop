// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 📦 Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/ui/round_container.dart';
import 'package:fluttermatic/components/widgets/ui/shimmer.dart';
import 'package:fluttermatic/components/widgets/ui/snackbar_tile.dart';
import 'package:fluttermatic/core/notifiers/models/state/general/theme.dart';
import 'package:fluttermatic/core/notifiers/out.dart';
import 'package:fluttermatic/meta/views/tabs/sections/pub/dialogs/package_info.dart';
import 'package:fluttermatic/meta/views/tabs/sections/pub/models/pkg_data.dart';

class PubPkgTile extends StatefulWidget {
  final PkgViewData? data;

  const PubPkgTile({Key? key, required this.data}) : super(key: key);

  @override
  _PubPkgTileState createState() => _PubPkgTileState();
}

class _PubPkgTileState extends State<PubPkgTile> {
  // Whether or not the user is hovering on the tile. We will show more details
  // if the user is hovering.
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    if (widget.data == null) {
      return RoundContainer(
        width: 250,
        height: 230,
        child: Shimmer.fromColors(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const RoundContainer(
                  width: 150, height: 20, child: SizedBox.shrink()),
              VSeparators.normal(),
              const RoundContainer(
                  width: 200, height: 20, child: SizedBox.shrink()),
              VSeparators.normal(),
              const Expanded(
                child: RoundContainer(width: 350, child: SizedBox.shrink()),
              ),
              VSeparators.normal(),
              const RoundContainer(
                  width: 50, height: 30, child: SizedBox.shrink()),
            ],
          ),
        ),
      );
    }
    return Consumer(
      builder: (_, ref, __) {
        ThemeState themeState = ref.watch(themeStateController);

        return MouseRegion(
          onHover: (_) => setState(() => _isHovering = true),
          onExit: (_) => setState(() => _isHovering = false),
          child: InkWell(
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => PubPackageDialog(pkgInfo: widget.data!),
              );
            },
            child: RoundContainer(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            widget.data!.name,
                            maxLines: 1,
                            overflow: TextOverflow.fade,
                            softWrap: false,
                            style: TextStyle(
                              color: themeState.darkTheme
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 17,
                            ),
                          ),
                        ),
                        // Show a copy icon to copy the dependency directly on when
                        // hovering to avoid UI distraction.
                        if (_isHovering)
                          Tooltip(
                            message: 'Copy dependency',
                            waitDuration: const Duration(seconds: 1),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: RectangleButton(
                                width: 22,
                                height: 22,
                                padding: EdgeInsets.zero,
                                radius: BorderRadius.circular(2),
                                color: Colors.transparent,
                                child: Icon(
                                  Icons.content_copy,
                                  size: 14,
                                  color: (themeState.darkTheme
                                          ? Colors.white
                                          : Colors.black)
                                      .withOpacity(0.5),
                                ),
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(
                                      text:
                                          '${widget.data!.name}: ^${widget.data!.info.version}'));
                                  ScaffoldMessenger.of(context)
                                      .clearSnackBars();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    snackBarTile(
                                      context,
                                      'Dependency has been copied to your clipboard.',
                                      type: SnackBarType.done,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                      ],
                    ),
                    VSeparators.small(),
                    Expanded(
                      child: Text(
                        widget.data?.info.description ??
                            'No package description provided.',
                        maxLines: _isHovering ? null : 3,
                        style: TextStyle(
                          color: themeState.darkTheme
                              ? Colors.white
                              : Colors.black,
                          fontSize: 13.5,
                        ),
                      ),
                    ),
                    VSeparators.normal(),
                    if (_isHovering)
                      const ColorFiltered(
                        colorFilter:
                            ColorFilter.mode(kGreenColor, BlendMode.srcATop),
                        child: Text('Tap to learn more'),
                      ),
                    VSeparators.small(),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Tooltip(
                            message: 'Likes',
                            waitDuration: const Duration(seconds: 1),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(
                                  Icons.thumb_up_alt_rounded,
                                  size: 13,
                                  color: (themeState.darkTheme
                                          ? Colors.white
                                          : Colors.black)
                                      .withOpacity(0.5),
                                ),
                                HSeparators.xSmall(),
                                Text(
                                  NumberFormat.compact().format(
                                      widget.data?.metrics?.score.likeCount ??
                                          0),
                                  style: TextStyle(
                                    color: (themeState.darkTheme
                                            ? Colors.white
                                            : Colors.black)
                                        .withOpacity(0.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Tooltip(
                            message: 'Score',
                            waitDuration: const Duration(seconds: 1),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(
                                  Icons.insights_rounded,
                                  size: 13,
                                  color: (themeState.darkTheme
                                          ? Colors.white
                                          : Colors.black)
                                      .withOpacity(0.5),
                                ),
                                HSeparators.xSmall(),
                                Text(
                                  (widget.data?.metrics?.score.maxPoints ?? 0)
                                      .toString(),
                                  style: TextStyle(
                                    color: (themeState.darkTheme
                                            ? Colors.white
                                            : Colors.black)
                                        .withOpacity(0.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Tooltip(
                            message: 'Popularity',
                            waitDuration: const Duration(seconds: 1),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(
                                  Icons.public_rounded,
                                  size: 13,
                                  color: (themeState.darkTheme
                                          ? Colors.white
                                          : Colors.black)
                                      .withOpacity(0.5),
                                ),
                                HSeparators.xSmall(),
                                Text(
                                  '${NumberFormat.compact().format((widget.data?.metrics?.score.popularityScore ?? 0) * 100)}%',
                                  style: TextStyle(
                                    color: (themeState.darkTheme
                                            ? Colors.white
                                            : Colors.black)
                                        .withOpacity(0.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    VSeparators.normal(),
                    Row(
                      children: <Widget>[
                        const Tooltip(
                          message: 'Verified Publisher',
                          waitDuration: Duration(seconds: 1),
                          child: Icon(Icons.verified,
                              size: 15, color: kGreenColor),
                        ),
                        HSeparators.xSmall(),
                        Expanded(
                          child: Text(
                            widget.data?.publisher.publisherId ?? 'Unknown',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13.5,
                              color: (themeState.darkTheme
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
          ),
        );
      },
    );
  }
}
