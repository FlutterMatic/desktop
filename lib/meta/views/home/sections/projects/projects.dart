import 'package:flutter/material.dart';
import 'package:manager/app/constants/constants.dart';
import 'package:manager/components/widgets/ui/warning_widget.dart';
import 'package:manager/components/widgets/ui/round_container.dart';
import 'package:manager/components/widgets/buttons/rectangle_button.dart';
import 'package:manager/meta/views/home/sections/projects/element/search_result_tile.dart';
import 'package:manager/core/models/projects.model.dart';
import 'package:manager/core/libraries/notifiers.dart';
import 'package:provider/provider.dart';

class HomeProjectsSection extends StatefulWidget {
  const HomeProjectsSection({Key? key}) : super(key: key);

  @override
  _HomeProjectsSectionState createState() => _HomeProjectsSectionState();
}

class _HomeProjectsSectionState extends State<HomeProjectsSection> {
  String _searchText = '';

  bool _loadingSearch = false;

  static final int _buttonsOnRight = 0;

  final FocusNode _searchNode = FocusNode();

  List<ProjectObject> _searchResults = <ProjectObject>[
    const ProjectObject(name: 'Ok', path: '123'),
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Column(
          children: <Widget>[
            VSeparators.normal(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Center(
                child: Row(
                  children: <Widget>[
                    if (_buttonsOnRight > 0)
                      SizedBox(
                        width: (40 * _buttonsOnRight) +
                            ((_buttonsOnRight - 1) * 10),
                      ),
                    const Spacer(),
                    SizedBox(
                      width: (MediaQuery.of(context).size.width > 1000)
                          ? 500
                          : 400,
                      height: 40,
                      child: RoundContainer(
                        padding: EdgeInsets.zero,
                        borderColor: Colors.blueGrey.withOpacity(0.2),
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: 8,
                                right:
                                    _searchText == '' || !_searchNode.hasFocus
                                        ? 8
                                        : 5),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: TextFormField(
                                    focusNode: _searchNode,
                                    style: TextStyle(
                                      color: (context
                                                  .read<ThemeChangeNotifier>()
                                                  .isDarkTheme
                                              ? Colors.white
                                              : Colors.black)
                                          .withOpacity(0.8),
                                    ),
                                    cursorRadius: const Radius.circular(5),
                                    decoration: InputDecoration(
                                      hintStyle: TextStyle(
                                        color: (context
                                                    .read<ThemeChangeNotifier>()
                                                    .isDarkTheme
                                                ? Colors.white
                                                : Colors.black)
                                            .withOpacity(0.6),
                                        fontSize: 14,
                                      ),
                                      hintText: 'Search Projects',
                                      border: InputBorder.none,
                                      isCollapsed: true,
                                    ),
                                    onFieldSubmitted: (String? val) {
                                      // Show a page with all the results.
                                    },
                                    onChanged: (String val) {
                                      if (val.isEmpty) {
                                        setState(() {
                                          _searchText = val;
                                          _searchResults = <ProjectObject>[];
                                        });
                                      } else {
                                        setState(() => _searchText = val);
                                        // _updateResults();
                                      }
                                    },
                                  ),
                                ),
                                HSeparators.xSmall(),
                                if (_searchText == '' || !_searchNode.hasFocus)
                                  const Icon(Icons.search_rounded, size: 16)
                                else
                                  RectangleButton(
                                    width: 30,
                                    height: 30,
                                    padding: const EdgeInsets.all(5),
                                    child: Icon(
                                      Icons.close_rounded,
                                      size: 13,
                                      color: context
                                              .read<ThemeChangeNotifier>()
                                              .isDarkTheme
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                    onPressed: () {
                                      // _searchNode.unfocus();
                                      // setState(() {
                                      //   _searchResults = <PubPackageObject>[];
                                      //   _searchText = '';
                                      // });
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ],
        ),
        // Show the search results in realtime if the user has typed anything
        // to search for.
        if (_searchText != '')
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 60),
              child: Container(
                constraints: const BoxConstraints(
                  maxWidth: 500,
                  maxHeight: 300,
                ),
                decoration: BoxDecoration(
                  color: context.read<ThemeChangeNotifier>().isDarkTheme
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
                                  backgroundColor: Colors.blue.withOpacity(0.1),
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
    );
  }
}
