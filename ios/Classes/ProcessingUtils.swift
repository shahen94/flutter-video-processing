//
//  ProcessingUtils.swift
//  flutter_video_processing
//
//  Created by Shahen Hovhannisyan on 5/23/20.
//

import UIKit
import AVFoundation

class ProcessingUtils {
    static func reverse(_ original: AVAsset, outputURL: URL, completion: @escaping (AVAsset) -> Void, onError: ((String) -> Void)?) {
    
    // Initialize the reader
    
    var reader: AVAssetReader! = nil
    do {
      reader = try AVAssetReader(asset: original)
    } catch {
      onError?("could not initialize reader.")
      return
    }
    
    guard let videoTrack = original.tracks(withMediaType: .video).last else {
        onError?("could not retrieve the video track.")
      return
    }
    
    let readerOutputSettings: [String: Any] = [kCVPixelBufferPixelFormatTypeKey as String : Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
    let readerOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: readerOutputSettings)
    reader.add(readerOutput)
    
    reader.startReading()
    
    // read in samples
    
    var samples: [CMSampleBuffer] = []
    while let sample = readerOutput.copyNextSampleBuffer() {
      samples.append(sample)
    }
    
    // Initialize the writer
    
    let writer: AVAssetWriter
    do {
      writer = try AVAssetWriter(outputURL: outputURL, fileType: .mov)
    } catch let error {
      fatalError(error.localizedDescription)
    }
    
    let videoCompositionProps = [AVVideoAverageBitRateKey: videoTrack.estimatedDataRate]
    let writerOutputSettings = [
      AVVideoCodecKey: AVVideoCodecH264,
      AVVideoWidthKey: videoTrack.naturalSize.width,
      AVVideoHeightKey: videoTrack.naturalSize.height,
      AVVideoCompressionPropertiesKey: videoCompositionProps
      ] as [String : Any]
    
    let writerInput = AVAssetWriterInput(mediaType: .video, outputSettings: writerOutputSettings)
    writerInput.expectsMediaDataInRealTime = false
    writerInput.transform = videoTrack.preferredTransform
    
    let pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: writerInput, sourcePixelBufferAttributes: nil)
    
    writer.add(writerInput)
    writer.startWriting()
    writer.startSession(atSourceTime: CMSampleBufferGetPresentationTimeStamp(samples.first!))
    
    for (index, sample) in samples.enumerated() {
      let presentationTime = CMSampleBufferGetPresentationTimeStamp(sample)
      let imageBufferRef = CMSampleBufferGetImageBuffer(samples[samples.count - 1 - index])
      while !writerInput.isReadyForMoreMediaData {
        Thread.sleep(forTimeInterval: 0.1)
      }
      pixelBufferAdaptor.append(imageBufferRef!, withPresentationTime: presentationTime)
      
    }
    
    writer.finishWriting {
      completion(AVAsset(url: outputURL))
    }
  }
    
 static func getSourceURL(source: String) -> URL {
      var sourceURL: URL
      if source.contains("assets-library") {
        sourceURL = NSURL(string: source)! as URL
      } else {
        let bundleUrl = Bundle.main.resourceURL!
        sourceURL = URL(string: source, relativeTo: bundleUrl)!
      }
      return sourceURL
    }
    
  static func randomString(length: Int = 10) -> String {

        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)

        var randomString = ""

        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }

        return randomString
    }
    
  static func getQualityForAsset(quality: String, asset: AVAsset) -> String {
      var useQuality: String

      switch quality {
        case QUALITY_ENUM.QUALITY_LOW.rawValue:
          useQuality = AVAssetExportPresetLowQuality

        case QUALITY_ENUM.QUALITY_MEDIUM.rawValue:
          useQuality = AVAssetExportPresetMediumQuality

        case QUALITY_ENUM.QUALITY_HIGHEST.rawValue:
          useQuality = AVAssetExportPresetHighestQuality

        case QUALITY_ENUM.QUALITY_640x480.rawValue:
          useQuality = AVAssetExportPreset640x480

        case QUALITY_ENUM.QUALITY_960x540.rawValue:
          useQuality = AVAssetExportPreset960x540

        case QUALITY_ENUM.QUALITY_1280x720.rawValue:
          useQuality = AVAssetExportPreset1280x720

        case QUALITY_ENUM.QUALITY_1920x1080.rawValue:
          useQuality = AVAssetExportPreset1920x1080

        case QUALITY_ENUM.QUALITY_3840x2160.rawValue:
          if #available(iOS 9.0, *) {
            useQuality = AVAssetExportPreset3840x2160
          } else {
            useQuality = AVAssetExportPresetPassthrough
          }

        default:
          useQuality = AVAssetExportPresetPassthrough
      }

      let compatiblePresets = AVAssetExportSession.exportPresets(compatibleWith: asset)
      if !compatiblePresets.contains(useQuality) {
        useQuality = AVAssetExportPresetPassthrough
      }
      return useQuality
    }
}
