import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:manager/components/widgets/buttons/rectangle_button.dart';
import 'package:manager/components/widgets/ui/round_container.dart';
import 'package:manager/components/widgets/ui/spinner.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

bool _failedRequest = false;

final List<ContributorTile> _contributors = <ContributorTile>[
  const ContributorTile('56755783'), // Ziyad Farhan
  const ContributorTile('35523357'), // Minnu
];

class ContributorsAboutSection extends StatelessWidget {
  const ContributorsAboutSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData customTheme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Contributors',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        if (_failedRequest)
          RoundContainer(
            color: customTheme.focusColor,
            width: double.infinity,
            child: Column(
              children: <Widget>[
                const SizedBox(height: 5),
                const Icon(Icons.lock),
                const SizedBox(height: 15),
                const Text(
                  'Reloaded Too Many Times',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                const Text(
                  'It seems that you have reloaded this page way too many times. Try again in about an hour.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
              ],
            ),
          )
        else
          Column(
              children: _contributors.map((ContributorTile e) => (e)).toList()),
        const SizedBox(height: 10),
        RoundContainer(
          width: double.infinity,
          color: customTheme.focusColor,
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Want to contribute?',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                        'We appreciate people like you to contribute to this project.'),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              RectangleButton(
                hoverColor: customTheme.hoverColor,
                width: 90,
                // TODO(yahu1031): Launch to the GitHub page for contributions.
                onPressed: () => launch(''),
                child: Text(
                  'Get Started',
                  style:
                      TextStyle(color: customTheme.textTheme.bodyText1!.color),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ContributorTile extends StatefulWidget {
  final String gitHubId;

  const ContributorTile(this.gitHubId, {Key? key}) : super(key: key);

  @override
  _ContributorTileState createState() => _ContributorTileState();
}

// Utils
bool _loading = true;
bool _failed = false;

// Values
late String _userId;
late String _userName;
late String _profileURL;

class _ContributorTileState extends State<ContributorTile> {
  Future<void> _loadProfile() async {
    Map<String, String> _header = <String, String>{
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };

    http.Response _result = await http.get(
      Uri.parse('https://api.github.com/user/${widget.gitHubId}'),
      headers: _header,
    );
    if (_result.statusCode == 200) {
      dynamic _responseJSON = json.decode(_result.body);
      setState(() {
        _userId = _responseJSON['login'];
        _userName = _responseJSON['name'];
        _profileURL = _responseJSON['avatar_url'];
        _failed = false;
        _loading = false;
      });
    } else {
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
          onPressed: () => launch('https://www.github.com/$_userId'),
          width: double.infinity,
          height: 65,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: _loading
              ? Spinner(size: 15, thickness: 2)
              : Row(
                  children: <Widget>[
                    CircleAvatar(backgroundImage: NetworkImage(_profileURL)),
                    const SizedBox(width: 10),
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
                          const SizedBox(height: 5),
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
