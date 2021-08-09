import 'package:flutter/material.dart';
import 'package:manager/app/constants/constants.dart';
import 'package:manager/components/dialog_templates/dialog_header.dart';
import 'package:manager/components/dialog_templates/projects/open_options.dart';
import 'package:manager/components/dialog_templates/settings/settings.dart';
import 'package:manager/components/widgets/buttons/rectangle_button.dart';
import 'package:manager/components/widgets/inputs/text_field.dart';
import 'package:manager/components/widgets/ui/current_directory.dart';
import 'package:manager/components/widgets/ui/dialog_template.dart';
import 'package:manager/components/widgets/ui/round_container.dart';
import 'package:manager/components/widgets/ui/snackbar_tile.dart';
import 'package:manager/components/widgets/ui/spinner.dart';
import 'package:manager/core/models/projects.model.dart';

class SearchProjectsDialog extends StatefulWidget {
  @override
  _SearchProjectsDialogState createState() => _SearchProjectsDialogState();
}

class _SearchProjectsDialogState extends State<SearchProjectsDialog> {
  bool _loading = true;
  bool _showResults = false;
  String? _searchInput;

  final List<ProjectsModel> _searchResults = <ProjectsModel>[];

  Future<void> _loadProjects() async {
    setState(() => _loading = true);
    try {
      // TODO: Load the projects to begin the search.
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
    for (int i = 0; i < projs.length; i++) {
      String _itemValue = projs[i];
      if (_itemValue.toLowerCase().contains(_searchInput!)) {
        _searchResults.add(
          ProjectsModel(
            name: projs[i],
            modDate: projsModDate[i],
            // TODO: Specify the project path.
            path: '',
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
  Widget build(BuildContext context) {
    ThemeData customTheme = Theme.of(context);
    return DialogTemplate(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          DialogHeader(title: 'Search Projects'),
          const SizedBox(height: 20),
          if (!_loading && projs.isNotEmpty)
            CustomTextField(
              hintText: 'Search',
              autofocus: true,
              onChanged: (String val) {
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
                  const Icon(Icons.search_rounded),
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
                itemBuilder: (_, int i) {
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
            const Icon(Icons.folder_rounded, color: kGreenColor),
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
