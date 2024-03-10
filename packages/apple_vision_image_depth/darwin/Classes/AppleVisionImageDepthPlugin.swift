import AVFoundation
import Vision

#if os(iOS)
import Flutter
import UIKit
#elseif os(macOS)
import FlutterMacOS
import AppKit
#endif

public class AppleVisionImageDepthPlugin: NSObject, FlutterPlugin {
    
    let registry: FlutterTextureRegistry
    var model:VNCoreMLModel?
    var confidence:Double = 0.75

    init(_ registry: FlutterTextureRegistry) {
        self.registry = registry
        super.init()
    }

    public static func register(with registrar: FlutterPluginRegistrar) {
        #if os(iOS)
        let method = FlutterMethodChannel(name:"apple_vision/image_depth", binaryMessenger: registrar.messenger())
        let instance = AppleVisionImageDepthPlugin(registrar.textures())
        #elseif os(macOS)
        let method = FlutterMethodChannel(name:"apple_vision/image_depth", binaryMessenger: registrar.messenger)
        let instance = AppleVisionImageDepthPlugin(registrar.textures)
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
            confidence = arguments["confidence"] as? Double ?? 0.75
            let format = arguments["format"] as! String
            let orientation = arguments["orientation"] as? String ?? "downMirrored"
            
            #if os(iOS)
                if #available(iOS 14.0, *) {
                    return result(convertImage(Data(data.data),CGSize(width: width , height: height),CIFormat.BGRA8,orientation,format))
                } else {
                    return result(FlutterError(code: "INVALID OS", message: "requires version 14.0", details: nil))
                }
            #elseif os(macOS)
                return result(convertImage(Data(data.data),CGSize(width: width , height: height),CIFormat.ARGB8,orientation,format))
            #endif        
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    // Gets called when a new image is added to the buffer
    #if os(iOS)
    @available(iOS 14.0, *)
    #endif
    func convertImage(_ data: Data,_ imageSize: CGSize,_ format: CIFormat,_ oriString: String,_ fileType: String) -> [String:Any?]{
        var event:[String:Any?] = ["name":"noData"];
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

        var originalImage:CIImage?
        var min:Double = 0
        var max:Double = 1
        if data.count == (Int(imageSize.height)*Int(imageSize.width)*4){
            // Create a bitmap graphics context with the sample buffer data
            originalImage =  CIImage(bitmapData: data, bytesPerRow: Int(imageSize.width)*4, size: imageSize, format: format, colorSpace: nil)
            
            imageRequestHandler = VNImageRequestHandler(ciImage:originalImage!, orientation: orientation)
        }
        else{
            imageRequestHandler = VNImageRequestHandler(
                data: data,
                orientation: orientation)
        }

        if model == nil{
            model = AppleVisionImageDepthPlugin.createImageDepth()
        }

        let imageRecognition = VNCoreMLRequest(model: model!, completionHandler: { (request, error) in
            if let results = request.results as? [VNCoreMLFeatureValueObservation] {
                var depthData:[Data?] = []
                for observation in results {
                    let depthmap = observation.featureValue.multiArrayValue

                    var originalImageOr:CIImage
                    if originalImage == nil{
                        originalImageOr = CIImage(data:data)!
                    }
                    else{
                        originalImageOr = originalImage!
                    }
                    
                    if depthmap != nil{
                        (min, max) = self.getMinMax(from: depthmap!)
                        var ciImage = CIImage(cgImage: depthmap!.cgImage(min: min,max: max)!)
                        
                        // Scale the mask image to fit the bounds of the video frame.
                        let scaleX = originalImageOr.extent.width / ciImage.extent.width
                        let scaleY = originalImageOr.extent.height / ciImage.extent.height
                        ciImage = ciImage.transformed(by: .init(scaleX: scaleX, y: scaleY))

                    #if os(iOS)
                        var uiImage:Data?
                        switch fileType {
                            case "jpg":
                                uiImage = UIImage(ciImage: ciImage).jpegData(compressionQuality: 1.0)
                            case "jpeg":
                                uiImage = UIImage(ciImage: ciImage).jpegData(compressionQuality: 1.0)
                            case "bmp":
                                uiImage = nil
                            case "png":
                                uiImage = UIImage(ciImage: ciImage).pngData()
                            case "tiff":
                                uiImage = nil
                            default:
                            uiImage = nil
                        }
                        
                        if uiImage == nil{
                            let ciContext = CIContext()
                            let rowBytes = 4 * Int(ciImage.extent.width) // 4 channels (RGBA) of 8-bit data
                            let dataSize = rowBytes * Int(ciImage.extent.height)
                            var data = Data(count: dataSize)
                            data.withUnsafeMutableBytes { data in
                                ciContext.render(ciImage, toBitmap: data, rowBytes: rowBytes, bounds: ciImage.extent, format: .RGBA8, colorSpace: CGColorSpace(name: CGColorSpace.sRGB)!)
                            }
                            if fileType == "bmp"{
                                uiImage = rgba2bitmap(
                                    data,
                                    Int(ciImage.extent.width),
                                    Int(ciImage.extent.height)
                                )
                            }
                            else{
                                uiImage = data
                            }
                        }
                        depthData.append(ciImage?.cgImage?.dataProvider?.data as Data?)
                    #elseif os(macOS)
                        var nsImage:Data?
                        switch fileType {
                            case "jpg":
                                nsImage = NSBitmapImageRep(ciImage:ciImage).representation(
                                    using: .jpeg,
                                    properties: [:]
                                )
                            case "jpeg":
                                nsImage = NSBitmapImageRep(ciImage:ciImage).representation(
                                    using: .jpeg2000,
                                    properties: [:]
                                )
                            case "bmp":
                                nsImage = NSBitmapImageRep(ciImage:ciImage).representation(
                                    using: .bmp,
                                    properties: [:]
                                )
                            case "png":
                                nsImage = NSBitmapImageRep(ciImage:ciImage).representation(
                                    using: .png,
                                    properties: [:]
                                )
                            case "tiff":
                                nsImage = NSBitmapImageRep(ciImage:ciImage).representation(
                                    using: .tiff,
                                    properties: [:]
                                )
                            default:
                                nsImage = nil
                        }
                        if nsImage == nil{
                            let u = NSBitmapImageRep(ciImage:ciImage)
                            let bytesPerRow = u.bytesPerRow
                            let height = Int(u.size.height)
                            
                            nsImage = Data(bytes: u.bitmapData!, count: Int(bytesPerRow*height))
                        }
                        depthData.append(nsImage!)
                    #endif
                    }
                }
                event = [
                    "name": "imageDepth",
                    "data": depthData,
                    "max": max,
                    "min":min,
                    "imageSize": [
                        "width": imageSize.width,
                        "height": imageSize.height
                    ]
                ]
            }
        })
        let requests: [VNRequest] = [imageRecognition]
        // Start the image classification request.
        try? imageRequestHandler.perform(requests)

        return event;
    }

