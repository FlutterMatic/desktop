// 📦 Package imports:
import 'package:pub_semver/src/version.dart';

class ServiceCheckResponse {
  final Version? version;
  final String? channel;

  ServiceCheckResponse({
    required this.version,
    required this.channel,
  });
}
