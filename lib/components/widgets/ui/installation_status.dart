// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_svg/flutter_svg.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants.dart';
import 'package:fluttermatic/components/widgets/buttons/square_button.dart';

class InstallationStatusTile extends StatelessWidget {
  final InstallationStatus status;
  final String title;
  final String description;
  final String tooltip;
  final Function() onDownload;

  const InstallationStatusTile({
    Key? key,
    required this.status,
    required this.title,
    required this.description,
    required this.tooltip,
    required this.onDownload,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              SvgPicture.asset(
                status == InstallationStatus.done
                    ? Assets.done
                    : status == InstallationStatus.warning
                        ? Assets.warn
                        : Assets.error,
                height: 20,
              ),
              HSeparators.small(),
              Text(
                title,
                style: const TextStyle(fontSize: 16),
              ),
              const Spacer(),
              if (status != InstallationStatus.done)
                SquareButton(
                  size: 35,
                  color: Colors.transparent,
                  icon: const Icon(Icons.download_rounded, size: 20),
                  tooltip: 'Download $tooltip',
                  onPressed: onDownload,
                ),
            ],
          ),
          if (status == InstallationStatus.error ||
              status == InstallationStatus.warning)
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 3,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: status == InstallationStatus.error
                          ? kRedColor
                          : kYellowColor,
                    ),
                    height: 40,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SelectableText(
                      description,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

enum InstallationStatus { done, warning, error }
