import 'package:flutter/material.dart';
import 'package:flutter_installer/components/dialog_templates/dialog_header.dart';
import 'package:flutter_installer/components/widgets/dialog_template.dart';
import 'package:flutter_installer/components/widgets/round_container.dart';
import 'package:flutter_installer/components/widgets/text_field.dart';
import 'package:flutter_installer/utils/constants.dart';

class SearchProjectsDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ThemeData customTheme = Theme.of(context);
    return DialogTemplate(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DialogHeader(title: 'Search Projects'),
          const SizedBox(height: 20),
          RoundContainer(
            color: Colors.blueGrey.withOpacity(0.2),
            radius: 5,
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Current Directory',
                    style: TextStyle(fontWeight: FontWeight.w600),),
                const SizedBox(height: 10),
                Text(projDir!),
              ],
            ),
          ),
          const SizedBox(height: 10),
          CustomTextField(
            hintText: 'Search',
            suffixIcon: Icon(Icons.search_rounded,
                color: customTheme.textTheme.bodyText1!.color),
            onChanged: (val) {},
          ),
        ],
      ),
    );
  }
}
