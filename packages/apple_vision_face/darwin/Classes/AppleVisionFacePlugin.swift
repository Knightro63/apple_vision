import AVFoundation
import Vision

#if os(iOS)
import Flutter
import UIKit
#elseif os(macOS)
import FlutterMacOS
import AppKit
#endif

public class AppleVisionFacePlugin: NSObject, FlutterPlugin {
    let registry: FlutterTextureRegistry
    
    init(_ registry: FlutterTextureRegistry) {
        self.registry = registry
        super.init()
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        #if os(iOS)
        let method = FlutterMethodChannel(name:"apple_vision/face", binaryMessenger: registrar.messenger())
        let instance = AppleVisionFacePlugin(registrar.textures())
        #elseif os(macOS)
        let method = FlutterMethodChannel(name:"apple_vision/face", binaryMessenger: registrar.messenger)
        let instance = AppleVisionFacePlugin(registrar.textures)
        #endif
        registrar.addMethodCallDelegate(instance, channel: method)
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
                if #available(iOS 13.0, *) {
                    return result(convertImage(Data(data.data),CGSize(width: width , height: height),CIFormat.BGRA8))
                } else {
                    return result(FlutterError(code: "INVALID OS", message: "requires version 13.0", details: nil))
                }
            #elseif os(macOS)
                return result(convertImage(Data(data.data),CGSize(width: width , height: height),CIFormat.ARGB8))
            #endif
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    #if os(iOS)
    @available(iOS 13.0, *)
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
            try imageRequestHandler.perform([VNDetectFaceLandmarksRequest { (request, error) in
                if error == nil {
                    if let results = request.results as? [VNFaceObservation] {
                        var faceData:[[String:Any?]] = []
                        for face in results {
                            faceData.append(self.processObservation(face,imageSize))
                        }
                        event = [
                            "name": "face",
                            "data": faceData,
                            "imageSize": ["width":imageSize.width ,"height":imageSize.height]
                        ]
                    }
                } else {
                    event = ["name":"error","code": "No Face In Detected", "message": error!.localizedDescription]
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
    @available(iOS 13.0, *)
    #endif
    func processObservation(_ face: VNFaceObservation,_ imageSize: CGSize) -> [String:Any?] {
        // Retrieve all torso points.
        let landmarksToDraw = [
            face.landmarks?.faceContour,
           face.landmarks?.outerLips,
           face.landmarks?.innerLips,
           face.landmarks?.leftEye,
           face.landmarks?.rightEye,
           face.landmarks?.leftPupil,
           face.landmarks?.rightPupil,
           face.landmarks?.leftEyebrow,
           face.landmarks?.rightEyebrow
        ]
        
        let marks: [String] = [
           "faceContour",
           "outerLips",
           "innerLips",
           "leftEye",
           "rightEye",
           "leftPupil",
           "rightPupil",
           "leftEyebrow",
           "rightEyebrow"
        ];
        
        var imagePoints: [[String:Any?]] = [];
        var i = 0
        for name in marks{
            var points: [[String:Any?]] = [];
            if let landmark = landmarksToDraw[i]{
                for j in 0...landmark.pointCount - 1 {
                    let coord =  VNImagePointForNormalizedPoint(landmarksToDraw[i]!.normalizedPoints[j],
                                                                Int(imageSize.width),
                                                                Int(imageSize.height))
                    points.append([
                        "x":landmarksToDraw[i]!.pointsInImage(imageSize: imageSize)[j].x,
                        "y":landmarksToDraw[i]!.pointsInImage(imageSize: imageSize)[j].y
                    ])
                }
                imagePoints.append([
                    name: points
                ]);
            }
            i+=1;
        }
        
        var pitch: Double?;
        #if os(iOS)
            if #available(iOS 15.0, *){
                pitch = face.pitch as! Double?
            }
        #elseif os(macOS)
            if #available(macOS 12.0, *){
                pitch = face.pitch as! Double?
            }
        #endif
        let data:[String: Any?] = [
            "yaw": face.yaw,
            "roll": face.roll,
            "pitch": pitch,
            "quailty": face.faceCaptureQuality
        ];
        
            
        let event: [String: Any?] = [
            "data" : imagePoints,
            "orientation": data,
        ]
        
        return event
    }
}
