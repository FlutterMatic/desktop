import 'package:flutter/material.dart';
import 'package:flutter_installer/components/widgets/buttons/rectangle_button.dart';
import 'package:flutter_installer/components/widgets/ui/spinner.dart';
import 'package:flutter_installer/services/themes.dart';
import 'package:flutter_installer/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

class ContributersAboutSection extends StatelessWidget {
  final List<ContributerTile> _contributers = [
    ContributerTile('56755783'), // Ziyad Farhan
    ContributerTile('35523357'), // Minnu
  ];
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contributers',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          itemCount: _contributers.length,
          itemBuilder: (_, i) {
            return _contributers[i];
          },
        ),
      ],
    );
  }
}

class ContributerTile extends StatefulWidget {
  final String gitHubId;

  ContributerTile(this.gitHubId);

  @override
  _ContributerTileState createState() => _ContributerTileState();
}

// Utils
bool _loading = true;
bool _failed = false;

// Values
late String _userId;
late String _userName;
late String _profileURL;

class _ContributerTileState extends State<ContributerTile> {
  Future<void> _loadProfile() async {
    Map<String, String> _header = {
      'Content-type': 'application/json',
      'Accept': 'application/json'
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
  void dispose() {
    _loading = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData customTheme = Theme.of(context);
    return _failed
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: RectangleButton(
              onPressed: () => launch('https://www.github.com/$_userId'),
              width: double.infinity,
              height: 65,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              color: currentTheme.isDarkTheme
                  ? kDarkColor
                  : Colors.grey.withOpacity(0.2),
              child: _loading
                  ? Spinner(size: 15, thickness: 2)
                  : Row(
                      children: [
                        CircleAvatar(
                            backgroundImage: NetworkImage('$_profileURL')),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
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
                                    color: customTheme
                                        .textTheme.bodyText1!.color!
                                        .withOpacity(0.7)),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 18,
                          color: customTheme.indicatorColor,
                        ),
                      ],
                    ),
            ),
          );
  }
}
