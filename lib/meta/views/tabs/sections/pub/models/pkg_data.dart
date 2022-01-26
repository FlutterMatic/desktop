// 🎯 Dart imports:
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

// 📦 Package imports:
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
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
    return PkgViewData(
      name: json['name'] as String,
      info: PubPackage.fromJson(json['info'] as Map<String, dynamic>),
      metrics: json['metrics'] != null
          ? PackageMetrics.fromJson(json['metrics'] as Map<String, dynamic>)
          : null,
      publisher:
          PackagePublisher.fromJson(json['publisher'] as Map<String, dynamic>),
    );
  }

  /// Returns the package's README by crawling the package's homepage.
  ///
  /// This method is meant to always run on an isolate. Requires an input of
  /// type list with the following information in order:
  ///
  /// [<SendPort> port, <String> packageName]
  static Future<void> getPkgReadMeIsolate(List<dynamic> data) async {
    SendPort _port = data[0];
    String _pkgName = data[1];

    try {
      List<String> _readMe = <String>[];

      // Will crawl the package's readme from the Pub.dev website.
      http.Response _response =
          await http.get(Uri.parse('https://pub.dev/packages/$_pkgName'));

      // Everything between `<section class="tab-content detail-tab-readme-content -active markdown-body">`
      // and `</section>` is the README.md markdown data.

      String _startTxt =
          '<section class="tab-content detail-tab-readme-content -active markdown-body">';
      String _endTxt = '</section>';

      int _start = _response.body.indexOf(_startTxt) + _startTxt.length;

      int _end = 0;

      while (_end < _start) {
        _end = _response.body.indexOf(_endTxt, _end + 1);
      }

      String _plainReadMe = _response.body.substring(_start, _end);

      // We will extract the <code></code> tags and replace them with markdown
      // code blocks.
      List<String> _codeStartTags = <String>[
        '<code>',
        '<pre><code>',
        '<pre><code class="language-dart">',
        '<pre><code class="language-java">',
        '<pre><code class="language-swift">',
        '<pre><code class="language-javascript">',
        '<pre><code class="language-python">',
        '<pre><code class="language-html">',
        '<pre><code class="language-typescript">',
      ];

      List<String> _codeEndTags = <String>[
        '</code>',
        '</code></pre>',
      ];

      for (String tag in _codeStartTags) {
        while (_plainReadMe.contains(tag)) {
          int _startCode = _plainReadMe.indexOf(tag);
          int _endCode = -1;

          String _endCodeTag = '';

          for (String endTag in _codeEndTags) {
            _endCode = _plainReadMe.indexOf(endTag, _startCode + 1);
            _endCodeTag = endTag;

            if (_endCode != -1) {
              break;
            }
          }

          if (_endCode == -1) {
            break;
          }

          String _code =
              _plainReadMe.substring(_startCode + tag.length, _endCode);

          // Add to the [_readMe] list the documentation before the code block. Then
          // we will add the code block to the list. After that, we will remove
          // the code block from the [_plainReadMe] string and also the documentation
          // that was before the code block.
          if (_plainReadMe.substring(0, _startCode).isNotEmpty) {
            _readMe.add('docs:' + _plainReadMe.substring(0, _startCode));
          }
          // TODO: Temporary avoid code blocks. Resolve.
          _readMe.add('docs:' + _code);
          _plainReadMe = _plainReadMe.substring(_endCode + _endCodeTag.length);
        }
      }

      // Print all the code snippets.
      for (String block in _readMe) {
        if (block.startsWith('code:')) {
          // TODO: Fix to ignore blocks directly as <code></code> tags.
        }
      }

      _port.send(_readMe);
    } catch (_, s) {
      await logger.file(
          LogTypeTag.error, 'Failed to fetch README for package: $_pkgName',
          stackTraces: s);
      _port.send(false);
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
  static Future<GetPkgResponseModel> getInitialPackages() async {
    List<PkgViewData> _pubPackages = <PkgViewData>[];
    Directory _dir = await getApplicationSupportDirectory();
    File _cache = File(_dir.path + '\\cache\\pub_cache.map.json');

    try {
      if (await _cache.exists()) {
        Map<String, dynamic> _cacheFile =
            jsonDecode(await _cache.readAsString());

        DateTime _time = DateTime.parse(_cacheFile['timestamp']);

        // Make sure it hasn't been more than a day since the last time we updated
        // the cache.
        if (_time.difference(DateTime.now()).inMinutes.abs() < _cacheTimeout) {
          await logger.file(
            LogTypeTag.info,
            'Fetching pub packages from cache after '
            '${_time.difference(DateTime.now()).inMinutes.abs()} minute(s) since stored.',
          );
          List<dynamic> _pendingPkg =
              (_cacheFile['packages'] as List<dynamic>).toList();

          _pendingPkg = _pendingPkg.length > _loadCount
              ? _pendingPkg.sublist(0, _loadCount)
              : _pendingPkg;

          for (dynamic pkg in _pendingPkg) {
            File _pkg = File(_dir.path + '\\cache\\packages\\$pkg.json');

            if (await _pkg.exists()) {
              String _pkgInfo = await _pkg.readAsString();
              _pubPackages.add(PkgViewData.fromJson(jsonDecode(_pkgInfo)));
            } else {
              await logger.file(
                LogTypeTag.error,
                'Failed to find package: $pkg in cache, even though declared in cache map.',
              );
            }
          }

          return GetPkgResponseModel(
              response: GetPkgResponse.done, packages: _pubPackages);
        } else {
          await logger.file(LogTypeTag.info,
              'Refetching pub packages cache -- cache exists but is stale/expired.');
        }
      }

      if (_pubPackages.isNotEmpty) {
        return GetPkgResponseModel(
            response: GetPkgResponse.done, packages: _pubPackages);
      }

      // http.Response _result = await http
      //     .get(Uri.parse('https://pub.dev/api/package-name-completion-data'))
      //     .onError((_, __) => http.Response('', 300));

      SearchResults _search1 = await PubClient().search('', page: 1);
      SearchResults _search2 = await PubClient().search('', page: 2);

      List<PackageResult> _packages = <PackageResult>[
        ..._search1.packages,
        ..._search2.packages
      ];

      for (PackageResult e in _packages) {
        PubPackage _info = await _pub.packageInfo(e.package);
        PackageMetrics? _data = await _pub.packageMetrics(e.package);
        PackagePublisher _author = await _pub.packagePublisher(e.package);

        _pubPackages.add(PkgViewData(
          name: e.package,
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
      if (!Directory(_dir.path + '\\cache\\packages').existsSync()) {
        Directory(_dir.path + '\\cache\\packages').createSync(recursive: true);
      }

      // Save it locally as cache for later use.
      for (PkgViewData e in _pubPackages) {
        File _pkg = File(_dir.path + '\\cache\\packages\\${e.name}.json');

        if (await _pkg.exists()) {
          await _pkg.delete();
        }

        await _pkg.writeAsString(jsonEncode(e.toJson()));
      }
      await logger.file(LogTypeTag.info,
          'Added packages ${_pubPackages.map((PkgViewData e) => e.name + ', ')} to cache.');

      return GetPkgResponseModel(
          response: GetPkgResponse.done, packages: _pubPackages);
    } catch (_, s) {
      await logger.file(LogTypeTag.error, 'Failed to fetch pub packages.',
          stackTraces: s);
      return GetPkgResponseModel(
          response: GetPkgResponse.error, packages: _pubPackages);
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
  network,
}
