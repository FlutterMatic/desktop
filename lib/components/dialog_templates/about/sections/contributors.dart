// 🎯 Dart imports:
import 'dart:convert';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

// 🌎 Project imports:
import 'package:manager/app/constants/constants.dart';
import 'package:manager/core/libraries/widgets.dart';

bool _failedRequest = false;

class ContributorsAboutSection extends StatefulWidget {
  const ContributorsAboutSection({Key? key}) : super(key: key);

  @override
  _ContributorsAboutSectionState createState() =>
      _ContributorsAboutSectionState();
}

class _ContributorsAboutSectionState extends State<ContributorsAboutSection> {
  @override
  Widget build(BuildContext context) {
    ThemeData customTheme = Theme.of(context);
    return TabViewTabHeadline(
      title: 'Contributors',
      content: <Widget>[
        RoundContainer(
          width: double.infinity,
          color: customTheme.colorScheme.secondary.withOpacity(0.2),
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
                color: customTheme.colorScheme.secondary.withOpacity(0.2),
                hoverColor: customTheme.hoverColor,
                width: 90,
                onPressed: () => launch(
                    'https://github.com/FlutterMatic/FlutterMatic-desktop'),
                child: Text(
                  'Get Started',
                  style:
                      TextStyle(color: customTheme.textTheme.bodyText1!.color),
                ),
              ),
            ],
          ),
        ),
        VSeparators.xSmall(),
        if (_failedRequest)
          RoundContainer(
            color: customTheme.colorScheme.secondary.withOpacity(0.2),
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
          Column(
            children: const <Widget>[
              ContributorTile('35523357'), // Minnu
              ContributorTile('56755783'), // Ziyad
            ],
          ),
      ],
    );
  }
}

// Just trying to get the data from the github api.

class ContributorTile extends StatefulWidget {
  final String gitHubId;

  const ContributorTile(this.gitHubId, {Key? key}) : super(key: key);

  @override
  _ContributorTileState createState() => _ContributorTileState();
}

class _ContributorTileState extends State<ContributorTile> {
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
    ThemeData customTheme = Theme.of(context);
    if (_failed) {
      return const SizedBox.shrink();
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: RectangleButton(
          height: 65,
          width: double.infinity,
          color: customTheme.colorScheme.secondary.withOpacity(0.2),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          onPressed: () => launch('https://www.github.com/$_userId'),
          child: _loading
              ? const Spinner(size: 15, thickness: 2)
              : Row(
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
                          Text(
                            _userName,
                            style: TextStyle(
                              color: customTheme.textTheme.bodyText1!.color,
                            ),
                          ),
                          VSeparators.xSmall(),
                          Text(
                            'GitHub: ' + _userId,
                            style: TextStyle(
                                color: customTheme.textTheme.bodyText1!.color!
                                    .withOpacity(0.7)),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded,
                        color: customTheme.indicatorColor, size: 18),
                  ],
                ),
        ),
      );
    }
  }
}
