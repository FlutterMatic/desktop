import 'package:flutter/material.dart';
import 'package:flutter_installer/components/dialog_templates/dialog_header.dart';
import 'package:flutter_installer/components/dialog_templates/projects/open_options.dart';
import 'package:flutter_installer/components/dialog_templates/settings/settings.dart';
import 'package:flutter_installer/components/widgets/buttons/rectangle_button.dart';
import 'package:flutter_installer/components/widgets/ui/current_directory.dart';
import 'package:flutter_installer/components/widgets/ui/dialog_template.dart';
import 'package:flutter_installer/components/widgets/ui/round_container.dart';
import 'package:flutter_installer/components/widgets/inputs/text_field.dart';
import 'package:flutter_installer/components/widgets/ui/snackbar_tile.dart';
import 'package:flutter_installer/components/widgets/ui/spinner.dart';
import 'package:flutter_installer/models/projects.dart';
import 'package:flutter_installer/services/flutter_actions.dart';
import 'package:flutter_installer/utils/constants.dart';

class SearchProjectsDialog extends StatefulWidget {
  final List projects;

  SearchProjectsDialog({required this.projects});

  @override
  _SearchProjectsDialogState createState() => _SearchProjectsDialogState();
}

class _SearchProjectsDialogState extends State<SearchProjectsDialog> {
  bool _loading = true;
  bool _showResults = false;
  String? _searchInput;
  List<ProjectsModel> _searchResults = [];
  
  Future<void> _loadProjects() async {
    setState(() => _loading = true);
    try {
      await FlutterActions().checkProjects();
    } catch (_) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
          snackBarTile('Unable to load projects', type: SnackBarType.error));
    }
    setState(() => _loading = false);
  }

  void _reloadSearch() {
    _searchResults.clear();
    setState(() => _showResults = true);
    for (var i = 0; i < projs.length; i++) {
      String _itemValue = projs[i];
      if (_itemValue.toLowerCase().contains(_searchInput!)) {
        _searchResults.add(
          ProjectsModel(
            name: projs[i],
            path: '$projDir/${projs[i]}',
            modDate: projsModDate[i],
          ),
        );
      }
    }
  }

  @override
  void initState() {
    _loadProjects();
    super.initState();
  }

  @override
  void dispose() {
    _searchResults = [];
    _showResults = false;
    _searchInput = null;
    _loading = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData customTheme = Theme.of(context);
    return DialogTemplate(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          DialogHeader(title: 'Search Projects'),
          const SizedBox(height: 20),
          // const Center(
          //   child: Padding(
          //     padding: EdgeInsets.symmetric(vertical: 10),
          //     child: ColoredBox(
          //       color: kDarkColor,
          //       child: SizedBox(width: 250, height: 2),
          //     ),
          //   ),
          // ),
          if (!_loading && projs.isNotEmpty)
            CustomTextField(
              hintText: 'Search',
              autofocus: true,
              onChanged: (val) {
                setState(() {
                  if (val.isNotEmpty) {
                    _searchInput = val;
                  } else {
                    _searchInput = null;
                  }
                });
                if (val.isNotEmpty) {
                  _reloadSearch();
                }
              },
            ),
          const SizedBox(height: 10),
          // Loading when finding initial projects
          if (_loading)
            Center(child: SizedBox(height: 80, width: 80, child: Spinner())),
          // No project(s) in provided path
          if (!_loading && projs.isEmpty)
            Center(
              child: Column(
                children: <Widget>[
                  const Text(
                    'No Projects Found',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: 400,
                    child: Text(
                      'You have no projects found. Make sure that you are pointing us towards the correct path.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: customTheme.textTheme.bodyText1!.color),
                    ),
                  ),
                  const SizedBox(height: 15),
                  RectangleButton(
                    onPressed: () {
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        builder: (_) => SettingDialog(goToPage: 'Projects'),
                      );
                    },
                    child: Text(
                      'Edit Path',
                      style: TextStyle(
                        color: customTheme.textTheme.bodyText1!.color,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  currentDirectoryTile(),
                  const SizedBox(height: 10),
                ],
              ),
            )
          // If no search input provided
          else if (_searchInput == null)
            Center(
              child: Column(
                children: <Widget>[
                  const Icon(Iconsdata.search),
                  const SizedBox(height: 15),
                  const Text(
                    'Type Search',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: 400,
                    child: Text(
                      'Search above with keywords included in the project/package name. We will try our best to find matches.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: customTheme.textTheme.bodyText1!.color),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          // No results found
          if (!_loading && _searchInput != null && _searchResults.isEmpty)
            Center(
              child: Column(
                children: <Widget>[
                  const Icon(Icons.error),
                  const SizedBox(height: 15),
                  const Text(
                    'No Matches',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: 400,
                    child: Text(
                      'We couldn\'t seem to find any project/package that matches the search input provided. Try again with another keyword.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: customTheme.textTheme.bodyText1!.color),
                    ),
                  ),
                  const SizedBox(height: 20),
                  currentDirectoryTile(),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          // Show search results
          if (!_loading && _searchInput != null && projs.isNotEmpty)
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _showResults ? _searchResults.length : projs.length,
                itemBuilder: (_, i) {
                  if (_showResults) {
                    return _searchItem(context, _searchResults[i].name,
                        _searchResults[i].modDate);
                  } else {
                    return _searchItem(context, projs[i], projsModDate[i]);
                  }
                },
              ),
            ),
        ],
      ),
    );
  }
}

Widget _searchItem(BuildContext context, String name, String? modDate) {
  ThemeData customTheme = Theme.of(context);
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: RectangleButton(
      width: double.infinity,
      height: 50,
      color: customTheme.buttonColor,
      padding: EdgeInsets.zero,
      onPressed: () {
        showDialog(
          context: context,
          builder: (_) => OpenOptionsDialog(name),
        );
      },
      child: RoundContainer(
        color: Colors.transparent,
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
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    style: TextStyle(
                      color: customTheme.textTheme.bodyText1!.color,
                    ),
                  ),
                  if (modDate != null)
                    Text(
                      modDate,
                      style: TextStyle(
                        fontSize: 12,
                        color: customTheme.textTheme.bodyText1!.color!
                            .withOpacity(0.5),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 15, color: customTheme.iconTheme.color),
          ],
        ),
      ),
    ),
  );
}
