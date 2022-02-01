// 🎯 Dart imports:
import 'dart:convert';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants/constants.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/ui/round_container.dart';
import 'package:fluttermatic/components/widgets/ui/spinner.dart';
import 'package:fluttermatic/components/widgets/ui/tab_view.dart';

bool _failedRequest = false;

class ContributorsAboutSection extends StatefulWidget {
  const ContributorsAboutSection({Key? key}) : super(key: key);

  @override
  _ContributorsAboutSectionState createState() =>
      _ContributorsAboutSectionState();
}

class _ContributorsAboutSectionState extends State<ContributorsAboutSection> {
  static const List<_ContributorTile> _contributors = <_ContributorTile>[
    _ContributorTile('56755783'), // Ziyad
    _ContributorTile('35523357'), // Minnu
  ];

  @override
  Widget build(BuildContext context) {
    return TabViewTabHeadline(
      title: 'Contributors',
      content: <Widget>[
        RoundContainer(
          width: double.infinity,
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text('Want to contribute?'),
                    VSeparators.xSmall(),
                    const Text(
                      'We appreciate people like you to contribute to this project.',
                      style: TextStyle(fontSize: 13.5),
                    ),
                  ],
                ),
              ),
              HSeparators.small(),
              RectangleButton(
                width: 90,
                onPressed: () =>
                    launch('https://github.com/FlutterMatic/desktop'),
                child: const Text('Get Started'),
              ),
            ],
          ),
        ),
        VSeparators.xSmall(),
        if (_failedRequest)
          RoundContainer(
            width: double.infinity,
            child: Column(
              children: <Widget>[
                VSeparators.xSmall(),
                const Icon(Icons.lock),
                VSeparators.normal(),
                const Text(
                  'Reloaded Too Many Times',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                VSeparators.small(),
                const Text(
                  'It seems that you have reloaded this page way too many times. Try again in about an hour.',
                  textAlign: TextAlign.center,
                ),
                VSeparators.small(),
              ],
            ),
          )
        else
          Column(children: _contributors),
      ],
    );
  }
}

// Will get the contributor user information from the GitHub api and return
// a widget that displays the information.
class _ContributorTile extends StatefulWidget {
  final String gitHubId;

  const _ContributorTile(this.gitHubId, {Key? key}) : super(key: key);

  @override
  _ContributorTileState createState() => _ContributorTileState();
}

class _ContributorTileState extends State<_ContributorTile> {
  // Utils
  bool _loading = true;
  bool _failed = false;

  // Values
  late String _userId;
  late String _userName;
  late String _profileURL;

  Future<void> _loadProfile() async {
    Map<String, String> _header = <String, String>{
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };

    http.Response _result = await http.get(
      Uri.parse('https://api.github.com/user/${widget.gitHubId}'),
      headers: _header,
    );

    if (_result.statusCode == 200 && mounted) {
      dynamic _responseJSON = json.decode(_result.body);
      setState(() {
        _userId = _responseJSON['login'];
        _userName = _responseJSON['name'];
        _profileURL = _responseJSON['avatar_url'];
        _failed = false;
        _loading = false;
      });
    } else if (mounted) {
      setState(() {
        _failedRequest = true;
        _failed = true;
        _loading = false;
      });
    }
  }

  @override
  void initState() {
    _loadProfile();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) {
      return const SizedBox.shrink();
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: RectangleButton(
          height: 65,
          width: double.infinity,
          color: Colors.blueGrey.withOpacity(0.1),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          onPressed: () => launch('https://www.github.com/$_userId'),
          child: Builder(
            builder: (_) {
              if (_loading) {
                return const Spinner(size: 15, thickness: 2);
              } else {
                return Row(
                  children: <Widget>[
                    CircleAvatar(
                      backgroundImage: NetworkImage(_profileURL, scale: 5),
                      backgroundColor: Colors.blueGrey,
                    ),
                    HSeparators.small(),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(_userName),
                          VSeparators.xSmall(),
                          Text('GitHub: ' + _userId,
                              style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 18),
                  ],
                );
              }
            },
          ),
        ),
      );
    }
  }
}
