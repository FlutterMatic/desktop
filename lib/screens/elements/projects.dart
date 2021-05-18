import 'package:flutter/material.dart';
import 'package:flutter_installer/components/dialog_templates/flutter/install_flutter.dart';
import 'package:flutter_installer/components/dialog_templates/other/open_options.dart';
import 'package:flutter_installer/components/dialog_templates/projects/new_project.dart';
import 'package:flutter_installer/components/dialog_templates/projects/search_projects.dart';
import 'package:flutter_installer/components/dialog_templates/settings/settings.dart';
import 'package:flutter_installer/components/widgets/rectangle_button.dart';
import 'package:flutter_installer/components/widgets/round_container.dart';
import 'package:flutter_installer/components/widgets/spinner.dart';
import 'package:flutter_installer/components/widgets/square_button.dart';
import 'package:flutter_installer/components/widgets/title_section.dart';
import 'package:flutter_installer/services/flutter_actions.dart';
import 'package:flutter_installer/utils/constants.dart';

class Projects extends StatefulWidget {
  @override
  _ProjectsState createState() => _ProjectsState();
}

class _ProjectsState extends State<Projects> {
  bool _reloading = true;
  final List<String> _projects = [];
  final List<String> _modDate = [];

  Future<void> _initializeProjects() async {
    setState(() => _reloading = true);
    await FlutterActions().checkProjects();
    _projects.clear();
    for (var i = 0; i < projs.length; i++) {
      _projects.add(projs[i]);
    }
    _modDate.clear();
    for (var i = 0; i < projsModDate.length; i++) {
      _modDate.add(projsModDate[i]);
    }
    setState(() => _reloading = false);
  }

  @override
  void initState() {
    _initializeProjects();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData customTheme = Theme.of(context);
    return Column(
      children: <Widget>[
        titleSection(
          'Projects',
          context,
          [
            //Search Projects
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: SquareButton(
                color: customTheme.primaryColorLight,
                icon: Icon(
                  Iconsdata.search,
                  color: customTheme.iconTheme.color,
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => SearchProjectsDialog(),
                  );
                },
              ),
            ),
            //Refresh Projects
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: SquareButton(
                color: customTheme.primaryColorLight,
                icon: Icon(
                  Icons.refresh,
                  color: customTheme.iconTheme.color,
                ),
                onPressed: _reloading ? () {} : () => _initializeProjects(),
              ),
            ),
            //Add Project
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: SquareButton(
                color: customTheme.primaryColorLight,
                icon: Icon(
                  Icons.add_rounded,
                  color: customTheme.iconTheme.color,
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) {
                      if (flutterInstalled) {
                        return NewProjectDialog();
                      } else {
                        return InstallFlutterDialog();
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
        if (_reloading)
          SizedBox(height: 200, width: 200, child: Spinner())
        else
          ((projs.isEmpty)
              ? Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 100),
                    child: Column(
                      children: [
                        const Icon(Iconsdata.folder, size: 30),
                        const SizedBox(height: 20),
                        const SizedBox(
                          width: 400,
                          child: Text(
                            'No Projects found at the moment. Change your projects path or add new projects.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            RectangleButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (_) =>
                                      SettingDialog(goToPage: 'Projects'),
                                );
                              },
                              child: Text(
                                'Update Path',
                                style: TextStyle(
                                    color: customTheme
                                        .textTheme.bodyText1!.color),
                              ),
                            ),
                            const SizedBox(width: 10),
                            SquareButton(
                              icon: Icon(
                                Icons.add_rounded,
                                color: customTheme.textTheme.bodyText1!.color,
                              ),
                              color: customTheme.buttonColor,
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (_) => NewProjectDialog());
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _projects.length,
                    itemBuilder: (_, index) {
                      return ProjectTile(
                        fileName: _projects[index],
                        filePath: '$projDir/${_projects[index]}',
                        lastEdit: projsModDate[index],
                      );
                    },
                  ),
                ))
      ],
    );
  }
}

class ProjectTile extends StatelessWidget {
  final String fileName;
  final String filePath;
  final String? lastEdit;

  ProjectTile({required this.fileName, required this.filePath, this.lastEdit});
  @override
  Widget build(BuildContext context) {
    ThemeData customTheme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
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
                children: <Widget>[
                  Text(
                    fileName,
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    style: TextStyle(
                      color: customTheme.textTheme.bodyText1!.color,
                    ),
                  ),
                  lastEdit != null
                      ? Text(
                          lastEdit!,
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
                  builder: (_) => OpenOptionsDialog(fileName),
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
