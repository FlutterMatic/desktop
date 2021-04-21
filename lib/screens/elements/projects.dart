import 'package:flutter/material.dart';
import 'package:flutter_installer/components/dialog_templates/general/new_project.dart';
import 'package:flutter_installer/components/dialog_templates/general/open_options.dart';
import 'package:flutter_installer/components/widgets/round_container.dart';
import 'package:flutter_installer/components/widgets/square_button.dart';
import 'package:flutter_installer/components/widgets/title_section.dart';
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
            builder: (context) => NewProjectDialog(),
          ),
          context: context,
        ),
        (projs.isEmpty)
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 100.0),
                  child: Text('No Projects found at the moment.'),
                ),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: SizedBox(
                  width: 500,
                  height: 0.47 * MediaQuery.of(context).size.height,
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: projs.length,
                    itemBuilder: (_, index) {
                      return ProjectTile(
                        fileName: projs[index],
                        filePath: '$projDir/${projs[index]}',
                        lastEdit: projsModDate[index],
                      );
                    },
                  ),
                ),
              ),
        // ProjectTile(
        //     fileName: 'flutter_tooltip',
        //     filePath: 'path',
        //     lastEdit: 'Jan - 17, 2021',
        //   ),
      ],
    ),
  );
}

class ProjectTile extends StatefulWidget {
  final String fileName;
  final String filePath;
  final String? lastEdit;

  ProjectTile({
    required this.fileName,
    required this.filePath,
    this.lastEdit,
  });

  @override
  _ProjectTileState createState() => _ProjectTileState();
}

class _ProjectTileState extends State<ProjectTile> {
  @override
  Widget build(BuildContext context) {
    ThemeData customTheme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: RoundContainer(
        height: 55,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        radius: 5,
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
            SquareButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => OpenOptionsDialog(),
                );
              },
              color: customTheme.primaryColorLight,
              icon: Icon(
                Icons.more_vert_rounded,
                color: customTheme.iconTheme.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
