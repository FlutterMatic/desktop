// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:provider/provider.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants/constants.dart';
import 'package:fluttermatic/components/dialog_templates/other/status.dart';
import 'package:fluttermatic/components/dialog_templates/project/select.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/ui/round_container.dart';
import 'package:fluttermatic/components/widgets/ui/stage_tile.dart';
import 'package:fluttermatic/core/models/projects.model.dart';
import 'package:fluttermatic/core/notifiers/notifications.notifier.dart';
import 'package:fluttermatic/meta/utils/app_theme.dart';
import 'package:fluttermatic/meta/views/dialogs/notifications/notification_view.dart';
import 'package:fluttermatic/meta/views/tabs/sections/projects/elements/search_result_tile.dart';
import 'package:fluttermatic/meta/views/workflows/startup.dart';

class HomeSearchComponent extends StatefulWidget {
  const HomeSearchComponent({Key? key}) : super(key: key);

  @override
  _HomeSearchComponentState createState() => _HomeSearchComponentState();
}

class _HomeSearchComponentState extends State<HomeSearchComponent> {
  final TextEditingController _searchController = TextEditingController();
  // final bool _loadingSearch = false;

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
                      builder: (_) => const SelectProjectTypeDialog(),
                    );
                  },
                ),
              ),
              HSeparators.small(),
              Tooltip(
                message: 'Status',
                waitDuration: const Duration(seconds: 1),
                child: RectangleButton(
                  width: 40,
                  height: 40,
                  child: const Icon(Icons.analytics_rounded, size: 20),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => const StatusDialog(),
                    );
                  },
                ),
              ),
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
                      builder: (_) => const StartUpWorkflow(),
                    );
                  },
                ),
              ),
              HSeparators.small(),
              const _NotificationsButton(),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: _searchResults.isEmpty
                          ? <Widget>[
                              Row(
                                children: <Widget>[
                                  const StageTile(
                                      stageType: StageType.prerelease),
                                  HSeparators.normal(),
                                  const Expanded(
                                    child: Text(
                                        'The search feature is not available yet. You will see this message appear until we provide the feature in a public release.'),
                                  ),
                                ],
                              ),
                              // VSeparators.normal(),
                              // if (_loadingSearch)
                              //   const CustomLinearProgressIndicator(
                              //       includeBox: false)
                              // else
                              //   informationWidget(
                              //     'There are no results for your search query. Try using another term instead.',
                              //     type: InformationType.error,
                              //   ),
                            ]
                          : <Widget>[
                              // TODO: Implement the search.
                              // Search will be able to search multiple FM services.
                              // This means that we need to perform multiple searches
                              // and display the results in a list (merged and sorted
                              // by either importance, relevance, or date).
                              // This needs to be done in an efficient manner in addition
                              // to an isolate implementation.

                              // Show the search results.
                              ..._searchResults.map((ProjectObject e) {
                                double _pad = _searchResults.indexOf(e) ==
                                        _searchResults.length - 1
                                    ? 0
                                    : 5;
                                return Padding(
                                  padding: EdgeInsets.only(bottom: _pad),
                                  child: ProjectSearchResultTile(project: e),
                                );
                              })
                            ],
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

class _NotificationsButton extends StatefulWidget {
  const _NotificationsButton({Key? key}) : super(key: key);

  @override
  State<_NotificationsButton> createState() => _NotificationsButtonState();
}

class _NotificationsButtonState extends State<_NotificationsButton> {
  int _notificationsCount = 0;
  bool _hasNotifications = false;

  Future<void> _reloadOnNotification() async {
    while (mounted) {
      await Future<void>.delayed(const Duration(seconds: 3));

      if (mounted &&
          context.read<NotificationsNotifier>().notifications.isNotEmpty) {
        if (!_hasNotifications && mounted) {
          setState(() => _hasNotifications = true);
        }
      } else {
        if (_hasNotifications && mounted) {
          setState(() => _hasNotifications = false);
        }
      }

      if (mounted &&
          context.read<NotificationsNotifier>().notifications.length !=
              _notificationsCount) {
        setState(() => _notificationsCount =
            context.read<NotificationsNotifier>().notifications.length);
      }
    }
  }

  @override
  void initState() {
    _reloadOnNotification();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: context.read<NotificationsNotifier>().notifications.isEmpty
          ? 'No Notifications'
          : 'Notifications (${context.read<NotificationsNotifier>().notifications.length})',
      waitDuration: const Duration(seconds: 1),
      child: Stack(
        children: <Widget>[
          RectangleButton(
            width: 40,
            height: 40,
            child: Icon(Icons.notifications_outlined,
                color: Colors.yellow[900], size: 20),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => const NotificationViewDialog(),
              );
            },
          ),
          Positioned(
            right: 10,
            top: 10,
            child: AnimatedOpacity(
              opacity: _hasNotifications ? 1 : 0,
              duration: const Duration(milliseconds: 150),
              child: const RoundContainer(
                child: SizedBox.shrink(),
                color: kRedColor,
                radius: 20,
                height: 10,
                width: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
