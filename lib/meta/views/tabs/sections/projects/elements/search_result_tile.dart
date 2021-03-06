// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants/constants.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/core/models/projects.model.dart';
import 'package:fluttermatic/meta/utils/app_theme.dart';

class ProjectSearchResultTile extends StatelessWidget {
  final ProjectObject project;

  const ProjectSearchResultTile({Key? key, required this.project})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RectangleButton(
      width: 500,
      height: 60,
      onPressed: () {},
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
                  maxLines: 1,
                  style: TextStyle(
                    color: Theme.of(context).isDarkTheme
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
                VSeparators.small(),
                Text(
                  project.description ?? project.path,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Icon(
              Icons.arrow_forward_ios_rounded,
              size: 13,
              color:
                  (Theme.of(context).isDarkTheme ? Colors.white : Colors.black)
                      .withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}
