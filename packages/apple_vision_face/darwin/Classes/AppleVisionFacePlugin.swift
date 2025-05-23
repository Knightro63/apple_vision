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
            let orientation = arguments["orientation"] as? String ?? "downMirrored"

            #if os(iOS)
                if #available(iOS 13.0, *) {
                    return result(convertImage(Data(data.data),CGSize(width: width , height: height),CIFormat.BGRA8,orientation))
                } else {
                    return result(FlutterError(code: "INVALID OS", message: "requires version 13.0", details: nil))
                }
            #elseif os(macOS)
                return result(convertImage(Data(data.data),CGSize(width: width , height: height),CIFormat.ARGB8,orientation))
            #endif
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    #if os(iOS)
    @available(iOS 13.0, *)
    #endif
    func convertImage(_ data: Data,_ imageSize: CGSize,_ format: CIFormat,_ oriString: String) -> [String:Any?]{
        let imageRequestHandler:VNImageRequestHandler

        var orientation:CGImagePropertyOrientation = CGImagePropertyOrientation.downMirrored
        switch oriString{
            case "down":
                orientation = CGImagePropertyOrientation.down
                break
            case "right":
                orientation = CGImagePropertyOrientation.right
                break
            case "rightMirrored":
                orientation = CGImagePropertyOrientation.rightMirrored
                break
            case "left":
                orientation = CGImagePropertyOrientation.left
                break
            case "leftMirrored":
                orientation = CGImagePropertyOrientation.leftMirrored
                break
            case "up":
                orientation = CGImagePropertyOrientation.up
                break
            case "upMirrored":
                orientation = CGImagePropertyOrientation.upMirrored
                break
            default:
                orientation = CGImagePropertyOrientation.downMirrored
                break
        }

        if data.count == (Int(imageSize.height)*Int(imageSize.width)*4){
            // Create a bitmap graphics context with the sample buffer data
            let context =  CIImage(bitmapData: data, bytesPerRow: Int(imageSize.width)*4, size: imageSize, format: format, colorSpace: nil)
            
            imageRequestHandler = VNImageRequestHandler(ciImage:context,orientation: orientation)
        }
        else{
            imageRequestHandler = VNImageRequestHandler(
                data: data,
                orientation: orientation)
        }

        var event:[String:Any?] = [
            "name":"noData",
            "imageSize": ["width":imageSize.width ,"height":imageSize.height]
        ];
        do {
            try imageRequestHandler.perform([VNDetectFaceCaptureQualityRequest { (request, error) in
                if error == nil {
                    if let results = request.results as? [VNFaceObservation] {
                        var faceData:[[String:Any?]] = []
                        for face in results {
                            faceData.append(self.assessFaceCaptureQuality(face,imageSize))
                        }
                        event["orientation"] = faceData;
                    }
                } else {
                    event = ["name":"error","code": "No Face In Detected", "message": error!.localizedDescription]
                    print(error!.localizedDescription)
                }
            }])
            
            try imageRequestHandler.perform([VNDetectFaceLandmarksRequest { (request, error) in
                if error == nil {
                    if let results = request.results as? [VNFaceObservation] {
                        var faceData:[[String:Any?]] = []
                        for face in results {
                            faceData.append(self.processObservation(face,imageSize))
                        }
                        event["name"] = "face";
                        event["data"] = faceData;
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
    func assessFaceCaptureQuality(_ face: VNFaceObservation,_ imageSize: CGSize) -> [String:Any?] {
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
        
        return data
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
        
        let event: [String: Any?] = [
            "data" : imagePoints,
        ]
        
        return event
    }
}
