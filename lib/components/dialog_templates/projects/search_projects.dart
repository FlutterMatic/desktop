// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:manager/app/constants/constants.dart';
import 'package:manager/components/dialog_templates/dialog_header.dart';
import 'package:manager/components/dialog_templates/projects/open_options.dart';
import 'package:manager/components/dialog_templates/settings/settings.dart';
import 'package:manager/core/libraries/widgets.dart';
import 'package:manager/core/models/projects.model.dart';

class SearchProjectsDialog extends StatefulWidget {
  const SearchProjectsDialog({Key? key}) : super(key: key);

  @override
  _SearchProjectsDialogState createState() => _SearchProjectsDialogState();
}

class _SearchProjectsDialogState extends State<SearchProjectsDialog> {
  bool _loading = true;
  bool _showResults = false;
  String? _searchInput;

  final List<ProjectObject> _searchResults = <ProjectObject>[];

  Future<void> _loadProjects() async {
    setState(() => _loading = true);
    try {
      // TODO: Load the projects to begin the search.
    } catch (_) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        snackBarTile(
          context,
          'Unable to load projects',
          type: SnackBarType.error,
        ),
      );
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
          ProjectObject(
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
          const DialogHeader(title: 'Search Projects'),
          VSeparators.large(),
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
          VSeparators.small(),
          // Loading when finding initial projects
          if (_loading)
            const Center(
                child: SizedBox(height: 80, width: 80, child: Spinner())),
          // No project(s) in provided path
          if (!_loading && projs.isEmpty)
            Center(
              child: Column(
                children: <Widget>[
                  const Text(
                    'No Projects Found',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  VSeparators.small(),
                  SizedBox(
                    width: 400,
                    child: Text(
                      'You have no projects found. Make sure that you are pointing us towards the correct path.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: customTheme.textTheme.bodyText1!.color),
                    ),
                  ),
                  VSeparators.normal(),
                  RectangleButton(
                    onPressed: () {
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        builder: (_) =>
                            const SettingDialog(goToPage: 'Projects'),
                      );
                    },
                    child: Text(
                      'Edit Path',
                      style: TextStyle(
                        color: customTheme.textTheme.bodyText1!.color,
                      ),
                    ),
                  ),
                  VSeparators.large(),
                  currentDirectoryTile(),
                  VSeparators.small(),
                ],
              ),
            )
          // If no search input provided
          else if (_searchInput == null)
            Center(
              child: Column(
                children: <Widget>[
                  const Icon(Icons.search_rounded),
                  VSeparators.normal(),
                  const Text(
                    'Type Search',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  VSeparators.small(),
                  SizedBox(
                    width: 400,
                    child: Text(
                      'Search above with keywords included in the project/package name. We will try our best to find matches.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: customTheme.textTheme.bodyText1!.color),
                    ),
                  ),
                  VSeparators.small(),
                ],
              ),
            ),
          // No results found
          if (!_loading && _searchInput != null && _searchResults.isEmpty)
            Center(
              child: Column(
                children: <Widget>[
                  const Icon(Icons.error),
                  VSeparators.normal(),
                  const Text(
                    'No Matches',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  VSeparators.small(),
                  SizedBox(
                    width: 400,
                    child: Text(
                      'We couldn\'t seem to find any project/package that matches the search input provided. Try again with another keyword.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: customTheme.textTheme.bodyText1!.color),
                    ),
                  ),
                  VSeparators.large(),
                  currentDirectoryTile(),
                  VSeparators.small(),
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
            HSeparators.small(),
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
            HSeparators.small(),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 15, color: customTheme.iconTheme.color),
          ],
        ),
      ),
    ),
  );
}
