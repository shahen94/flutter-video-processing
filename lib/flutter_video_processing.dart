import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_video_processing/constants.dart';
import 'package:flutter_video_processing/plugin_interface.dart';

class FlutterVideoProcessing implements PluginInterface {
  static const MethodChannel _channel =
      const MethodChannel(CHANNEL);

  static final FlutterVideoProcessing shared = FlutterVideoProcessing._();

  // static Future<String> get platformVersion async {
  //   final String version = await _channel.invokeMethod('getPlatformVersion');
  //   return version;
  // }

  FlutterVideoProcessing() {
    throw UnimplementedError();
  }

  FlutterVideoProcessing._();

  @override
  Future<String> boomerang({String url}) async {
    final String videoSource = await _channel.invokeMethod('boomerang', url);
    return videoSource;
  }

  @override
  Future<String> compress({CompressParams params, String url}) async {
    Map<String, dynamic> passParams = {
      "url": url,
      "params": params,
    };

    final String videoSource = await _channel.invokeMethod('compress', passParams);
    return videoSource;
  }

  @override
  Future<String> crop({CropParams params, String url}) {
    // TODO: implement crop
    throw UnimplementedError();
  }

  @override
  Future<Frame> getFrameAt({double second, String url}) {
    // TODO: implement getFrameAt
    throw UnimplementedError();
  }

  @override
  Future<List<Frame>> getFramesList(String videoUrl) {
    // TODO: implement getFramesList
    throw UnimplementedError();
  }

  @override
  Future<VideoInfo> getInfo({String url}) {
    // TODO: implement getInfo
    throw UnimplementedError();
  }

  @override
  Future<String> reverse({String url}) {
    // TODO: implement reverse
    throw UnimplementedError();
  }

  @override
  Future<String> trim({TrimOptions options, String url}) {
    // TODO: implement trim
    throw UnimplementedError();
  }
}
