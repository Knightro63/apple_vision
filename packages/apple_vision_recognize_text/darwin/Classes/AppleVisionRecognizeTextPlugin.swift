import AVFoundation
import Vision

#if os(iOS)
import Flutter
import UIKit
#elseif os(macOS)
import FlutterMacOS
import AppKit
#endif

public class AppleVisionRecognizeTextPlugin: NSObject, FlutterPlugin {

    let registry: FlutterTextureRegistry
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        #if os(iOS)
        let method = FlutterMethodChannel(name:"apple_vision/recognize_text", binaryMessenger: registrar.messenger())
        let instance = AppleVisionRecognizeTextPlugin(registrar.textures())
        #elseif os(macOS)
        let method = FlutterMethodChannel(name:"apple_vision/recognize_text", binaryMessenger: registrar.messenger)
        let instance = AppleVisionRecognizeTextPlugin(registrar.textures)
        #endif
        registrar.addMethodCallDelegate(instance, channel: method)
    }
    
    init(_ registry: FlutterTextureRegistry) {
        self.registry = registry
        super.init()
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "process":
            guard let arguments = call.arguments as? [String:Any],
                let data:FlutterStandardTypedData = arguments["image"] as? FlutterStandardTypedData else {
                    result("Couldn't find image data")
                    return
            }
            let width = arguments["width"] as? Double ?? 0
            let height = arguments["height"] as? Double ?? 0
            let candidates = arguments["candidates"] as? Int ?? 1
  #if os(iOS)
                if #available(iOS 13.0, *) {
                    convertImage(Data(data.data), CGSize(width: width, height: height), candidates, CIFormat.ARGB8) { event in
                result(event)
            }
                } else {
                    return result(FlutterError(code: "INVALID OS", message: "requires version 12.0", details: nil))
                }
            #elseif os(macOS)
               convertImage(Data(data.data), CGSize(width: width, height: height), candidates, CIFormat.ARGB8) { event in
                result(event)
            }
            #endif
           
        default:
            result(FlutterMethodNotImplemented)
        }
    }
 #if os(iOS)
    @available(iOS 13.0, *)
    #endif
    // Gets called when a new image is added to the buffer
    func convertImage(_ data: Data, _ imageSize: CGSize, _ candidates: Int, _ format: CIFormat, completion: @escaping ([String: Any?]) -> Void) {
        DispatchQueue.global().async {
            let imageRequestHandler: VNImageRequestHandler
            if data.count == (Int(imageSize.height) * Int(imageSize.width) * 4) {
                // Create a bitmap graphics context with the sample buffer data
                let context = CIImage(bitmapData: data, bytesPerRow: Int(imageSize.width) * 4, size: imageSize, format: format, colorSpace: nil)

                imageRequestHandler = VNImageRequestHandler(ciImage: context, orientation: .downMirrored)
            } else {
                imageRequestHandler = VNImageRequestHandler(
                    data: data,
                    orientation: .down)
            }

            var event: [String: Any?] = ["name": "noData"]

            do {
                try imageRequestHandler.perform([VNRecognizeTextRequest { (request, error) in
                    if error == nil {

                        if let results = request.results as? [VNRecognizedTextObservation] {
                            var listText: [[String: Any?]] = []
                            for text in results {
                                listText.append(self.processObservation(text, imageSize, candidates))
                            }
                            event = [
                                "name": "recognizeText",
                                "data": listText,
                                "imageSize": [
                                    "width": imageSize.width,
                                    "height": imageSize.height
                                ]
                            ]
                        }
                    } else {
                        event = ["name": "error", "code": "No Text Detected", "message": error!.localizedDescription]
                        print(error!.localizedDescription)
                    }
                    completion(event) // Call the completion handler when processing is complete
                }])
            } catch {
                event = ["name": "error", "code": "Data Corropted", "message": error.localizedDescription]
                print(error)
                completion(event) // Call the completion handler even in case of an error
            }
        }
    }
 #if os(iOS)
    @available(iOS 13.0, *)
    #endif
    func processObservation(_ observation: VNRecognizedTextObservation, _ imageSize: CGSize, _ candidates: Int) -> [String: Any?] {
        // Retrieve all torso points.
        let recognizedPoints = observation.boundingBox
        let coord = VNImagePointForNormalizedPoint(recognizedPoints.origin,
                                                   Int(imageSize.width),
                                                   Int(imageSize.height))
        return [
            "minX": Double(recognizedPoints.minX),
            "maxX": Double(recognizedPoints.maxX),
            "minY": Double(recognizedPoints.minY),
            "maxY": Double(recognizedPoints.maxX),
            "height": Double(recognizedPoints.height),
            "width": Double(recognizedPoints.width),
            "origin": ["x": (imageSize.width - coord.x) - (recognizedPoints.width * imageSize.width), "y": coord.y],
            "text": observation.topCandidates(candidates).map { text in
                text.string
            }
        ]
    }
}
