import 'package:flutter/material.dart';
import 'package:manager/app/constants/constants.dart';
import 'package:manager/components/dialog_templates/dialog_header.dart';
import 'package:manager/components/widgets/ui/dialog_template.dart';
import 'package:manager/components/widgets/ui/markdown_view.dart';
import 'package:manager/components/widgets/ui/warning_widget.dart';
import 'package:manager/core/libraries/notifiers.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class PubPackageDialog extends StatefulWidget {
  const PubPackageDialog({Key? key}) : super(key: key);

  @override
  State<PubPackageDialog> createState() => _PubPackageDialogState();
}

class _PubPackageDialogState extends State<PubPackageDialog> {
  String? _data;
  bool _hasReadme = true;

  Future<void> _loadData() async {
    try {
      http.Response _response = await http.get(
        Uri.parse(
            'https://raw.githubusercontent.com/flutter/plugins/master/packages/shared_preferences/shared_preferences/README.md'),
      );
      setState(() {
        if (_response.statusCode == 200) {
          _data = _response.body;
        } else {
          _hasReadme = false;
        }
      });
    } catch (_) {
      setState(() => _hasReadme = false);
    }
  }

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DialogTemplate(
      width: 800,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const DialogHeader(title: 'Pub Package'),
          const Text('Pub package'),
          VSeparators.normal(),
          ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: 500,
              maxWidth: 500,
              maxHeight: 450,
            ),
            child: Builder(
              builder: (BuildContext context) {
                try {
                  if (!_hasReadme) {
                    return informationWidget(
                      'Seems like this package doesn\'t have a README.md file.',
                      type: InformationType.error,
                    );
                  } else if (_data == null) {
                    return Container(
                      constraints:
                          const BoxConstraints(maxWidth: 500, maxHeight: 300),
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
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: LinearProgressIndicator(
                          backgroundColor: Colors.blue.withOpacity(0.1),
                        ),
                      ),
                    );
                  } else {
                    return SingleChildScrollView(
                      child: MarkdownBlock(
                        data: _data,
                        wrapWithBox: false,
                        shrinkView: true,
                      ),
                    );
                  }
                } catch (_) {
                  return informationWidget(
                    'We found a README.md for this package. However, we are not able to display if for you at the moment.',
                    type: InformationType.warning,
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
