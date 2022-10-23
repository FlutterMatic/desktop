// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path_provider/path_provider.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants.dart';
import 'package:fluttermatic/components/dialog_templates/other/status.dart';
import 'package:fluttermatic/components/dialog_templates/project/create_select.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/ui/load_activity_msg.dart';
import 'package:fluttermatic/components/widgets/ui/round_container.dart';
import 'package:fluttermatic/components/widgets/ui/spinner.dart';
import 'package:fluttermatic/core/notifiers/models/state/general/search.dart';
import 'package:fluttermatic/core/notifiers/models/state/general/theme.dart';
import 'package:fluttermatic/core/notifiers/notifiers/general/notifications.dart';
import 'package:fluttermatic/core/notifiers/notifiers/general/search.dart';
import 'package:fluttermatic/core/notifiers/out.dart';
import 'package:fluttermatic/core/services/logs.dart';
import 'package:fluttermatic/meta/views/dialogs/notifications/notification_view.dart';
import 'package:fluttermatic/meta/views/tabs/search/elements/package.dart';
import 'package:fluttermatic/meta/views/tabs/search/elements/projects.dart';
import 'package:fluttermatic/meta/views/tabs/search/elements/workflows.dart';
import 'package:fluttermatic/meta/views/workflows/startup.dart';

class HomeSearchComponent extends ConsumerStatefulWidget {
  const HomeSearchComponent({Key? key}) : super(key: key);

  @override
  _HomeSearchComponentState createState() => _HomeSearchComponentState();
}

class _HomeSearchComponentState extends ConsumerState<HomeSearchComponent> {
  // Inputs
  final TextEditingController _searchController = TextEditingController();

  final FocusNode _searchNode = FocusNode();

  String? _path;

  // Search will be able to search multiple FM services. This means that we
  // need to perform multiple searches and display the results in a list
  // (merged and sorted by either importance, relevance, or date).
  //
  // This needs to be done in an efficient manner.
  Future<void> _search() async {
    try {
      _path ??= (await getApplicationSupportDirectory()).path;

      if (_searchController.text.isEmpty) {
        ref.watch(appSearchStateNotifier.notifier).resetSearch();
        return;
      }

      // Wait a duration before starting the search. Make sure that the search
      // query before and after didn't change to avoid unnecessary searches.
      String before = _searchController.text;

      await Future<void>.delayed(const Duration(milliseconds: 200));

      // Ensure that we are still in the same search query.
      if (before != _searchController.text) {
        return;
      }

      await ref
          .watch(appSearchStateNotifier.notifier)
          .search(_searchController.text)
          .timeout(const Duration(seconds: 5), onTimeout: () {});
    } catch (e, s) {
      await logger.file(LogTypeTag.error,
          'Failed to search in main component. Maybe a search timeout exceeded?',
          error: e, stackTrace: s);
    }
  }

