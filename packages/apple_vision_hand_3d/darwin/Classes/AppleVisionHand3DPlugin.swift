import AVFoundation
import Vision

#if os(iOS)
import Flutter
import UIKit
#elseif os(macOS)
import FlutterMacOS
import AppKit
#endif

public class AppleVisionHand3DPlugin: NSObject, FlutterPlugin {
    let registry: FlutterTextureRegistry
    var modelPoints:VNCoreMLModel?

    init(_ registry: FlutterTextureRegistry) {
        self.registry = registry
        super.init()
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        #if os(iOS)
        let method = FlutterMethodChannel(name:"apple_vision/hand_3d", binaryMessenger: registrar.messenger())
        let instance = AppleVisionHand3DPlugin(registrar.textures())
        #elseif os(macOS)
        let method = FlutterMethodChannel(name:"apple_vision/hand_3d", binaryMessenger: registrar.messenger)
        let instance = AppleVisionHand3DPlugin(registrar.textures)
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
                if #available(iOS 14.0, *) {
                    return result(convertImage(Data(data.data),CGSize(width: width , height: height),CIFormat.BGRA8,orientation))
                } else {
                    return result(FlutterError(code: "INVALID OS", message: "requires version 14.0", details: nil))
                }
            #elseif os(macOS)
                if #available(iOS 14.0, *) {
                    return result(convertImage(Data(data.data),CGSize(width: width , height: height),CIFormat.ARGB8,orientation))
                } else {
                    return result(FlutterError(code: "INVALID OS", message: "requires version 11.0", details: nil))
                }
            #endif
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    #if os(iOS)
    @available(iOS 14.0, *)
    #elseif os(macOS)
    @available(macOS 11.0, *)
    #endif
    func convertImage(_ data: Data,_ imageSize: CGSize,_ format: CIFormat,_ oriString: String) -> [String:Any?]{
        var event:[String:Any?] = ["name":"noData"];
        var imageRequestHandler:VNImageRequestHandler?

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
        
        var croppedImage:(CIImage?,CGRect?)
        
        if data.count == (Int(imageSize.height)*Int(imageSize.width)*4){
            // Create a bitmap graphics context with the sample buffer data
            croppedImage = CIImage(bitmapData: data, bytesPerRow: Int(imageSize.width)*4, size: imageSize, format: format, colorSpace: nil).handCrop(imageSize,orientation)
            if croppedImage.0 != nil{
                imageRequestHandler = VNImageRequestHandler(ciImage:croppedImage.0!)
            }
        }
        else{
            croppedImage = CIImage(data: data)!.handCrop(imageSize,orientation)
            imageRequestHandler = VNImageRequestHandler(ciImage:croppedImage.0!)
        }

        if modelPoints == nil{
            modelPoints = AppleVisionHand3DPlugin.createHandMesh()
        }
        if imageRequestHandler != nil{
            let imageRecognition = VNCoreMLRequest(model: modelPoints!, completionHandler: { (request, error) in
                if let results = request.results as? [VNCoreMLFeatureValueObservation] {
                    var meshData:Array = []
                    var confidence:Float = 0
                    for observation in results {
                        let m:MLMultiArray? = observation.featureValue.multiArrayValue
                        if m != nil{
                            if let b = try? UnsafeBufferPointer<Float>(m!) {
                                if b.count >= 63{
                                    meshData = Array(b)
                                }
                                else if b.count == 1{
                                    confidence = Array(b)[0]
                                }
                            }
                        }
                    }

                    var nsImage:Data?
                    if croppedImage.0 != nil{
                        nsImage = NSBitmapImageRep(ciImage:croppedImage.0!).representation(using: .png,properties: [:])
                    }
                    
                    event = [
                        "name": "handMesh",
                        "mesh": meshData,
                        "confidence": confidence,
                        "croppedImage": nsImage,
                        "origin": ["x": croppedImage.1?.origin.x, "y": croppedImage.1?.origin.y],
                        "imageSize": ["width":croppedImage.1?.width ,"height":croppedImage.1?.height]
                    ]
                }
            })
            let requests: [VNRequest] = [imageRecognition]
            // Start the image classification request.
            try? imageRequestHandler!.perform(requests)
        }

        return event;
    }
    
    #if os(iOS)
    @available(iOS 14.0, *)
    #elseif os(macOS)
    @available(macOS 11.0, *)
    #endif
    static func createHandMesh() -> VNCoreMLModel {
        // Use a default model configuration.
        let defaultConfig = MLModelConfiguration()
        // Create an instance of the image classifier's wrapper class.
        let meshW = try? BlazeLandmarks(configuration: defaultConfig)
        guard let handMesh = meshW else {
            fatalError("App failed to create an image classifier model instance.")
        }
        // Get the underlying model instance.
        let handModel = handMesh.model
        // Create a Vision instance using the image classifier's model instance.
        guard let handMeshVisionModel = try? VNCoreMLModel(for: handModel) else {
            fatalError("App failed to create a `VNCoreMLModel` instance.")
        }
        return handMeshVisionModel
    }
}

