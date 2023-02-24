import FlutterMacOS
import Vision

public class AppleVisionHandPlugin: NSObject, FlutterPlugin {
    let registry: FlutterTextureRegistry
    
    init(_ registry: FlutterTextureRegistry) {
        self.registry = registry
        super.init()
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let method = FlutterMethodChannel(name:"apple_vision/hand", binaryMessenger: registrar.messenger)
        let instance = AppleVisionHandPlugin(registrar.textures)
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
    
    
    // Gets called when a new image is added to the buffer
    func convertImage(_ data: Data,_ imageSize: CGSize) -> [String:Any?]{
        let imageRequestHandler = VNImageRequestHandler(
            data: data,
            orientation: .up)
        
        var event:[String:Any?] = ["name":"noData"];

        do {
            try imageRequestHandler.perform([VNDetectHumanHandPoseRequest { (request, error) in
                if error == nil {
                    
                    if let results = request.results as? [VNHumanHandPoseObservation] {
                        for hand in results {
                            event = self.processObservation(hand,imageSize)
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
    
    func processObservation(_ observation: VNHumanHandPoseObservation,_ imageSize: CGSize) -> [String:Any?]{
        // Retrieve all torso points.
        guard let recognizedPoints =
                try? observation.recognizedPoints(.all) else { return ["name":"noData"]}
        
        // Torso joint names in a clockwise ordering.
        let handJointNames: [VNHumanHandPoseObservation.JointName] = [
            .thumbIP,
            .thumbMP,
            .thumbCMC,
            .thumbTip,
            
            .indexDIP,
            .indexMCP,
            .indexPIP,
            .indexTip,
            
            .middleDIP,
            .middleMCP,
            .middlePIP,
            .middleTip,
            
            .ringDIP,
            .ringMCP,
            .ringPIP,
            .ringTip,
            
            .littleDIP,
            .littleMCP,
            .littlePIP,
            .littleTip
        ]
        
        // Retrieve the CGPoints containing the normalized X and Y coordinates.
        let imagePoints: [[String:Any?]] = handJointNames.compactMap {
            guard let point = recognizedPoints[$0], point.confidence > 0 else { return nil }
            
            // Translate the point from normalized-coordinates to image coordinates.
             let coord =  VNImagePointForNormalizedPoint(point.location,
                                                  Int(imageSize.width),
                                                  Int(imageSize.height))
            return [$0.rawValue.rawValue: ["x":coord.x ,"y":coord.y, "confidence": point.confidence]]
        }
            
        let event: [String: Any?] = [
            "name": "hand",
            "data" : imagePoints,
            "imageSize": ["width":imageSize.width ,"height":imageSize.height]
        ]
        
        return event
    }
}
