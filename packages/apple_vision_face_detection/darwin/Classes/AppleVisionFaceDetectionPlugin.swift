import AVFoundation
import Vision

#if os(iOS)
import Flutter
import UIKit
#elseif os(macOS)
import FlutterMacOS
import AppKit
#endif

public class AppleVisionFaceDetectionPlugin: NSObject, FlutterPlugin {
    
    let registry: FlutterTextureRegistry
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        #if os(iOS)
        let method = FlutterMethodChannel(name:"apple_vision/face_detection", binaryMessenger: registrar.messenger())
        let instance = AppleVisionFacePlugin(registrar.textures())
        #elseif os(macOS)
        let method = FlutterMethodChannel(name:"apple_vision/face_detection", binaryMessenger: registrar.messenger)
        let instance = AppleVisionFacePlugin(registrar.textures)
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
            #if os(iOS)
                if #available(iOS 12.0, *) {
                    return result(convertImage(Data(data.data),CGSize(width: width , height: height),CIFormat.BGRA8))
                } else {
                    return result(FlutterError(code: "INVALID OS", message: "requires version 12.0", details: nil))
                }
            #elseif os(macOS)
                return result(convertImage(Data(data.data),CGSize(width: width , height: height),CIFormat.ARGB8))
            #endif
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    // Gets called when a new image is added to the buffer
    #if os(iOS)
    @available(iOS 12.0, *)
    #endif
    func convertImage(_ data: Data,_ imageSize: CGSize,_ format: CIFormat) -> [String:Any?]{
        let imageRequestHandler:VNImageRequestHandler
        if data.count == (Int(imageSize.height)*Int(imageSize.width)*4){
            // Create a bitmap graphics context with the sample buffer data
            let context =  CIImage(bitmapData: data, bytesPerRow: Int(imageSize.width)*4, size: imageSize, format: format, colorSpace: nil)
            
            imageRequestHandler = VNImageRequestHandler(ciImage:context)
        }
        else{
            imageRequestHandler = VNImageRequestHandler(
                data: data,
                orientation: .downMirrored)
        }
            
        var event:[String:Any?] = ["name":"noData"];

        do {
            try
            imageRequestHandler.perform([VNDetectFaceRectanglesRequest { (request, error)in
                if error == nil {
                    
                    if let results = request.results as? [VNFaceObservation] {
                        var objects:[[String:Any?]] = []
                        for object in results {
                            objects.append(self.processObservation(object,imageSize))
                        }
                        event = [
                            "name": "faceDetect",
                            "data": objects,
                            "imageSize": [
                                "width": imageSize.width,
                                "height": imageSize.height
                            ]
                        ]
                    }
                } else {
                    event = ["name":"error","code": "No Object Detected", "message": error!.localizedDescription]
                    print(error!.localizedDescription)
                }
            }])
        } catch {
            event = ["name":"error","code": "Data Corropted", "message": error.localizedDescription]
            print(error)
        }

        return event;
    }
    
    #if os(iOS)
    @available(iOS 12.0, *)
    #endif
    func processObservation(_ observation: VNFaceObservation,_ imageSize: CGSize) -> [String:Any?] {
        // Retrieve all torso points.
        let recognizedPoints = observation.boundingBox
        let coord =  VNImagePointForNormalizedPoint(recognizedPoints.origin,
                                             Int(imageSize.width),
                                             Int(imageSize.height))
        return [
            "minX":Double(recognizedPoints.minX),
            "maxX":Double(recognizedPoints.maxX),
            "minY":Double(recognizedPoints.minY),
            "maxY":Double(recognizedPoints.maxX),
            "height":Double(recognizedPoints.height),
            "width":Double(recognizedPoints.width),
            "origin": ["x":coord.x,"y":coord.y]
        ]
    }
}
