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
            let orientation = arguments["orientation"] as? String ?? "downMirrored"
            
            #if os(iOS)
                if #available(iOS 14.0, *) {
                    return result(convertImage(Data(data.data),CGSize(width: width , height: height),CIFormat.BGRA8,orientation))
                } else {
                    return result(FlutterError(code: "INVALID OS", message: "requires version 14.0", details: nil))
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
    @available(iOS 14.0, *)
    #endif
    func convertImage(_ data: Data,_ imageSize: CGSize,_ format: CIFormat,_ oriString: String) -> [String:Any?]{
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
            //event = ["name":"error","code": "Data Corropted", "message": "Error model did not load"]
        }
        else{
            let imageRecognition = VNCoreMLRequest(model: model!, completionHandler: { (request, error) in
                if let results = request.results as? [VNCoreMLFeatureValueObservation] {
                    var depthData:[Data?] = []
                    for observation in results {
                        let depthmap = observation.featureValue.multiArrayValue
                        
                        let convertedHeatmap = convertTo2DArray(from: depthmap!)

                        let average = Float32(convertedHeatmapInt.joined().reduce(0, +))/Float32(20480)

                        var originalImageOr:CIImage
                        if originalImage == nil{
                            originalImageOr = CIImage(data:data)!
                        }
                        else{
                            originalImageOr = originalImage!
                        }
                        
                        if depthmap != nil{
                            var ciImage = CIImage(cgImage: depthmap!.postProcessImage()!)
                            
                            // Scale the mask image to fit the bounds of the video frame.
                            let scaleX = originalImageOr.extent.width / ciImage.extent.width
                            let scaleY = originalImageOr.extent.height / ciImage.extent.height
                            ciImage = ciImage.transformed(by: .init(scaleX: scaleX, y: scaleY))
                            
                            let fileType = "raw"
#if os(iOS)
                            selfieData.append(ciImage?.cgImage?.dataProvider?.data as Data?)
#elseif os(macOS)
                            var format:NSBitmapImageRep.FileType?
                            switch fileType {
                            case "jpg":
                                format = NSBitmapImageRep.FileType.jpeg
                                break
                            case "jepg":
                                format = NSBitmapImageRep.FileType.jpeg2000
                                break
                            case "bmp":
                                format = NSBitmapImageRep.FileType.bmp
                                break
                            case "png":
                                format = NSBitmapImageRep.FileType.png
                                break
                            case "tiff":
                                format = NSBitmapImageRep.FileType.tiff
                                break
                            default:
                                format = nil
                            }
                            var nsImage:Data?
                            if format != nil{
                                nsImage = NSBitmapImageRep(ciImage:ciImage).representation(
                                    using: format!,
                                    properties: [
                                        NSBitmapImageRep.PropertyKey.currentFrame: NSBitmapImageRep.PropertyKey.currentFrame.self
                                    ]
                                )
                                depthData.append(nsImage)
                            }
                            else{
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
        }


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
    
    func convertTo2DArray(from heatmaps: MLMultiArray) -> Array<Array<Double>> {
        guard heatmaps.shape.count >= 3 else {
            print("heatmap's shape is invalid. \(heatmaps.shape)")
            return []
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
        
        let minmaxGap = maximumValue - minimumValue
        
        for i in 0..<heatmap_w {
            for j in 0..<heatmap_h {
                convertedHeatmap[j][i] = (convertedHeatmap[j][i] - minimumValue) / minmaxGap
            }
        }
        
        return convertedHeatmap
    }
}

extension MLMultiArray {

func postProcessImage(size: Int = 256) -> CGImage? {
    let rawPointer = malloc(size*size*3)!
    let bytes = rawPointer.bindMemory(to: UInt8.self, capacity: size*size*3)
    
    let mlArray = self.dataPointer.bindMemory(to: Float32.self, capacity: size*size*3)
    for index in 0..<self.count/(3) {
        bytes[index*3 + 0] = UInt8(max(min(mlArray[index]*255, 255), 0))
        bytes[index*3 + 1] = UInt8(max(min(mlArray[index + size*size]*255, 255), 0))
        bytes[index*3 + 2] = UInt8(max(min(mlArray[index + size*size*2]*255, 255), 0))
    }
    
    let selftureSize = size*size*3
    
    let provider = CGDataProvider(dataInfo: nil, data: rawPointer, size: selftureSize, releaseData: { (_, data, size) in
        data.deallocate()
    })!
   
    let rawBitmapInfo = CGImageAlphaInfo.none.rawValue
    let bitmapInfo = CGBitmapInfo(rawValue: rawBitmapInfo)
    let pColorSpace = CGColorSpaceCreateDeviceRGB()

    let rowBytesCount = size*3
    return CGImage(width: size, height: size, bitsPerComponent: 8, bitsPerPixel: 24, bytesPerRow: rowBytesCount, space: pColorSpace, bitmapInfo: bitmapInfo, provider: provider, decode: nil, shouldInterpolate: true, intent: CGColorRenderingIntent.defaultIntent)!
}

}
