import AVFoundation
import FlutterMacOS
import Vision
import AppKit

public class AppleVisionImageClassificationPlugin: NSObject, FlutterPlugin {
    
    let registry: FlutterTextureRegistry
    var model:VNCoreMLModel?
    var confidence:Double = 0.75
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = AppleVisionImageClassificationPlugin(registrar.textures)
        let method = FlutterMethodChannel(name:"apple_vision/image_classification", binaryMessenger: registrar.messenger)
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
            confidence = arguments["confidence"] as? Double ?? 0.75
            return result(convertImage(Data(data.data),CGSize(width: width , height: height)))
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    // Gets called when a new image is added to the buffer
    func convertImage(_ data: Data,_ imageSize: CGSize) -> [String:Any?]{
        var event:[String:Any?] = ["name":"noData"];
        let handler = VNImageRequestHandler(
            data: data,
            orientation: .downMirrored)

        if model == nil{
            model = AppleVisionImageClassificationPlugin.createImageClassifier()
            //event = ["name":"error","code": "Data Corropted", "message": "Error model did not load"]
        }
        else{
            let imageRecognition = VNCoreMLRequest(model: model!, completionHandler: { (request, error) in
                if let results = request.results as? [VNClassificationObservation] {
                    var classes:[[String:Any?]] = []
                    for observation in results {
                        let temp = self.processObservation(observation,imageSize)
                        
                        if temp != nil{
                            classes.append(temp!)
                        }
                    }
                    event = [
                        "name": "imageClassify",
                        "data": classes,
                        "imageSize": [
                            "width": imageSize.width,
                            "height": imageSize.height
                        ]
                    ]
                }
            })
            let requests: [VNRequest] = [imageRecognition]
            // Start the image classification request.
            try? handler.perform(requests)
        }


        return event;
    }
    /// - Tag: name
    static func createImageClassifier() -> VNCoreMLModel {
        // Use a default model configuration.
        let defaultConfig = MLModelConfiguration()
        // Create an instance of the image classifier's wrapper class.
        let imageClassifierWrapper = try? MobileNetV2Int8LUT(configuration: defaultConfig)
        guard let imageClassifier = imageClassifierWrapper else {
            fatalError("App failed to create an image classifier model instance.")
        }
        // Get the underlying model instance.
        let imageClassifierModel = imageClassifier.model
        // Create a Vision instance using the image classifier's model instance.
        guard let imageClassifierVisionModel = try? VNCoreMLModel(for: imageClassifierModel) else {
            fatalError("App failed to create a `VNCoreMLModel` instance.")
        }
        return imageClassifierVisionModel
    }
    func processObservation(_ observation: VNClassificationObservation,_ imageSize: CGSize) -> [String:Any?]? {
        
        if observation.confidence > 0.75{
            return [
                "label":observation.identifier,
                "confidence": observation.confidence
            ]
        }
        return nil
    }
}
