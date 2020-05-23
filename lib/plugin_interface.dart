import 'package:flutter/material.dart';

class Frame {
  const Frame({@required this.url});

  final String url;
}

class TrimOptions {
  const TrimOptions({
    @required this.startAt,
    @required this.endAt
  });

  final double startAt;
  final double endAt;
}

class VideoInfo {
  const VideoInfo({
    this.duration,
    this.width,
    this.height,
    this.size,
    this.frameRate,
    this.bitRate
  });

  final double duration;
  final double width;
  final double height;
  final double size;
  final double frameRate;
  final double bitRate;
}

class CropParams {
  const CropParams({
    this.cropOffsetX,
    this.cropOffsetY,
    this.cropWidth,
    this.cropHeight
  });

  final double cropOffsetX;
  final double cropOffsetY;
  final double cropWidth;
  final double cropHeight;
}

class CompressParams {
  const CompressParams({
    this.width,
    this.height,
    this.bitrateMultiplier,
    this.minimumBitrate,
    this.removeAudio
  });

  final double width;
  final double height;
  final double bitrateMultiplier;
  final double minimumBitrate;
  final double removeAudio;
}


abstract class PluginInterface {
  Future<List<Frame>> getFramesList(String videoUrl);
  Future<Frame> getFrameAt({double second, String url});
  Future<String> trim({TrimOptions options, String url});
  Future<String> reverse({String url});
  Future<String> boomerang({String url});
  Future<String> compress({CompressParams params, String url});
  Future<String> crop({ @required CropParams params, String url});

  Future<VideoInfo> getInfo({String url});
}