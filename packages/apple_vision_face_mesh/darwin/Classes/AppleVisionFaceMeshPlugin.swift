import AVFoundation
import Vision

#if os(iOS)
import Flutter
import UIKit
#elseif os(macOS)
import FlutterMacOS
import AppKit
#endif

public class AppleVisionFaceMeshPlugin: NSObject, FlutterPlugin {
    let registry: FlutterTextureRegistry
    var model:VNCoreMLModel?
    
    init(_ registry: FlutterTextureRegistry) {
        self.registry = registry
        super.init()
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        #if os(iOS)
        let method = FlutterMethodChannel(name:"apple_vision/face_mesh", binaryMessenger: registrar.messenger())
        let instance = AppleVisionFaceMeshPlugin(registrar.textures())
        #elseif os(macOS)
        let method = FlutterMethodChannel(name:"apple_vision/face_mesh", binaryMessenger: registrar.messenger)
        let instance = AppleVisionFaceMeshPlugin(registrar.textures)
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
                if #available(macOS 15.0, *) {
                    return result(convertImage(Data(data.data),CGSize(width: width , height: height),CIFormat.ARGB8,orientation))
                } else {
                    return result(FlutterError(code: "INVALID OS", message: "requires version 14.0", details: nil))
                }
            #endif
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    #if os(iOS)
    @available(iOS 14.0, *)
    #elseif os(macOS)
    @available(macOS 10.15, *)
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
            croppedImage = CIImage(bitmapData: data, bytesPerRow: Int(imageSize.width)*4, size: imageSize, format: format, colorSpace: nil).faceCrop(imageSize,orientation)
            if croppedImage.0 != nil{
                imageRequestHandler = VNImageRequestHandler(ciImage:croppedImage.0!)
            }
        }
        else{
            croppedImage = CIImage(data: data)!.faceCrop(imageSize,orientation)
            imageRequestHandler = VNImageRequestHandler(
                ciImage:croppedImage.0!)
        }

        if model == nil{
            model = AppleVisionFaceMeshPlugin.createFaceMesh()
        }
        if imageRequestHandler != nil{
            let imageRecognition = VNCoreMLRequest(model: model!, completionHandler: { (request, error) in
                if let results = request.results as? [VNCoreMLFeatureValueObservation] {
                    var meshData:Array = []
                    for observation in results {
                        let m:MLMultiArray? = observation.featureValue.multiArrayValue
                        if m != nil{
                            if let b = try? UnsafeBufferPointer<Float>(m!) {
                                meshData = Array(b)
                            }
                        }
                    }
                    var nsImage:Data?
                    #if os(iOS)
                        nsImage = UIImage(ciImage: croppedImage.0!).pngData()
                    #elseif os(macOS)
                    if croppedImage.0 != nil{
                        nsImage = NSBitmapImageRep(ciImage:croppedImage.0!).representation(using: .png,properties: [:])
                    }
                    #endif
                    
                    event = [
                        "name": "faceMesh",
                        "mesh": meshData,
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
    @available(macOS 10.15, *)
    #endif
    
    static func createFaceMesh() -> VNCoreMLModel {
        // Use a default model configuration.
        let defaultConfig = MLModelConfiguration()
        // Create an instance of the image classifier's wrapper class.
        let faceMeshWrapper = try? facemesh(configuration: defaultConfig)
        guard let faceMesh = faceMeshWrapper else {
            fatalError("App failed to create an image classifier model instance.")
        }
        // Get the underlying model instance.
        let faceMeshModel = faceMesh.model
        // Create a Vision instance using the image classifier's model instance.
        guard let faceMeshVisionModel = try? VNCoreMLModel(for: faceMeshModel) else {
            fatalError("App failed to create a `VNCoreMLModel` instance.")
        }
        return faceMeshVisionModel
    }
}

public extension CIImage {
    func scale(targetSize: CGSize = CGSize(width:192, height:192)) -> CIImage?{
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
    func faceCrop(_ imageSize: CGSize,_ orientation: CGImagePropertyOrientation, margin: CGSize = CGSize(width:40, height:60)) -> (CIImage?,CGRect?) {
        var ciImage:CIImage?
        var croppingRect:[CGRect]?
        let req = VNDetectFaceRectanglesRequest { request, error in
            guard let results = request.results, !results.isEmpty else {
                return
            }
            
            var faces: [VNFaceObservation] = []
            for result in results {
                guard let face = result as? VNFaceObservation else { continue }
                faces.append(face)
            }
            
            croppingRect = self.getCroppingRect(imageSize,for: faces, margin: margin)
            let faceImage = self.cropped(to: croppingRect![0]).scale()
            ciImage = faceImage
        }
        
        try? VNImageRequestHandler(ciImage: self, orientation: orientation, options: [:]).perform([req])
        
        return (ciImage,croppingRect?[0])
    }
    
    @available(iOS 14.0, *)
    private func getCroppingRect(_ imageSize: CGSize, for faces: [VNFaceObservation], margin: CGSize) -> [CGRect] {
        var rects:[CGRect] = []
        for face in faces {
            let points = face.boundingBox
            let coord =  VNImagePointForNormalizedPoint(points.origin,
                                                        Int(imageSize.width),
                                                        Int(imageSize.height))

            let boxSize = points.width > points.height ? points.width : points.height
            let imsize = imageSize.width > imageSize.height ? imageSize.width : imageSize.height
            
            rects.append(CGRect(
                x:coord.x-margin.height,
                y: coord.y-margin.height,
                width: boxSize*imsize, 
                height: boxSize*imsize
            ))
        }
        return rects
    }
}
