import AVFoundation
import FlutterMacOS
import Vision
import AppKit

public class AppleVisionFacePlugin: NSObject, FlutterPlugin {
    let registry: FlutterTextureRegistry
    
    init(_ registry: FlutterTextureRegistry) {
        self.registry = registry
        super.init()
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let method = FlutterMethodChannel(name:"apple_vision/face", binaryMessenger: registrar.messenger)
        let instance = AppleVisionFacePlugin(registrar.textures)
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
            return result(convertImage(Data(data.data),CGSize(width: width , height: height)))
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    
    func convertImage(_ data: Data,_ imageSize: CGSize) -> [String:Any?]{
        let imageRequestHandler = VNImageRequestHandler(
            data: data,
            orientation: .up)

        var event:[String:Any?] = ["name":"noData"];
        do {
            try imageRequestHandler.perform([VNDetectFaceLandmarksRequest { (request, error) in
                if error == nil {
                    
                    if let results = request.results as? [VNFaceObservation] {
                        for face in results {
                            event = self.processObservation(face,imageSize)
                        }
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
        
        var marks: [String] = [
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
        if #available(macOS 12.0, *){
            pitch = face.pitch as! Double?
        }
        
        let data:[String: Any?] = [
            "yaw": face.yaw,
            "roll": face.roll,
            "pitch": pitch,
            "quailty": face.faceCaptureQuality
        ];
        
            
        let event: [String: Any?] = [
            "name": "face",
            "data" : imagePoints,
            "orientation": data,
            "imageSize": ["width":imageSize.width ,"height":imageSize.height]
        ]
        
        return event
    }
}
