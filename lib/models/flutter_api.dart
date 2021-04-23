import 'package:flutter_installer/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';

APICalls apiCalls = APICalls();

class APICalls {
  Future<FlutterReleases> flutterAPICall() async {
    if (win32) {
      http.Response? apiResponse = await http.get(APILinks.win32RelaseEndpoint);
      Map<String, dynamic> data = json.decode(apiResponse.body);
      return FlutterReleases.fromJson(data);
    } else if (mac) {
      http.Response? apiResponse = await http.get(APILinks.macRelaseEndpoint);
      Map<String, dynamic> data = json.decode(apiResponse.body);
      debugPrint(apiResponse.body);
      return FlutterReleases.fromJson(data);
    } else {
      http.Response? apiResponse = await http.get(APILinks.linuxRelaseEndpoint);
      Map<String, dynamic> data = json.decode(apiResponse.body);
      debugPrint(apiResponse.body);
      return FlutterReleases.fromJson(data);
    }
  }
}

class FlutterReleases {
  String? baseUrl;
  CurrentRelease? currentRelease;
  List<Releases?>? releases;

  FlutterReleases(
      {required String baseUrl,
      required CurrentRelease currentRelease,
      required List<Releases> releases}) {
    baseUrl = baseUrl;
    currentRelease = currentRelease;
    releases = releases;
  }

  FlutterReleases.fromJson(Map<String, dynamic> json) {
    baseUrl = json['base_url'];
    currentRelease = json['current_release'] != null
        ? CurrentRelease.fromJson(json['current_release'])
        : null;
    if (json['releases'] != null) {
      releases = <Releases>[];
      json['releases'].forEach((v) {
        releases!.add(Releases.fromJson(v));
      });
    }
  }
  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = <String, dynamic>{};
    data['base_url'] = baseUrl;
    if (currentRelease != null) {
      data['current_release'] = currentRelease!.toJson();
    }
    return data;
  }
}

class CurrentRelease {
  String? beta;
  String? dev;
  String? stable;

  CurrentRelease(
      {required String beta, required String dev, required String stable}) {
    beta = beta;
    dev = dev;
    stable = stable;
  }

  CurrentRelease.fromJson(Map<String, dynamic> json) {
    beta = json['beta'];
    dev = json['dev'];
    stable = json['stable'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = <String, dynamic>{};
    data['beta'] = beta;
    data['dev'] = dev;
    data['stable'] = stable;
    return data;
  }
}

class Releases {
  String? hash;
  String? channel;
  String? version;
  String? releaseDate;
  String? archive;
  String? sha256;

  Releases(
      {required String hash,
      required String channel,
      required String version,
      required String releaseDate,
      required String archive,
      required String sha256}) {
    hash = hash;
    channel = channel;
    version = version;
    releaseDate = releaseDate;
    archive = archive;
    sha256 = sha256;
  }
  Releases.fromJson(Map<String, dynamic> json) {
    hash = json['hash'];
    channel = json['channel'];
    version = json['version'];
    releaseDate = json['release_date'];
    archive = json['archive'];
    sha256 = json['sha256'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = <String, dynamic>{};
    data['hash'] = hash;
    data['channel'] = channel;
    data['version'] = version;
    data['release_date'] = releaseDate;
    data['archive'] = archive;
    data['sha256'] = sha256;
    return data;
  }
}
