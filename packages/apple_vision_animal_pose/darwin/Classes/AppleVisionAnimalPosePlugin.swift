#if os(iOS)
import Flutter
#elseif os(macOS)
import FlutterMacOS
#endif
import Vision

public class AppleVisionAnimalPosePlugin: NSObject, FlutterPlugin {

    let registry: FlutterTextureRegistry
    
    init(_ registry: FlutterTextureRegistry) {
        self.registry = registry
        super.init()
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        #if os(iOS)
        let method = FlutterMethodChannel(name:"apple_vision/animal_pose", binaryMessenger: registrar.messenger())
        let instance = AppleVisionAnimalPosePlugin(registrar.textures())
        #elseif os(macOS)
        let method = FlutterMethodChannel(name:"apple_vision/animal_pose", binaryMessenger: registrar.messenger)
        let instance = AppleVisionAnimalPosePlugin(registrar.textures)
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
                if #available(iOS 17.0, *) {
                    return result(convertImage(Data(data.data),CGSize(width: width , height: height),CIFormat.BGRA8,orientation))
                } else {
                    return result(FlutterError(code: "INVALID OS", message: "requires version 17.0", details: nil))
                }
            #elseif os(macOS)
                return result(convertImage(Data(data.data),CGSize(width: width , height: height),CIFormat.ARGB8,orientation))
            #endif
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    // Gets called when a new image is added to the buffer
    #if os(iOS)
    @available(iOS 17.0, *)
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
            
            imageRequestHandler = VNImageRequestHandler(ciImage:context, orientation: orientation)
        }
        else{
            imageRequestHandler = VNImageRequestHandler(data: data, orientation: orientation)
        }
        var event:[String:Any?] = ["name":"noData"];
        do {
            try imageRequestHandler.perform([VNDetectAnimalBodyPoseRequest { (request, error) in
                if error == nil {
                    if let results = request.results as? [VNAnimalBodyPoseObservation] {
                        var poseData:[[[String:Any?]]] = []
                        for pose in results {
                            poseData.append(self.processObservation(pose,imageSize))
                        }
                        event = [
                            "name": "animalPose",
                            "data": poseData
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

        return event
    }
    
    #if os(iOS)
    @available(iOS 17.0, *)
    #endif
    func processObservation(_ observation: VNAnimalBodyPoseObservation,_ imageSize: CGSize) -> [[String:Any?]] {
        // Retrieve all torso points.
        guard let recognizedPoints =
                try? observation.recognizedPoints(.all) else { return [[:]]}
        
        // Torso joint names in a clockwise ordering.
        let torsoJointNames: [VNAnimalBodyPoseObservation.JointName] = [
            .rightBackElbow,
            //.rightFronElbow,
            .rightBackKnee,
            .rightFrontKnee,
            .rightBackPaw,
            .rightFrontPaw,

            .rightEarTop,
            .rightEarMiddle,
            .rightEarBottom,
            .rightEye,
            .nose,
            .neck,
            .leftEye,
            .leftEarTop,
            .leftEarMiddle,
            .leftEarBottom,

            .leftBackElbow,
            //.leftFronElbow,
            .leftBackKnee,
            .leftFrontKnee,
            .leftBackPaw,
            .leftFrontPaw,

            .tailTop,
            .tailMiddle,
            .tailBottom
        ]

        var pointData:[[String:Any?]] = []
        // Retrieve the CGPoints containing the normalized X and Y coordinates.
        let _: [[String:Any?]] = torsoJointNames.compactMap {
            guard let point = recognizedPoints[$0], point.confidence > 0 else { return nil }
            
            // Translate the point from normalized-coordinates to image coordinates.
             let coord =  VNImagePointForNormalizedPoint(point.location,
                                                  Int(imageSize.width),
                                                  Int(imageSize.height))

            pointData.append(["description": $0.rawValue.rawValue.description,"x":coord.x ,"y":coord.y, "confidence": point.confidence])
            return [$0.rawValue.rawValue.description: ["x":coord.x ,"y":coord.y, "confidence": point.confidence]]
        }
        
        return pointData
    }
}
