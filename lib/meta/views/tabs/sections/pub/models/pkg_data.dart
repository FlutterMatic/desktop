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
    SendPort port = data[0];
    String path = data[1];

    List<PkgViewData> pubPackages = <PkgViewData>[];
    File cache = File('$path\\cache\\pub_cache.map.json');

    try {
      if (await cache.exists()) {
        Map<String, dynamic> cacheFile = jsonDecode(await cache.readAsString());

        DateTime time = DateTime.parse(cacheFile['timestamp']);

        await logger.file(LogTypeTag.info,
            'Fetching pub packages from cache after ${time.difference(DateTime.now()).inMinutes.abs()} minute(s) since stored.',
            logDir: Directory(path));

        List<dynamic> pendingPkg =
            (cacheFile['packages'] as List<dynamic>).toList();

        pendingPkg = pendingPkg.length > _loadCount
            ? pendingPkg.sublist(0, _loadCount)
            : pendingPkg;

        for (dynamic pkgName in pendingPkg) {
          File pkg = File('$path\\cache\\packages\\$pkgName.json');

          if (await pkg.exists()) {
            String pkgInfo = await pkg.readAsString();
            pubPackages.add(PkgViewData.fromJson(jsonDecode(pkgInfo)));
          } else {
            await logger.file(
              LogTypeTag.error,
              'Failed to find package: $pkg in cache, even though declared in cache map.',
              logDir: Directory(path),
            );
          }
        }

        // Make sure it hasn't been more than an hour since the last time we updated
        // the cache.
        if (time.difference(DateTime.now()).inMinutes.abs() < _cacheTimeout) {
          GetPkgResponseModel response = GetPkgResponseModel(
              response: GetPkgResponse.done, packages: pubPackages);

          // Kill isolate
          port.send(<dynamic>[response, true, false]);
          return;
        } else {
          GetPkgResponseModel response = GetPkgResponseModel(
              response: GetPkgResponse.pending, packages: pubPackages);

          // Don't kill isolate. Will refetch with cache.
          port.send(<dynamic>[response, false, true]);

          await logger.file(
            LogTypeTag.info,
            'Refetching pub packages cache -- cache exists but is stale/expired.',
            logDir: Directory(path),
          );

          pubPackages.clear();
        }
      }

      List<String> search = await PubClient().fetchFlutterFavorites();

      for (String e in search) {
        if (search.indexOf(e) >= _loadCount) {
          break;
        }

        PubPackage info = await _pub.packageInfo(e);
        PackageMetrics? data = await _pub.packageMetrics(e);
        PackagePublisher author = await _pub.packagePublisher(e);

        pubPackages.add(
          PkgViewData(
            name: e,
            info: info,
            metrics: data,
            publisher: author,
          ),
        );
      }

      // Set the cache after we have loaded the packages.
      await cache.writeAsString(
        jsonEncode(<String, dynamic>{
          'timestamp': DateTime.now().toIso8601String(),
          'packages': pubPackages.map((PkgViewData e) => e.name).toList(),
        }),
      );

      // Create the directory for projects if it doesn't exist.
      if (!Directory('$path\\cache\\packages').existsSync()) {
        Directory('$path\\cache\\packages').createSync(recursive: true);
      }

      // Save it locally as cache for later use.
      for (PkgViewData e in pubPackages) {
        File pkg = File('$path\\cache\\packages\\${e.name}.json');

        if (await pkg.exists()) {
          await pkg.delete();
        }

        await pkg.writeAsString(jsonEncode(e.toJson()));
      }
      await logger.file(LogTypeTag.info,
          'Added packages ${pubPackages.map((PkgViewData e) => '${e.name}, ')} to cache.',
          logDir: Directory(path));

      GetPkgResponseModel response = GetPkgResponseModel(
          response: GetPkgResponse.done, packages: pubPackages);

      // Kill isolate
      port.send(<dynamic>[response, true, false]);
      return;
    } catch (_, s) {
      print(_);
      print(s);

      await logger.file(
        LogTypeTag.error,
        'Failed to fetch pub packages. Error: $_',
        stackTraces: s,
        logDir: Directory(path),
      );

      GetPkgResponseModel response = GetPkgResponseModel(
          response: GetPkgResponse.error, packages: pubPackages);

      // Kill isolate
      port.send(<dynamic>[response, true, false]);
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
