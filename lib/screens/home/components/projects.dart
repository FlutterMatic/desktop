import 'package:flutter/material.dart';
import 'package:flutter_installer/components/dialog_templates/new_project.dart';
import 'package:flutter_installer/components/dialog_templates/open_options.dart';
import 'package:flutter_installer/components/square_button.dart';
import 'package:flutter_installer/components/title_section.dart';
import 'package:flutter_installer/services/themes.dart';
import 'package:flutter_installer/utils/constants.dart';

Widget projects(BuildContext context) {
  ThemeData customTheme = Theme.of(context);
  return SizedBox(
    width: 500,
    child: Column(
      children: <Widget>[
        titleSection(
          'Projects',
          Icon(
            Icons.add_rounded,
            color: customTheme.iconTheme.color,
          ),
          () => showDialog(
            context: context,
            builder: (_) => NewProjectDialog(),
          ),
          context: context,
        ),
        ProjectTile(
          fileName: 'flutter_tooltip',
          lastEdit: 'Jan - 17, 2021',
          //TODO: Open file onPressed
          onPressed: () {},
        ),
        ProjectTile(
          fileName: 'flutter_tooltip',
          lastEdit: 'Jan - 17, 2021',
          //TODO: Open file onPressed
          onPressed: () {},
        ),
        ProjectTile(
          fileName: 'flutter_tooltip',
          lastEdit: 'Jan - 17, 2021',
          //TODO: Open file onPressed
          onPressed: () {},
        ),
      ],
    ),
  );
}

class ProjectTile extends StatefulWidget {
  final String fileName;
  final String? lastEdit;
  final Function() onPressed;

  ProjectTile({
    required this.fileName,
    required this.onPressed,
    this.lastEdit,
  });

  @override
  _ProjectTileState createState() => _ProjectTileState();
}

bool _hovered = false;

class _ProjectTileState extends State<ProjectTile> {
  @override
  Widget build(BuildContext context) {
    CustomTheme currentTheme = CustomTheme();
    ThemeData customTheme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: MouseRegion(
        onEnter: (event) => setState(() => _hovered = false),
        onHover: (event) => setState(() => _hovered = true),
        onExit: (event) => setState(() => _hovered = false),
        child: Container(
          height: 55,
          width: double.infinity,
          // onPressed: widget.onPressed,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: currentTheme.currentTheme == ThemeMode.dark
                ? customTheme.primaryColorLight
                : kLightGreyColor,
          ),
          child: Row(
            children: <Widget>[
              const Icon(Iconsdata.folder, color: kGreenColor),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.fileName,
                      maxLines: 1,
                      overflow: TextOverflow.fade,
                      softWrap: false,
                      style: TextStyle(
                        color: customTheme.textTheme.bodyText1!.color,
                      ),
                    ),
                    widget.lastEdit != null
                        ? Text(
                            widget.lastEdit!,
                            style: TextStyle(
                              fontSize: 12,
                              color: customTheme.textTheme.bodyText1!.color!
                                  .withOpacity(0.5),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ],
                ),
              ),
              _hovered
                  ? SquareButton(
                      color: customTheme.buttonColor,
                      tooltip: 'Options',
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => OpenOptionsDialog(),
                        );
                      },
                      icon: Icon(
                        Icons.more_vert_rounded,
                        color: customTheme.iconTheme.color,
                      ),
                    )
                  : const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}
