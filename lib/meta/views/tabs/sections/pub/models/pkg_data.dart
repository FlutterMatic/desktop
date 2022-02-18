// 🎯 Dart imports:
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

// 📦 Package imports:
import 'package:pub_api_client/pub_api_client.dart';

// 🌎 Project imports:
import 'package:fluttermatic/core/services/logs.dart';

class PkgViewData {
  final String name;
  final PubPackage info;
  final PackageMetrics? metrics;
  final PackagePublisher publisher;

  const PkgViewData({
    required this.name,
    required this.info,
    required this.metrics,
    required this.publisher,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'info': info.toJson(),
      'metrics': metrics?.toJson(),
      'publisher': publisher.toJson(),
    };
  }

  static PkgViewData fromJson(Map<String, dynamic> json) {
    try {
      return PkgViewData(
        name: json['name'] as String,
        info: PubPackage.fromJson(json['info'] as Map<String, dynamic>),
        metrics: json['metrics'] != null
            ? PackageMetrics.fromJson(json['metrics'] as Map<String, dynamic>)
            : null,
        publisher: PackagePublisher.fromJson(
            json['publisher'] as Map<String, dynamic>),
      );
    } catch (_, s) {
      logger.file(
          LogTypeTag.error, 'Failed to parse json package: $_, json: $json',
          stackTraces: s);
      rethrow;
    }
  }

  static const int _loadCount = 20;
  static const int _cacheTimeout = 60;
  static final PubClient _pub = PubClient();

  /// Will get the JSON from this URL: https://pub.dev/api/package-name-completion-data
  /// This JSON will contain the list of all pub packages that are available.
  ///
  /// The results will only contain the package name.
  ///
  /// To get the full data about a specific package we need to make a request to
  /// the following URL: https://pub.dev/api/packages/package-name
  ///
  /// Once we get the JSON, we will store it the first time and then use it to
  /// filter the results as the user types.
  /// This is done to avoid making too many requests to the pub API.
  static Future<void> getPackagesIsolate(List<dynamic> data) async {
    SendPort _port = data[0];
    String _path = data[1];

    List<PkgViewData> _pubPackages = <PkgViewData>[];
    File _cache = File(_path + '\\cache\\pub_cache.map.json');

    try {
      if (await _cache.exists()) {
        Map<String, dynamic> _cacheFile =
            jsonDecode(await _cache.readAsString());

        DateTime _time = DateTime.parse(_cacheFile['timestamp']);

        await logger.file(LogTypeTag.info,
            'Fetching pub packages from cache after ${_time.difference(DateTime.now()).inMinutes.abs()} minute(s) since stored.',
            logDir: Directory(_path));

        List<dynamic> _pendingPkg =
            (_cacheFile['packages'] as List<dynamic>).toList();

        _pendingPkg = _pendingPkg.length > _loadCount
            ? _pendingPkg.sublist(0, _loadCount)
            : _pendingPkg;

        for (dynamic pkg in _pendingPkg) {
          File _pkg = File(_path + '\\cache\\packages\\$pkg.json');

          if (await _pkg.exists()) {
            String _pkgInfo = await _pkg.readAsString();
            _pubPackages.add(PkgViewData.fromJson(jsonDecode(_pkgInfo)));
          } else {
            await logger.file(
              LogTypeTag.error,
              'Failed to find package: $pkg in cache, even though declared in cache map.',
              logDir: Directory(_path),
            );
          }
        }

        // Make sure it hasn't been more than an hour since the last time we updated
        // the cache.
        if (_time.difference(DateTime.now()).inMinutes.abs() < _cacheTimeout) {
          GetPkgResponseModel _response = GetPkgResponseModel(
              response: GetPkgResponse.done, packages: _pubPackages);

          // Kill isolate
          _port.send(<dynamic>[_response, true, false]);
          return;
        } else {
          GetPkgResponseModel _response = GetPkgResponseModel(
              response: GetPkgResponse.pending, packages: _pubPackages);

          // Don't kill isolate. Will refetch with cache.
          _port.send(<dynamic>[_response, false, true]);

          await logger.file(
            LogTypeTag.info,
            'Refetching pub packages cache -- cache exists but is stale/expired.',
            logDir: Directory(_path),
          );

          _pubPackages.clear();
        }
      }

      List<String> _search = await PubClient().fetchFlutterFavorites();

      for (String e in _search) {
        if (_search.indexOf(e) >= _loadCount) {
          break;
        }

        PubPackage _info = await _pub.packageInfo(e);
        PackageMetrics? _data = await _pub.packageMetrics(e);
        PackagePublisher _author = await _pub.packagePublisher(e);

        _pubPackages.add(PkgViewData(
          name: e,
          info: _info,
          metrics: _data,
          publisher: _author,
        ));
      }

      // Set the cache after we have loaded the packages.
      await _cache.writeAsString(
        jsonEncode(<String, dynamic>{
          'timestamp': DateTime.now().toIso8601String(),
          'packages': _pubPackages.map((PkgViewData e) => e.name).toList(),
        }),
      );

      // Create the directory for projects if it doesn't exist.
      if (!Directory(_path + '\\cache\\packages').existsSync()) {
        Directory(_path + '\\cache\\packages').createSync(recursive: true);
      }

      // Save it locally as cache for later use.
      for (PkgViewData e in _pubPackages) {
        File _pkg = File(_path + '\\cache\\packages\\${e.name}.json');

        if (await _pkg.exists()) {
          await _pkg.delete();
        }

        await _pkg.writeAsString(jsonEncode(e.toJson()));
      }
      await logger.file(LogTypeTag.info,
          'Added packages ${_pubPackages.map((PkgViewData e) => e.name + ', ')} to cache.',
          logDir: Directory(_path));

      GetPkgResponseModel _response = GetPkgResponseModel(
          response: GetPkgResponse.done, packages: _pubPackages);

      // Kill isolate
      _port.send(<dynamic>[_response, true, false]);
      return;
    } catch (_, s) {
      await logger.file(LogTypeTag.error, 'Failed to fetch pub packages.',
          stackTraces: s, logDir: Directory(_path));

      GetPkgResponseModel _response = GetPkgResponseModel(
          response: GetPkgResponse.error, packages: _pubPackages);

      // Kill isolate
      _port.send(<dynamic>[_response, true, false]);
      return;
    }
  }
}

class GetPkgResponseModel {
  final GetPkgResponse response;
  final List<PkgViewData> packages;

  const GetPkgResponseModel({
    required this.response,
    required this.packages,
  });
}

enum GetPkgResponse {
  done,
  error,
  pending,
  network,
}
