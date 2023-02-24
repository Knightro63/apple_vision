import AVFoundation
import FlutterMacOS
import Vision
import AppKit

public class AppleVisionObjectPlugin: NSObject, FlutterPlugin {
    
    let registry: FlutterTextureRegistry
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = AppleVisionObjectPlugin(registrar.textures)
        let method = FlutterMethodChannel(name:"apple_vision/object", binaryMessenger: registrar.messenger)
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
            try
            imageRequestHandler.perform([VNTrackObjectRequest(de: inputObservations.value) { (request, error)in
                if error == nil {
                    
                    if let results = request.results as? [VNDetectedObjectObservation] {
                        for object in results {
                            event = self.processObservation(object,imageSize)
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
    
    func processObservation(_ observation: VNFaceObservation,_ imageSize: CGSize) -> [String:Any?] {
        // Retrieve all torso points.
        let recognizedPoints = observation.boundingBox
        let coord =  VNImagePointForNormalizedPoint(recognizedPoints.origin,
                                             Int(imageSize.width),
                                             Int(imageSize.height))
        let event: [String: Any?] = [
            "name": "object",
            "data" : [
                "minX":Double(recognizedPoints.minX),
                "maxX":Double(recognizedPoints.maxX),
                "minY":Double(recognizedPoints.minY),
                "maxY":Double(recognizedPoints.maxX),
                "height":Double(recognizedPoints.height),
                "width":Double(recognizedPoints.width),
                "origin": ["x":coord.x,"y":coord.y]
            ],
            "imageSize": ["width":imageSize.width ,"height":imageSize.height]
        ]
        
        return event
    }
}