  @override
  void dispose() {
    _searchNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (_, ref, __) {
        ThemeState themeState = ref.watch(themeStateController);

        NotificationsNotifier notificationsNotifier =
            ref.watch(notificationStateController.notifier);

        AppSearchState appSearchState = ref.watch(appSearchStateNotifier);
        AppSearchNotifier appSearchNotifier =
            ref.watch(appSearchStateNotifier.notifier);

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
                    width:
                        (MediaQuery.of(context).size.width > 1000) ? 500 : 400,
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
                                  enabled:
                                      appSearchState.currentActivity.isEmpty,
                                  focusNode: _searchNode,
                                  style: TextStyle(
                                    color: (themeState.darkTheme
                                            ? Colors.white
                                            : Colors.black)
                                        .withOpacity(0.8),
                                  ),
                                  cursorRadius: const Radius.circular(5),
                                  decoration: InputDecoration(
                                    hintStyle: TextStyle(
                                      color: (themeState.darkTheme
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
                                  onChanged: (_) => _search(),
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
                                      color: themeState.darkTheme
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                    onPressed: () {
                                      _searchNode.unfocus();
                                      _searchController.clear();

                                      appSearchNotifier.resetSearch();
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
                  Tooltip(
                    message: notificationsNotifier.notifications.isEmpty
                        ? 'No Notifications'
                        : 'Notifications (${notificationsNotifier.notifications.length})',
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
                            opacity:
                                notificationsNotifier.notifications.isNotEmpty
                                    ? 1
                                    : 0,
                            duration: const Duration(milliseconds: 150),
                            child: const RoundContainer(
                              color: kRedColor,
                              radius: 20,
                              height: 10,
                              width: 10,
                              child: SizedBox.shrink(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Show the search results in realtime if the user has typed
              // anything to search for.
              Builder(
                builder: (_) {
                  if (_searchController.text.isNotEmpty) {
                    return Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 50),
                        child: Container(
                          width: 500,
                          constraints: const BoxConstraints(
                            maxWidth: 500,
                            maxHeight: 500,
                          ),
                          decoration: BoxDecoration(
                            color: themeState.darkTheme
                                ? const Color(0xff262F34)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                                color: Colors.blueGrey.withOpacity(0.4)),
                          ),
                          child: SingleChildScrollView(
                            key: const ValueKey<String>('search-results'),
                            child: Builder(
                              builder: (_) {
                                if (appSearchState.currentActivity.isNotEmpty) {
                                  return LoadActivityMessageElement(
                                      message: appSearchState.currentActivity);
                                } else {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (appSearchNotifier
                                          .projects.isNotEmpty) ...<Widget>[
                                        const Padding(
                                          padding: EdgeInsets.only(
                                              left: 10, right: 10, top: 10),
                                          child: Text(
                                            'Projects',
                                            style: TextStyle(fontSize: 18),
                                          ),
                                        ),
                                        VSeparators.small(),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 10),
                                          child: SizedBox(
                                            height: 150,
                                            child: ListView.builder(
                                              shrinkWrap: true,
                                              scrollDirection: Axis.horizontal,
                                              key: const ValueKey<String>(
                                                  'project-list'),
                                              itemCount: appSearchNotifier
                                                  .projects.length,
                                              itemBuilder: (_, int i) {
                                                return SearchProjectTile(
                                                  project: appSearchNotifier
                                                      .projects[i],
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                      if (appSearchNotifier
                                          .workflows.isNotEmpty)
                                        ...appSearchNotifier.workflows.map(
                                          (e) {
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 10),
                                              child: SearchWorkflowsTile(
                                                  workflow: e),
                                            );
                                          },
                                        ),
                                      if (appSearchState.loading &&
                                          appSearchNotifier.packages.isEmpty)
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(
                                              10,
                                              <dynamic>[
                                                ...appSearchNotifier.projects,
                                                ...appSearchNotifier.workflows,
                                                ...appSearchNotifier.packages
                                              ].isEmpty
                                                  ? 10
                                                  : 0,
                                              10,
                                              10),
                                          child:
                                              const LoadActivityMessageElement(
                                                  message:
                                                      'Searching Pub packages'),
                                        )
                                      else if (!appSearchState.loading &&
                                          appSearchNotifier.packages.isEmpty)
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(
                                              10,
                                              appSearchNotifier
                                                      .mergedResults.isEmpty
                                                  ? 10
                                                  : 0,
                                              10,
                                              10),
                                          child: RoundContainer(
                                            child: Row(
                                              children: <Widget>[
                                                SvgPicture.asset(Assets.package,
                                                    color: themeState.darkTheme
                                                        ? Colors.white
                                                        : Colors.blueGrey,
                                                    height: 20),
                                                HSeparators.xSmall(),
                                                const Text(
                                                    'No packages found with your search query.'),
                                              ],
                                            ),
                                          ),
                                        ),
                                      if (appSearchNotifier
                                          .packages.isNotEmpty) ...<Widget>[
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 10, right: 10, top: 10),
                                          child: Row(
                                            children: <Widget>[
                                              const Expanded(
                                                child: Text('Pub Packages',
                                                    style: TextStyle(
                                                        fontSize: 18)),
                                              ),
                                              if (appSearchState.loading)
                                                const Spinner(
                                                    size: 14, thickness: 2),
                                            ],
                                          ),
                                        ),
                                        VSeparators.small(),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 10),
                                          child: SizedBox(
                                            height: 150,
                                            child: ListView.builder(
                                              shrinkWrap: true,
                                              scrollDirection: Axis.horizontal,
                                              key: const ValueKey<String>(
                                                  'package-list'),
                                              itemCount: appSearchNotifier
                                                  .packages.length,
                                              itemBuilder: (_, int i) {
                                                return SearchPackageTile(
                                                  package: ref
                                                      .watch(
                                                          appSearchStateNotifier
                                                              .notifier)
                                                      .packages[i],
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