public extension CIImage {
    func scale(targetSize: NSSize = NSSize(width:256, height:256)) -> CIImage?{
        let resizeFilter = CIFilter(name:"CILanczosScaleTransform")!

        // Compute scale and corrective aspect ratio
        let scale = targetSize.height / (self.extent.height)
        let aspectRatio = targetSize.width/((self.extent.width) * scale)

        // Apply resizing
        resizeFilter.setValue(self, forKey: kCIInputImageKey)
        resizeFilter.setValue(scale, forKey: kCIInputScaleKey)
        resizeFilter.setValue(aspectRatio, forKey: kCIInputAspectRatioKey)
        return resizeFilter.outputImage
    }
    
    @available(iOS 14.0, *)
    func handCrop(_ imageSize: CGSize,_ orientation: CGImagePropertyOrientation, margin: NSSize = NSSize(width:40, height:60)) -> (CIImage?,CGRect?) {
        var ciImage:CIImage?
        var croppingRect:[CGRect]?
        let req = VNDetectHumanHandPoseRequest { request, error in
            guard let results = request.results, !results.isEmpty else {
                return
            }
            
            var hands: [VNHumanHandPoseObservation] = []
            for result in results {
                guard let hand = result as? VNHumanHandPoseObservation else { continue }
                hands.append(hand)
            }
            
            croppingRect = self.getCroppingRect(imageSize,for: hands, margin: margin)
            let faceImage = self.cropped(to: croppingRect![0]).scale()
            ciImage = faceImage
        }
        
        try? VNImageRequestHandler(ciImage: self, orientation: orientation, options: [:]).perform([req])
        
        return (ciImage,croppingRect?[0])
    }
    
    @available(iOS 14.0, *)
    private func getCroppingRect(_ imageSize: CGSize, for hands: [VNHumanHandPoseObservation], margin: NSSize) -> [CGRect] {
        var rects:[CGRect] = []
        
        var xmin:CGFloat? = nil
        var xmax:CGFloat? = nil
        var ymin:CGFloat? = nil
        var ymax:CGFloat? = nil
        
        for hand in hands {
            // Retrieve all torso points.
            guard let recognizedPoints = try? hand.recognizedPoints(.all) else {
                break
            }
                
            recognizedPoints.forEach { (key: VNHumanHandPoseObservation.JointName, value: VNRecognizedPoint) in
                let coord =  VNImagePointForNormalizedPoint(value.location,Int(imageSize.width),Int(imageSize.height))
                
                if xmin == nil || xmin! > coord.x{
                    xmin = coord.x
                }
                if xmax == nil || xmax! < coord.x{
                    xmax = coord.x
                }
                if ymin == nil || ymin! > coord.y{
                    ymin = coord.y
                }
                if ymax == nil || ymax! < coord.y{
                    ymax = coord.y
                }
            }

            let boxSize = xmax!-xmin! > ymax!-ymin! ? xmax!-xmin! : ymax!-ymin!

            let origin:CGPoint = CGPoint(x: CGFloat(xmin!-margin.height/2), y: CGFloat(ymin!-margin.height/2))
            let size:CGSize = CGSize(width: CGFloat(boxSize+margin.height), height: CGFloat(boxSize+margin.height))
            
            rects.append(CGRect(origin: origin, size: size))
        }
        return rects
    }
}
