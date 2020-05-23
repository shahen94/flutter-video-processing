//
//  Boomerang.swift
//  flutter_video_processing
//
//  Created by Shahen Hovhannisyan on 5/23/20.
//

import Foundation
import AVFoundation
import Flutter

class Boomerang {
    static func exec(_ source: String, result: @escaping FlutterResult) {

        let quality = ""

        let manager = FileManager.default
        guard let documentDirectory = try? manager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
          else {
            result(FlutterError(code: "ERRFMANAGER", message: "Error creating FileManager", details: nil))
            return
        }

        let sourceURL = ProcessingUtils.getSourceURL(source: source)
        let firstAsset = AVAsset(url: sourceURL as URL)

        let mixComposition = AVMutableComposition()
        let track = mixComposition.addMutableTrack(withMediaType: .video, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))

        var outputURL = documentDirectory.appendingPathComponent("output")
        var finalURL = documentDirectory.appendingPathComponent("output")
        do {
          try manager.createDirectory(at: outputURL, withIntermediateDirectories: true, attributes: nil)
          try manager.createDirectory(at: finalURL, withIntermediateDirectories: true, attributes: nil)
            let name = ProcessingUtils.randomString(length: 10)
          outputURL = outputURL.appendingPathComponent("\(name).mp4")
          finalURL = finalURL.appendingPathComponent("\(name)merged.mp4")
        } catch {
            result(FlutterError(code: "ERRDIR", message: error.localizedDescription, details: nil))
            print(error)
            return;
        }

        //Remove existing file
        _ = try? manager.removeItem(at: outputURL)
        _ = try? manager.removeItem(at: finalURL)

        let useQuality = ProcessingUtils.getQualityForAsset(quality: quality, asset: firstAsset)

    //    print("RNVideoTrimmer passed quality: \(quality). useQuality: \(useQuality)")
        ProcessingUtils.reverse(
            firstAsset,
            outputURL: outputURL,
            completion: { [] (reversedAsset: AVAsset) in


          let secondAsset = reversedAsset

          // Credit: https://www.raywenderlich.com/94404/play-record-merge-videos-ios-swift
          do {
            try track?.insertTimeRange(CMTimeRangeMake(start: .zero, duration: firstAsset.duration), of: firstAsset.tracks(withMediaType: .video)[0], at: .zero)
          } catch _ {
            result(FlutterError(code: "ERRREV", message: "Could not load 1st track", details: nil))
            return
          }

          do {
            try track?.insertTimeRange(CMTimeRangeMake(start: .zero, duration: secondAsset.duration), of: secondAsset.tracks(withMediaType: .video)[0], at: mixComposition.duration)
          } catch _ {
            result(FlutterError(code: "ERRREV", message: "Could not load 2nd track", details: nil))
            return
          }


          guard let exportSession = AVAssetExportSession(asset: mixComposition, presetName: useQuality) else {
            result(FlutterError(code: "ERRREV", message: "Error creating AVAssetExportSession", details: nil))
            return
          }
          exportSession.outputURL = NSURL.fileURL(withPath: finalURL.path)
          exportSession.outputFileType = .mp4
          exportSession.shouldOptimizeForNetworkUse = true
          let startTime = CMTime(seconds: Double(0), preferredTimescale: 1000)
          let endTime = CMTime(seconds: mixComposition.duration.seconds, preferredTimescale: 1000)
          let timeRange = CMTimeRange(start: startTime, end: endTime)

          exportSession.timeRange = timeRange

          exportSession.exportAsynchronously{
            switch exportSession.status {
            case .completed:
              result(finalURL.absoluteString)

            case .failed:
                result(FlutterError(code: "ERREXPORT", message: "Error during export", details: exportSession.error))

            case .cancelled:
              result(FlutterError(code: "ERREXPORT", message: "Canceled during export", details: exportSession.error))

            default: break
            }
          }
        }, onError: {(error: String) in
            result(FlutterError(
                code: "ERR_REV", message: error, details: nil
            ))
        })
      }
}
