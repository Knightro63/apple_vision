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

        if data.count == (Int(imageSize.height)*Int(imageSize.width)*4){
            // Create a bitmap graphics context with the sample buffer data
            let context = CIImage(bitmapData: data, bytesPerRow: Int(imageSize.width)*4, size: imageSize, format: format, colorSpace: nil)//.faceCrop(imageSize)
            if context != nil{
                imageRequestHandler = VNImageRequestHandler(ciImage:context,orientation: orientation)
            }
        }
        else{
            imageRequestHandler = VNImageRequestHandler(
                data: data,
                orientation: orientation)
        }

        if model == nil{
            model = AppleVisionFaceMeshPlugin.createFaceMesh()
        }
        else if imageRequestHandler != nil{
            let imageRecognition = VNCoreMLRequest(model: model!, completionHandler: { (request, error) in
                if let results = request.results as? [VNCoreMLFeatureValueObservation] {
                    var meshData:[[String:Any?]] = []
                    for observation in results {
                        //print(observation)
                        let m:MLMultiArray? = observation.featureValue.multiArrayValue
                        if m != nil{
                            if let b = try? UnsafeBufferPointer<Float>(m!) {
                                meshData.append([
                                    "mesh" : Array(b),
                                    //"confidence": observation.featureValue.,
                                ])
                            }
                        }
                    }
                    event = [
                        "name": "faceMesh",
                        "data": meshData,
                        "imageSize": ["width":imageSize.width ,"height":imageSize.height]
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
    func scale(targetSize: NSSize = NSSize(width:192, height:192)) -> CIImage?{
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
    func faceCrop(_ imageSize: CGSize, margin: NSSize = NSSize(width:192, height:192)) -> CIImage? {
        var ciImage:CIImage?
        let req = VNDetectFaceRectanglesRequest { request, error in
            if let error = error {
                return
            }
            
            guard let results = request.results, !results.isEmpty else {
                return
            }
            
            var faces: [VNFaceObservation] = []
            for result in results {
                guard let face = result as? VNFaceObservation else { continue }
                faces.append(face)
            }
            
            let croppingRect = self.getCroppingRect(imageSize,for: faces, margin: margin)
            let faceImage = self.cropped(to: croppingRect)//.scale()
            ciImage = faceImage
        }
        
        do {
            try VNImageRequestHandler(ciImage: self, options: [:]).perform([req])
        } catch let error {

        }
        
        return ciImage
    }
    
    @available(iOS 14.0, *)
    private func getCroppingRect(_ imageSize: CGSize, for faces: [VNFaceObservation], margin: NSSize) -> CGRect {
        
        // 2
        var totalX = CGFloat(0)
        var totalY = CGFloat(0)
        var totalW = CGFloat(0)
        var totalH = CGFloat(0)
        
        // 3
        var minX = CGFloat.greatestFiniteMagnitude
        var minY = CGFloat.greatestFiniteMagnitude
        let numFaces = CGFloat(faces.count)
        
        // 4
        for face in faces {
            
            let points = face.boundingBox
            let coord =  VNImagePointForNormalizedPoint(points.origin,
                                                 Int(imageSize.width),
                                                 Int(imageSize.height))
            return CGRect(x:points.minX, y: points.minY, width: points.width+margin.width*imageSize.width, height: points.width+margin.height*imageSize.height)
            
            let boxSize = face.boundingBox.width > face.boundingBox.height ? face.boundingBox.width : face.boundingBox.height
            // 5
            let w = boxSize * CGFloat(imageSize.width)
            let h = boxSize * CGFloat(imageSize.height)
            let x = face.boundingBox.origin.x * CGFloat(imageSize.width)
            
            // 6
            let y = (1 - face.boundingBox.origin.y) * CGFloat(imageSize.height) - h
            
            totalX += x
            totalY += y
            totalW += w
            totalH += h
            minX = .minimum(minX, x)
            minY = .minimum(minY, y)
        }
        
        // 7
        let avgX = totalX / numFaces
        let avgY = totalY / numFaces
        let avgW = totalW / numFaces
        let avgH = totalH / numFaces
        
        // 8
        let offset = avgX - minX
        
        // 9
        return CGRect(x: avgX - offset - margin.width/2, y: avgY - offset-margin.height/2, width: avgW + ((offset+margin.width) * 2), height: avgH + ((offset+margin.height) * 2))
    }
}
