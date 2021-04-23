// import 'package:flutter_installer/utils/constants.dart';
// import 'package:http/http.dart' as http;

// // APICalls apiCalls = APICalls();

// // class APICalls {
// //   Future<void> flutterAPICall() async {
// //     if (win32) {
// //       http.Response? apiResponse = await http.get(APILinks.win32RelaseEndpoint);
// //     } else if (mac) {
// //       http.Response? apiResponse = await http.get(APILinks.macRelaseEndpoint);
// //       print(apiResponse.body);
// //     } else {
// //       http.Response? apiResponse = await http.get(APILinks.linuxRelaseEndpoint);
// //       print(apiResponse.body);
// //     }
// //     // Map<String, dynamic> data = json.decode(response.body);
// //   }
// // }

// class FlutterReleases {
//   String _baseUrl;
//   CurrentRelease _currentRelease;
//   List<Releases> _releases;

//   FlutterReleases(
//       {String baseUrl,
//       CurrentRelease currentRelease,
//       List<Releases> releases}) {
//     this._baseUrl = baseUrl;
//     this._currentRelease = currentRelease;
//     this._releases = releases;
//   }

//   String get baseUrl => _baseUrl;
//   set baseUrl(String baseUrl) => _baseUrl = baseUrl;
//   CurrentRelease get currentRelease => _currentRelease;
//   set currentRelease(CurrentRelease currentRelease) =>
//       _currentRelease = currentRelease;
//   List<Releases> get releases => _releases;
//   set releases(List<Releases> releases) => _releases = releases;

//   FlutterReleases.fromJson(Map<String, dynamic> json) {
//     _baseUrl = json['base_url'];
//     _currentRelease = json['current_release'] != null
//         ? new CurrentRelease.fromJson(json['current_release'])
//         : null;
//     if (json['releases'] != null) {
//       _releases = new List<Releases>();
//       json['releases'].forEach((v) {
//         _releases.add(new Releases.fromJson(v));
//       });
//     }
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['base_url'] = this._baseUrl;
//     if (this._currentRelease != null) {
//       data['current_release'] = this._currentRelease.toJson();
//     }
//     if (this._releases != null) {
//       data['releases'] = this._releases.map((v) => v.toJson()).toList();
//     }
//     return data;
//   }
// }

// class CurrentRelease {
//   String _beta;
//   String _dev;
//   String _stable;

//   CurrentRelease({String beta, String dev, String stable}) {
//     this._beta = beta;
//     this._dev = dev;
//     this._stable = stable;
//   }

//   String get beta => _beta;
//   set beta(String beta) => _beta = beta;
//   String get dev => _dev;
//   set dev(String dev) => _dev = dev;
//   String get stable => _stable;
//   set stable(String stable) => _stable = stable;

//   CurrentRelease.fromJson(Map<String, dynamic> json) {
//     _beta = json['beta'];
//     _dev = json['dev'];
//     _stable = json['stable'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['beta'] = this._beta;
//     data['dev'] = this._dev;
//     data['stable'] = this._stable;
//     return data;
//   }
// }

// class Releases {
//   String _hash;
//   String _channel;
//   String _version;
//   String _releaseDate;
//   String _archive;
//   String _sha256;

//   Releases(
//       {String hash,
//       String channel,
//       String version,
//       String releaseDate,
//       String archive,
//       String sha256}) {
//     this._hash = hash;
//     this._channel = channel;
//     this._version = version;
//     this._releaseDate = releaseDate;
//     this._archive = archive;
//     this._sha256 = sha256;
//   }

//   String get hash => _hash;
//   set hash(String hash) => _hash = hash;
//   String get channel => _channel;
//   set channel(String channel) => _channel = channel;
//   String get version => _version;
//   set version(String version) => _version = version;
//   String get releaseDate => _releaseDate;
//   set releaseDate(String releaseDate) => _releaseDate = releaseDate;
//   String get archive => _archive;
//   set archive(String archive) => _archive = archive;
//   String get sha256 => _sha256;
//   set sha256(String sha256) => _sha256 = sha256;

//   Releases.fromJson(Map<String, dynamic> json) {
//     _hash = json['hash'];
//     _channel = json['channel'];
//     _version = json['version'];
//     _releaseDate = json['release_date'];
//     _archive = json['archive'];
//     _sha256 = json['sha256'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['hash'] = this._hash;
//     data['channel'] = this._channel;
//     data['version'] = this._version;
//     data['release_date'] = this._releaseDate;
//     data['archive'] = this._archive;
//     data['sha256'] = this._sha256;
//     return data;
//   }
// }
