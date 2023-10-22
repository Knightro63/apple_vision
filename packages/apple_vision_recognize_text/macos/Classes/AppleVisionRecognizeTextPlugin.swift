import AVFoundation
import FlutterMacOS
import Vision
import AppKit

public class AppleVisionRecognizeTextPlugin: NSObject, FlutterPlugin {
    
    let registry: FlutterTextureRegistry
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = AppleVisionRecognizeTextPlugin(registrar.textures)
        let method = FlutterMethodChannel(name:"apple_vision/recognize_text", binaryMessenger: registrar.messenger)
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
            return result(convertImage(Data(data.data),CGSize(width: width , height: height),candidates))
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    // Gets called when a new image is added to the buffer
    func convertImage(_ data: Data,_ imageSize: CGSize, _ candidates: Int) -> [String:Any?]{
        let imageRequestHandler = VNImageRequestHandler(
            data: data,
            orientation: .down)
            
        var event:[String:Any?] = ["name":"noData"];

        do {
            try
            imageRequestHandler.perform([VNRecognizeTextRequest { (request, error)in
                if error == nil {
                    
                    if let results = request.results as? [VNRecognizedTextObservation] {
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
            }])
        } catch {
            event = ["name":"error","code": "Data Corropted", "message": error.localizedDescription]
            print(error)
        }

        return event;
    }
    
    func processObservation(_ observation: VNRecognizedTextObservation,_ imageSize: CGSize, _ candidates: Int) -> [String:Any?] {
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
            "origin": ["x":(imageSize.width-coord.x)-(recognizedPoints.width*imageSize.width),"y":coord.y],
            "text": observation.topCandidates(candidates).map {  text in
                text.string
            }
        ]
    }
}