    #if os(iOS)
    @available(iOS 14.0, *)
    #endif
    static func createImageDepth() -> VNCoreMLModel {
        // Use a default model configuration.
        let defaultConfig = MLModelConfiguration()
        // Create an instance of the image classifier's wrapper class.
        let imageDepthWrapper = try? FCRN(configuration: defaultConfig)
        guard let imageDepth = imageDepthWrapper else {
            fatalError("App failed to create an image classifier model instance.")
        }
        // Get the underlying model instance.
        let imageDepthModel = imageDepth.model
        // Create a Vision instance using the image classifier's model instance.
        guard let imageDepthVisionModel = try? VNCoreMLModel(for: imageDepthModel) else {
            fatalError("App failed to create a `VNCoreMLModel` instance.")
        }
        return imageDepthVisionModel
    }
    func getMinMax(from heatmaps: MLMultiArray) -> (Double, Double) {
        guard heatmaps.shape.count >= 3 else {
            print("heatmap's shape is invalid. \(heatmaps.shape)")
            return (0, 0)
        }
        let _/*keypoint_number*/ = heatmaps.shape[0].intValue
        let heatmap_w = heatmaps.shape[1].intValue
        let heatmap_h = heatmaps.shape[2].intValue
        
        var convertedHeatmap: Array<Array<Double>> = Array(repeating: Array(repeating: 0.0, count: heatmap_w), count: heatmap_h)
        
        var minimumValue: Double = Double.greatestFiniteMagnitude
        var maximumValue: Double = -Double.greatestFiniteMagnitude
        
        for i in 0..<heatmap_w {
            for j in 0..<heatmap_h {
                let index = i*(heatmap_h) + j
                let confidence = heatmaps[index].doubleValue
                guard confidence > 0 else { continue }
                convertedHeatmap[j][i] = confidence
                
                if minimumValue > confidence {
                    minimumValue = confidence
                }
                if maximumValue < confidence {
                    maximumValue = confidence
                }
            }
        }
        
        return (minimumValue,maximumValue)
    }
}
