import 'package:flutter/material.dart';
import 'package:manager/app/constants/constants.dart';
import 'package:manager/components/widgets/buttons/rectangle_button.dart';
import 'package:manager/components/widgets/ui/snackbar_tile.dart';
import 'package:manager/core/models/projects.model.dart';
import 'package:manager/core/libraries/notifiers.dart';
import 'package:provider/provider.dart';

class ProjectSearchResultTile extends StatelessWidget {
  final ProjectObject project;

  const ProjectSearchResultTile({Key? key, required this.project})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RectangleButton(
      width: 500,
      padding: const EdgeInsets.all(5),
      child: Row(
        children: <Widget>[
          HSeparators.xSmall(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  project.name,
                  style: TextStyle(
                    color: context.read<ThemeChangeNotifier>().isDarkTheme
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
                VSeparators.small(),
                Text(project.path),
              ],
            ),
          ),
          Row(
            children: <Widget>[
              const Tooltip(
                message: 'Verified Publisher',
                child: Icon(Icons.verified, size: 15, color: kGreenColor),
              ),
              HSeparators.xSmall(),
              Text(
                'dart.dev',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13.5,
                  color: (context.read<ThemeChangeNotifier>().isDarkTheme
                          ? Colors.white
                          : Colors.black)
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
                  color: (context.read<ThemeChangeNotifier>().isDarkTheme
                          ? Colors.white
                          : Colors.black)
                      .withOpacity(0.5),
                ),
                onPressed: () {
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
      onPressed: () {},
    );
  }
}
