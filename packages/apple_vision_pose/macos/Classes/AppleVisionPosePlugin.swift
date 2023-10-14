#if os(iOS)
import Flutter
#elseif os(macOS)
import FlutterMacOS
#endif
import Vision

public class AppleVisionPosePlugin: NSObject, FlutterPlugin {

    let registry: FlutterTextureRegistry
    
    init(_ registry: FlutterTextureRegistry) {
        self.registry = registry
        super.init()
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        #if os(iOS)
        let method = FlutterMethodChannel(name:"apple_vision/pose", binaryMessenger: registrar.messenger())
        let instance = AppleVisionPosePlugin(registrar.textures())
        #elseif os(macOS)
        let method = FlutterMethodChannel(name:"apple_vision/pose", binaryMessenger: registrar.messenger)
        let instance = AppleVisionPosePlugin(registrar.textures)
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
                if #available(iOS 14.0, *) {
                    return result(convertImage(Data(data.data),CGSize(width: width , height: height)))
                } else {
                    return result(FlutterError(code: "INVALID OS", message: "requires version 14.0", details: nil))
                }
            #elseif os(macOS)
                return result(convertImage(Data(data.data),CGSize(width: width , height: height)))
            #endif
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    // Gets called when a new image is added to the buffer
    #if os(iOS)
    @available(iOS 14.0, *)
    #endif
    func convertImage(_ data: Data,_ imageSize: CGSize) -> [String:Any?]{
        let imageRequestHandler = VNImageRequestHandler(
            data: data,
            orientation: .downMirrored)
        var event:[String:Any?] = ["name":"noData"];
        do {
            try imageRequestHandler.perform([VNDetectHumanBodyPoseRequest { (request, error) in
                if error == nil {
                    if let results = request.results as? [VNHumanBodyPoseObservation] {
                        for pose in results {
                            event = self.processObservation(pose,imageSize)
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

        return event
    }
    
    #if os(iOS)
    @available(iOS 14.0, *)
    #endif
    func processObservation(_ observation: VNHumanBodyPoseObservation,_ imageSize: CGSize) -> [String:Any?] {
        // Retrieve all torso points.
        guard let recognizedPoints =
                try? observation.recognizedPoints(.all) else { return ["name":"noData"]}
        
        // Torso joint names in a clockwise ordering.
        let torsoJointNames: [VNHumanBodyPoseObservation.JointName] = [
            .rightAnkle,
            .rightKnee,
            .rightHip,
            .rightWrist,
            .rightElbow,
            .rightShoulder,
            .rightEar,
            .rightEye,
            .nose,
            .neck,
            .leftEye,
            .leftEar,
            .leftShoulder,
            .leftElbow,
            .leftWrist,
            .leftHip,
            .leftKnee,
            .leftAnkle,
            .root
        ]
        
        // Retrieve the CGPoints containing the normalized X and Y coordinates.
        let imagePoints: [[String:Any?]] = torsoJointNames.compactMap {
            guard let point = recognizedPoints[$0], point.confidence > 0 else { return nil }
            
            // Translate the point from normalized-coordinates to image coordinates.
             let coord =  VNImagePointForNormalizedPoint(point.location,
                                                  Int(imageSize.width),
                                                  Int(imageSize.height))
            return [$0.rawValue.rawValue.description: ["x":coord.x ,"y":coord.y, "confidence": point.confidence]]
        }
            
        let event: [String: Any?] = [
            "name": "pose",
            "data" : imagePoints,
            "imageSize": ["width":imageSize.width ,"height":imageSize.height]
        ]
        
        return event
    }
}
