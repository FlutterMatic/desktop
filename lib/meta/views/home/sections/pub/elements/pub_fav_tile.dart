import 'package:flutter/material.dart';
import 'package:manager/app/constants/constants.dart';
import 'package:manager/components/widgets/buttons/rectangle_button.dart';
import 'package:manager/components/widgets/ui/snackbar_tile.dart';
import 'package:manager/core/notifiers/theme.notifier.dart';
import 'package:manager/meta/utils/app_theme.dart';
import 'package:manager/meta/views/home/sections/pub/package_dialog.dart';
import 'package:provider/provider.dart';

class PubFavoriteTile extends StatefulWidget {
  const PubFavoriteTile({Key? key}) : super(key: key);

  @override
  _PubFavoriteTileState createState() => _PubFavoriteTileState();
}

class _PubFavoriteTileState extends State<PubFavoriteTile> {
  // Whether or not the user is hovering on the tile. We will show more details
  // if the user is hovering.
  bool _isHovering = false;

  // If the package is migrated to null safety, then this will be true,
  // otherwise false.
  final bool _nullSafe = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: RectangleButton(
        width: 250,
        height: 230,
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => const PubPackageDialog(),
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
                            'package_info_plus',
                            style: TextStyle(
                              color: context.read<ThemeChangeNotifier>().isDarkTheme ? Colors.white : Colors.black,
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
                              color: (context.read<ThemeChangeNotifier>().isDarkTheme ? Colors.white : Colors.black)
                                  .withOpacity(0.5),
                            ),
                            onPressed: () {
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
                        'Flutter plugin for querying information about the application package, such as CFBundleVersion on iOS or versionCode on Android.',
                        style: TextStyle(
                          color: Theme.of(context).isDarkTheme ? Colors.white : Colors.black,
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
                          color: (Theme.of(context).isDarkTheme ? Colors.white : Colors.black).withOpacity(0.5),
                        ),
                        HSeparators.xSmall(),
                        Text(
                          '5.01K',
                          style: TextStyle(
                            color: (Theme.of(context).isDarkTheme ? Colors.white : Colors.black).withOpacity(0.5),
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
                          color: (Theme.of(context).isDarkTheme ? Colors.white : Colors.black).withOpacity(0.5),
                        ),
                        HSeparators.xSmall(),
                        Text(
                          '130',
                          style: TextStyle(
                            color: (Theme.of(context).isDarkTheme ? Colors.white : Colors.black).withOpacity(0.5),
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
                          color: (Theme.of(context).isDarkTheme ? Colors.white : Colors.black).withOpacity(0.5),
                        ),
                        HSeparators.xSmall(),
                        Text(
                          '100%',
                          style: TextStyle(
                            color: (Theme.of(context).isDarkTheme ? Colors.white : Colors.black).withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              VSeparators.small(),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    _nullSafe ? Icons.done_all_rounded : Icons.do_not_disturb_alt_rounded,
                    size: 13,
                    color: _nullSafe ? kGreenColor : kYellowColor,
                  ),
                  HSeparators.xSmall(),
                  Text(
                    _nullSafe ? 'Null safe' : 'Not null safe',
                    style: TextStyle(color: _nullSafe ? kGreenColor : kYellowColor),
                  ),
                ],
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
                      'fluttercommunity.dev',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.5,
                        color: (Theme.of(context).isDarkTheme ? Colors.white : Colors.black).withOpacity(0.5),
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
