// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants.dart';
import 'package:fluttermatic/components/widgets/buttons/square_button.dart';
import 'package:fluttermatic/components/widgets/ui/round_container.dart';
import 'package:fluttermatic/components/widgets/ui/snackbar_tile.dart';
import 'package:fluttermatic/meta/views/tabs/sections/pub/dialogs/package_info.dart';
import 'package:fluttermatic/meta/views/tabs/sections/pub/models/pkg_data.dart';

class SearchPackageTile extends StatelessWidget {
  final PkgViewData package;

  const SearchPackageTile({
    Key? key,
    required this.package,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 5, left: 10),
      child: RoundContainer(
        height: 150,
        width: 200,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(package.name, maxLines: 1, overflow: TextOverflow.ellipsis),
            VSeparators.xSmall(),
            Expanded(
              child: Text(
                package.info.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            VSeparators.xSmall(),
            Row(
              children: <Widget>[
                SquareButton(
                  size: 20,
                  tooltip: 'Copy',
                  color: Colors.transparent,
                  hoverColor: Colors.transparent,
                  icon: const Icon(Icons.copy_rounded, size: 12),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(
                        text: '${package.name}: ^${package.info.version}'));

                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(snackBarTile(
                      context,
                      'Copied ${package.name} to clipboard.',
                      type: SnackBarType.done,
                    ));
                  },
                ),
                const Spacer(),
                InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => PubPackageDialog(pkgInfo: package),
                    );
                  },
                  child: const Text('Open'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
