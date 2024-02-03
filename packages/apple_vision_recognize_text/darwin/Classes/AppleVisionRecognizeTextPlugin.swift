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
            let orientation = arguments["orientation"] as? String ?? "downMirrored"
            let recognitionLevel = arguments["recognitionLevel"] as? String ?? "accurate"
            let queueString = arguments["dispatch"] as? String ?? "defaultQueue"
            let languages = arguments["languages"] as? [String] ?? nil
            let automaticallyDetectsLanguage = arguments["automaticallyDetectsLanguage"] as? Bool ?? false

            var dq:DispatchQoS.QoSClass = DispatchQoS.QoSClass.default
            switch queueString{
                case "background":
                    dq = DispatchQoS.QoSClass.background
                case "unspecified":
                    dq = DispatchQoS.QoSClass.unspecified
                case "userInitiated":
                    dq = DispatchQoS.QoSClass.userInitiated
                case "userInteractive":
                    dq = DispatchQoS.QoSClass.userInteractive
                case "utility":
                    dq = DispatchQoS.QoSClass.utility
                default:
                    dq = DispatchQoS.QoSClass.default
            }
            
            #if os(iOS)
                if #available(iOS 13.0, *) {
                    let event = self.convertImage(
                        Data(data.data),
                        CGSize(width: width , height: height),
                        candidates,
                        CIFormat.BGRA8,
                        orientation,
                        recognitionLevel,
                        languages,
                        automaticallyDetectsLanguage
                    )                
                    if dq == DispatchQoS.QoSClass.default{
                        return result(event)
                    }
                    else{
                        DispatchQueue.global(qos: dq).async {
                            DispatchQueue.main.async{result(event)}
                        }
                    }
                } else {
                    return result(FlutterError(code: "INVALID OS", message: "requires version 12.0", details: nil))
                }
            #elseif os(macOS)
                let event = self.convertImage(
                    Data(data.data),
                    CGSize(width: width , height: height),
                    candidates,
                    CIFormat.ARGB8,
                    orientation,
                    recognitionLevel,
                    languages,
                    automaticallyDetectsLanguage
                )
                if dq == DispatchQoS.QoSClass.default{
                    return result(event)
                }
                else{
                    DispatchQueue.global(qos: dq).async {
                        DispatchQueue.main.async{
                            result(event)
                        }
                    }
                }
            #endif
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    // Gets called when a new image is added to the buffer
    #if os(iOS)
    @available(iOS 13.0, *)
    #endif
    func convertImage(
        _ data: Data,
        _ imageSize: CGSize,
        _ candidates: Int,
        _ format: CIFormat,
        _ oriString: String,
        _ recognitionLevelString: String,
        _ languages: [String]?,
        _ automaticallyDetectsLanguage: Bool
    ) -> [String:Any?]{
        let imageRequestHandler:VNImageRequestHandler

        var orientation:CGImagePropertyOrientation = CGImagePropertyOrientation.downMirrored
        switch oriString{
            case "down":
                orientation = CGImagePropertyOrientation.down
            case "right":
                orientation = CGImagePropertyOrientation.right
            case "rightMirrored":
                orientation = CGImagePropertyOrientation.rightMirrored
            case "left":
                orientation = CGImagePropertyOrientation.left
            case "leftMirrored":
                orientation = CGImagePropertyOrientation.leftMirrored
            case "up":
                orientation = CGImagePropertyOrientation.up
            case "upMirrored":
                orientation = CGImagePropertyOrientation.upMirrored
            default:
                orientation = CGImagePropertyOrientation.downMirrored
        }

        var recognitionLevel:VNRequestTextRecognitionLevel = VNRequestTextRecognitionLevel.accurate
        switch recognitionLevelString{
            case "fast":
                recognitionLevel = VNRequestTextRecognitionLevel.fast
                break
            default:
                recognitionLevel = VNRequestTextRecognitionLevel.accurate
                break
        }

        if data.count == (Int(imageSize.height)*Int(imageSize.width)*4){
            // Create a bitmap graphics context with the sample buffer data
            let context =  CIImage(bitmapData: data, bytesPerRow: Int(imageSize.width)*4, size: imageSize, format: format, colorSpace: nil)
            imageRequestHandler = VNImageRequestHandler(ciImage:context,orientation: orientation)
        }
        else{
            imageRequestHandler = VNImageRequestHandler(data: data, orientation: orientation)
        }
            
        var event:[String:Any?] = ["name":"noData"];

        do {
            let request = VNRecognizeTextRequest {(req, error)in
                if error == nil {
                    if let results = req.results as? [VNRecognizedTextObservation] {
                        var listText:[[String:Any?]] = []
                        for text in results {
                            listText.append(self.processObservation(text,imageSize,candidates))
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
                    event = ["name":"error","code": "No Text Detected", "message": error!.localizedDescription]
                    print(error!.localizedDescription)
                }
            }
            if languages != nil {
                request.recognitionLanguages = languages!
            }
            #if os(iOS)
                if #available(iOS 16.0, *) {
                    request.automaticallyDetectsLanguage = automaticallyDetectsLanguage
                }
            #elseif os(macOS)
                if #available(macOS 13.0, *) {
                    request.automaticallyDetectsLanguage = automaticallyDetectsLanguage
                }
            #endif
            request.recognitionLevel = recognitionLevel
            try imageRequestHandler.perform([request])
        } catch {
            event = ["name":"error","code": "Data Corropted", "message": error.localizedDescription]
            print(error)
        }

        return event;
    }
    
    #if os(iOS)
    @available(iOS 13.0, *)
    #endif
    func processObservation(_ observation: VNRecognizedTextObservation,_ imageSize: CGSize, _ candidates: Int) -> [String:Any?] {
        // Retrieve all torso points.
        let recognizedPoints = observation.boundingBox
        let coord =  VNImagePointForNormalizedPoint(recognizedPoints.origin,Int(imageSize.width),Int(imageSize.height))

        return [
            "minX":Double(recognizedPoints.minX),
            "maxX":Double(recognizedPoints.maxX),
            "minY":Double(recognizedPoints.minY),
            "maxY":Double(recognizedPoints.maxX),
            "height":Double(recognizedPoints.height),
            "width":Double(recognizedPoints.width),
            "origin": ["x":(imageSize.width-coord.x)-(recognizedPoints.width*imageSize.width),"y":coord.y],
            "text": observation.topCandidates(candidates).map {  text in
                text.string
            }
        ]
    }
}
