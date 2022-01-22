// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:provider/provider.dart';

// 🌎 Project imports:
import 'package:fluttermatic/components/dialog_templates/project/new_project.dart';
import 'package:fluttermatic/core/libraries/constants.dart';
import 'package:fluttermatic/core/libraries/models.dart';
import 'package:fluttermatic/core/libraries/notifiers.dart';
import 'package:fluttermatic/core/libraries/widgets.dart';
import 'package:fluttermatic/meta/utils/app_theme.dart';
import 'package:fluttermatic/meta/views/tabs/sections/projects/elements/search_result_tile.dart';
import 'package:fluttermatic/meta/views/workflows/startup.dart';

class HomeSearchComponent extends StatefulWidget {
  const HomeSearchComponent({Key? key}) : super(key: key);

  @override
  _HomeSearchComponentState createState() => _HomeSearchComponentState();
}

class _HomeSearchComponentState extends State<HomeSearchComponent> {
  final TextEditingController _searchController = TextEditingController();
  final bool _loadingSearch = false;

  final FocusNode _searchNode = FocusNode();
  final List<ProjectObject> _searchResults = <ProjectObject>[];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 15, 15, 5),
      child: Stack(
        fit: StackFit.loose,
        children: <Widget>[
          Row(
            children: <Widget>[
              Tooltip(
                message: 'New Project',
                waitDuration: const Duration(seconds: 1),
                child: RectangleButton(
                  width: 40,
                  height: 40,
                  child: const Icon(Icons.add_rounded, size: 20),
                  onPressed: () {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => const NewProjectDialog(),
                    );
                  },
                ),
              ),
              HSeparators.small(),
              const SizedBox(width: 40),
              const Spacer(),
              SizedBox(
                width: (MediaQuery.of(context).size.width > 1000) ? 500 : 400,
                height: 40,
                child: RoundContainer(
                  padding: EdgeInsets.zero,
                  borderColor: Colors.blueGrey.withOpacity(0.2),
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: 8,
                          right: _searchController.text.isEmpty ||
                                  !_searchNode.hasFocus
                              ? 8
                              : 5),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: TextFormField(
                              focusNode: _searchNode,
                              style: TextStyle(
                                color: (Theme.of(context).isDarkTheme
                                        ? Colors.white
                                        : Colors.black)
                                    .withOpacity(0.8),
                              ),
                              cursorRadius: const Radius.circular(5),
                              decoration: InputDecoration(
                                hintStyle: TextStyle(
                                  color: (Theme.of(context).isDarkTheme
                                          ? Colors.white
                                          : Colors.black)
                                      .withOpacity(0.6),
                                  fontSize: 14,
                                ),
                                hintText:
                                    'Search projects, packages, workflows...',
                                border: InputBorder.none,
                                isCollapsed: true,
                              ),
                              controller: _searchController,
                              onChanged: (String val) {
                                setState(() {});
                                // if (val.isEmpty) {
                                //   setState(() => _searchText = val);
                                //   // _startSearch();
                                // } else {
                                //   setState(() => _searchText = val);
                                //   // _startSearch();
                                // }
                              },
                            ),
                          ),
                          HSeparators.xSmall(),
                          if (_searchController.text.isEmpty ||
                              !_searchNode.hasFocus)
                            const Icon(Icons.search_rounded, size: 16)
                          else
                            Tooltip(
                              message: 'Cancel',
                              waitDuration: const Duration(seconds: 1),
                              child: RectangleButton(
                                width: 30,
                                height: 30,
                                padding: const EdgeInsets.all(5),
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 13,
                                  color: Theme.of(context).isDarkTheme
                                      ? Colors.white
                                      : Colors.black,
                                ),
                                onPressed: () {
                                  _searchNode.unfocus();
                                  _searchController.clear();
                                  setState(_searchResults.clear);
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Tooltip(
                message: 'New Workflow',
                waitDuration: const Duration(seconds: 1),
                child: RectangleButton(
                  width: 40,
                  height: 40,
                  child: const Icon(Icons.play_arrow_rounded,
                      size: 20, color: kGreenColor),
                  onPressed: () {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => const StartUpWorkflow(),
                    );
                  },
                ),
              ),
              HSeparators.small(),
              Tooltip(
                message: 'Notifications',
                waitDuration: const Duration(seconds: 1),
                child: RectangleButton(
                  width: 40,
                  height: 40,
                  child: Icon(
                    Icons.notifications_outlined,
                    size: 20,
                    color: context.read<ThemeChangeNotifier>().isDarkTheme
                        ? kYellowColor
                        : Colors.yellow[900],
                  ),
                  // TODO: Show notifications.
                  onPressed: () {},
                ),
              ),
            ],
          ),
          // Show the search results in realtime if the user has typed
          // anything to search for.
          if (_searchController.text.isNotEmpty)
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 50),
                child: Container(
                  constraints: const BoxConstraints(
                    maxWidth: 500,
                    maxHeight: 300,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).isDarkTheme
                        ? const Color(0xff262F34)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: Colors.blueGrey.withOpacity(0.4),
                    ),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: _searchResults.isEmpty
                          ? <Widget>[
                              if (_loadingSearch)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: LinearProgressIndicator(
                                    backgroundColor:
                                        Colors.blue.withOpacity(0.1),
                                  ),
                                )
                              else
                                informationWidget(
                                  'There are no results for your search query. Try using another term instead.',
                                  type: InformationType.error,
                                ),
                            ]
                          : _searchResults.map((ProjectObject e) {
                              double _pad = _searchResults.indexOf(e) ==
                                      _searchResults.length - 1
                                  ? 0
                                  : 5;
                              return Padding(
                                padding: EdgeInsets.only(bottom: _pad),
                                child: ProjectSearchResultTile(project: e),
                              );
                            }).toList(),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
