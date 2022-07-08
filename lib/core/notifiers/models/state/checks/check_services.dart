// 📦 Package imports:
import 'package:pub_semver/src/version.dart';

class ServiceCheckResponse {
  final Version? dartVersion;
  final String? dartChannel;

  final Version? flutterVersion;
  final String? flutterChannel;

  final Version? adbVersion;
  final String? adbChannel;

  final Version? vsCodeVersion;
  final String? vsCodeChannel;

  final Version? gitVersion;
  final String? gitChannel;

  final Version? javaVersion;
  final String? javaChannel;

  const ServiceCheckResponse({
    this.dartVersion,
    this.dartChannel,
    this.flutterVersion,
    this.flutterChannel,
    this.adbVersion,
    this.adbChannel,
    this.vsCodeVersion,
    this.vsCodeChannel,
    this.gitVersion,
    this.gitChannel,
    this.javaVersion,
    this.javaChannel,
  });

  factory ServiceCheckResponse.initial() => const ServiceCheckResponse();

  ServiceCheckResponse copyWith({
    Version? dartVersion,
    String? dartChannel,
    Version? flutterVersion,
    String? flutterChannel,
    Version? adbVersion,
    String? adbChannel,
    Version? vsCodeVersion,
    String? vsCodeChannel,
    Version? gitVersion,
    String? gitChannel,
    Version? javaVersion,
    String? javaChannel,
  }) {
    return ServiceCheckResponse(
      dartVersion: dartVersion ?? this.dartVersion,
      dartChannel: dartChannel ?? this.dartChannel,
      flutterVersion: flutterVersion ?? this.flutterVersion,
      flutterChannel: flutterChannel ?? this.flutterChannel,
      adbVersion: adbVersion ?? this.adbVersion,
      adbChannel: adbChannel ?? this.adbChannel,
      vsCodeVersion: vsCodeVersion ?? this.vsCodeVersion,
      vsCodeChannel: vsCodeChannel ?? this.vsCodeChannel,
      gitVersion: gitVersion ?? this.gitVersion,
      gitChannel: gitChannel ?? this.gitChannel,
      javaVersion: javaVersion ?? this.javaVersion,
      javaChannel: javaChannel ?? this.javaChannel,
    );
  }
}
