// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:manager/core/libraries/constants.dart';
import 'package:manager/core/libraries/models.dart';
import 'package:manager/core/libraries/utils.dart';
import 'package:manager/core/libraries/views.dart';
import 'package:manager/core/libraries/widgets.dart';
import 'package:manager/meta/views/workflows/startup.dart';

class HomeProjectsSection extends StatefulWidget {
  const HomeProjectsSection({Key? key}) : super(key: key);

  @override
  _HomeProjectsSectionState createState() => _HomeProjectsSectionState();
}

class _HomeProjectsSectionState extends State<HomeProjectsSection> {
  String _searchText = '';

  final bool _loadingSearch = false;

  static const int _buttonsOnRight = 1;

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
                      const SizedBox(
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
                                      color: (Theme.of(context).isDarkTheme
                                              ? Colors.white
                                              : Colors.black)
                                          .withOpacity(0.8),
                                    ),
                                    cursorRadius: const Radius.circular(5),
                                    decoration: InputDecoration(
                                      hintStyle: TextStyle(
                                        color: Colors.grey.withOpacity(0.8),
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
                                      color: Theme.of(context).isDarkTheme
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                    onPressed: () {},
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    RectangleButton(
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
        Padding(
          padding: const EdgeInsets.only(top: 70),
          child: Column(
            children: <Widget>[],
          ),
        )
      ],
    );
  }
}
