// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pub_api_client/pub_api_client.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/ui/snackbar_tile.dart';
import 'package:fluttermatic/components/widgets/ui/spinner.dart';
import 'package:fluttermatic/core/notifiers/models/state/general/theme.dart';
import 'package:fluttermatic/core/notifiers/out.dart';
import 'package:fluttermatic/core/services/logs.dart';
import 'package:fluttermatic/meta/views/tabs/sections/pub/dialogs/package_info.dart';
import 'package:fluttermatic/meta/views/tabs/sections/pub/models/pkg_data.dart';

class PubPackageSearchResultTile extends StatefulWidget {
  final PkgViewData package;

  const PubPackageSearchResultTile({Key? key, required this.package})
      : super(key: key);

  @override
  State<PubPackageSearchResultTile> createState() =>
      _PubPackageSearchResultTileState();
}

class _PubPackageSearchResultTileState
    extends State<PubPackageSearchResultTile> {
  PackagePublisher? _pkgInfo;

  Future<void> _fetchPkgInfo() async {
    try {
      PackagePublisher info = await PubClient()
          .packagePublisher(widget.package.name)
          .timeout(const Duration(seconds: 5));

      if (mounted) {
        setState(() => _pkgInfo = info);
      }
    } catch (_, s) {
      await logger.file(LogTypeTag.error, 'Failed to get package info.',
          stackTraces: s);
    }
  }

  @override
  void initState() {
    _fetchPkgInfo();
    super.initState();
  }

  @override
  void dispose() {
    _pkgInfo = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (_, ref, __) {
        ThemeState themeState = ref.watch(themeStateController);

        return RectangleButton(
          width: 500,
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => PubPackageDialog(pkgInfo: widget.package),
            );
          },
          padding: const EdgeInsets.all(5),
          child: Row(
            children: <Widget>[
              HSeparators.xSmall(),
              Expanded(
                child: Text(
                  widget.package.name,
                  style: TextStyle(
                    color: themeState.darkTheme ? Colors.white : Colors.black,
                  ),
                ),
              ),
              Row(
                children: <Widget>[
                  const Tooltip(
                    message: 'Verified Publisher',
                    child: Icon(Icons.verified, size: 15, color: kGreenColor),
                  ),
                  HSeparators.xSmall(),
                  if (_pkgInfo == null)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Spinner(size: 8, thickness: 1),
                    )
                  else
                    Text(
                      _pkgInfo!.publisherId ?? 'Unknown',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.5,
                        color:
                            (themeState.darkTheme ? Colors.white : Colors.black)
                                .withOpacity(0.5),
                      ),
                    ),
                  HSeparators.xSmall(),
                  // Show a copy icon to copy the dependency directly on when
                  // hovering to avoid UI distraction.
                  RectangleButton(
                    width: 30,
                    height: 30,
                    padding: EdgeInsets.zero,
                    color: Colors.transparent,
                    hoverColor: Colors.blueGrey.withOpacity(0.2),
                    child: Icon(
                      Icons.content_copy,
                      size: 13,
                      color:
                          (themeState.darkTheme ? Colors.white : Colors.black)
                              .withOpacity(0.5),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                        snackBarTile(
                          context,
                          'Dependency has been copied to your clipboard.',
                          type: SnackBarType.done,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
