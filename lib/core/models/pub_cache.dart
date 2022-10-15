// 🎯 Dart imports:
import 'dart:convert';
import 'dart:io';

// 📦 Package imports:
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

// 🌎 Project imports:
import 'package:fluttermatic/core/services/logs.dart';

class PubCache {
  static Future<File> get _cache async => File(
      '${(await getApplicationSupportDirectory()).path}\\cache\\pub_packages.json');

  /// Will load the packages from the API. This ignore the cache. Once fetched,
  /// it will update the API with the latest packages.
  static Future<List<String>> loadPackages() async {
    try {
      String url = 'https://pub.dev/api/package-name-completion-data';

      http.Response response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        await logger.file(LogTypeTag.error,
            'Failed to get pub cache from API. Didn\'t respond with code 200.');

        return [];
      } else {
        List<dynamic> packages =
            ((jsonDecode(response.body) as Map<String, dynamic>).entries.first)
                .value as List<dynamic>;

        await setCache(packages.cast<String>());

        await logger.file(LogTypeTag.info,
            'Storing the pub cache with the newly fetched packages from API.');
      }

      await logger.file(
          LogTypeTag.info, 'Fetched pub cache from API. Returning results.');

      return getCache();
    } catch (e, s) {
      await logger.file(
          LogTypeTag.error, 'Failed to get pub packages from API.',
          error: e, stackTrace: s);

      return [];
    }
  }

  /// Will get the packages from the cache is they are still valid. If not then
  /// will make an API request and then store the packages in the cache and
  /// return the new cache.
  static Future<List<String>> getCache() async {
    try {
      // Will make sure it has been less than 1 hour since the last time we
      // updated the cache.
      if (await (await _cache).exists()) {
        Map<String, dynamic> cachePackages =
            jsonDecode(await (await _cache).readAsString());

        DateTime lastUpdated =
            DateTime.fromMillisecondsSinceEpoch(cachePackages['last_updated']);

        bool isCacheValid = DateTime.now().difference(lastUpdated).inHours < 1;

        if (cachePackages['last_updated'] != null && isCacheValid) {
          await logger.file(LogTypeTag.info, 'Fetched valid pub cache data.');

          return (cachePackages['packages'] as List<dynamic>).cast<String>();
        } else {
          await logger.file(LogTypeTag.info,
              'Pub cache expired. Will request a refetch before returning results.');

          return loadPackages();
        }
      }

      await logger.file(LogTypeTag.info,
          'Requested pub cache when pub cache doesn\'t exist. Redirecting initial request to fetch from API instead.');

      return loadPackages();
    } catch (e, s) {
      await logger.file(LogTypeTag.error,
          'Failed to get pub cache. Will request a refetch before returning results.',
          error: e, stackTrace: s);

      return [];
    }
  }

  /// Will update the cache update timestamp to [DateTime.now()] and update the
  /// packages to [packages].
  static Future<void> setCache(List<String> packages) async {
    try {
      // Will update the cache file.
      Map<String, dynamic> cacheData = <String, dynamic>{
        'last_updated': DateTime.now().millisecondsSinceEpoch,
        'packages': packages,
      };

      await (await _cache).writeAsString(jsonEncode(cacheData));

      await logger.file(LogTypeTag.info,
          'Updated the pub cache file with the latest packages.');

      return;
    } catch (e, s) {
      await logger.file(LogTypeTag.error,
          'Failed to update the pub cache file with the latest packages.',
          error: e, stackTrace: s);

      return;
    }
  }
}
