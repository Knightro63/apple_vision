import Vision

#if os(iOS)
import Flutter
#elseif os(macOS)
import FlutterMacOS
#endif

import VideoToolbox
import CoreImage.CIFilterBuiltins

public class AppleVisionSaliencyPlugin: NSObject, FlutterPlugin {

    let registry: FlutterTextureRegistry
    
    init(_ registry: FlutterTextureRegistry) {
        self.registry = registry
        super.init()
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        #if os(iOS)
        let method = FlutterMethodChannel(name:"apple_vision/saliency", binaryMessenger: registrar.messenger())
        let instance = AppleVisionSaliencyPlugin(registrar.textures())
        #elseif os(macOS)
        let method = FlutterMethodChannel(name:"apple_vision/saliency", binaryMessenger: registrar.messenger)
        let instance = AppleVisionSaliencyPlugin(registrar.textures)
        #endif
        registrar.addMethodCallDelegate(instance, channel: method)
    }
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "process":
            guard let arguments = call.arguments as? [String:Any?],
            let data:FlutterStandardTypedData = arguments["image"] as? FlutterStandardTypedData else {
                result("Couldn't find image data")
                return
            }
            
            let width = arguments["width"] as? Double ?? 0
            let height = arguments["height"] as? Double ?? 0
            let pf = arguments["format"] as! String
            let type = arguments["type"] as! String
            let orientation = arguments["orientation"] as? String ?? "downMirrored"

            #if os(iOS)
                if #available(iOS 15.0, *) {
                    return result(convertImage(Data(data.data),CGSize(width: width , height: height),pf,CIFormat.BGRA8,orientation))
                } else {
                    return result(FlutterError(code: "INVALID OS", message: "requires version 15.0", details: nil))
                }
            #elseif os(macOS)
                return result(convertImage(Data(data.data),CGSize(width: width , height: height), pf,type,CIFormat.ARGB8,orientation))
            #endif
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    // Gets called when a new image is added to the buffer
    #if os(iOS)
    @available(iOS 15.0, *)
    #endif
    func convertImage(_ data: Data,_ imageSize: CGSize,_ fileType: String,_ type: String,_ format: CIFormat,_ oriString: String) -> [String:Any?]{
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
            
            imageRequestHandler = VNImageRequestHandler(ciImage:originalImage!,
                orientation: orientation)
        }
        else{
            imageRequestHandler = VNImageRequestHandler(
                data: data,
                orientation: orientation)
        }
        
        var SaliencyRequest:VNRequest? = nil
        var event:[String:Any?] = ["name":"noData"];
        if type == "attention"{
            SaliencyRequest = VNGenerateAttentionBasedSaliencyImageRequest(completionHandler: { (request, error) in
                if error == nil {
                    if let results = request.results as? [VNSaliencyImageObservation] {
                        event = self.process(results,imageSize,fileType)
                    } else {
                        event = ["name":"error","code": "No Face In Detected", "message": error!.localizedDescription]
                        print(error!.localizedDescription)
                    }
                }
            })
        }
        else {
            SaliencyRequest = VNGenerateObjectnessBasedSaliencyImageRequest(completionHandler: { (request, error) in
                if error == nil {
                    if let results = request.results as? [VNSaliencyImageObservation] {
                        event = self.process(results,imageSize,fileType)
                    } else {
                        event = ["name":"error","code": "No Face In Detected", "message": error!.localizedDescription]
                        print(error!.localizedDescription)
                    }
                }
            })
        }
        
        
        do {
            let requests: [VNRequest] = [SaliencyRequest!]
            try imageRequestHandler.perform(requests)
        } catch {
            event = ["name":"error","code": "Data Corropted", "message": error.localizedDescription]
            print(error)
        }

        return event
    }
    
    func process(_ results: [VNSaliencyImageObservation],_ imageSize: CGSize,_ fileType: String) -> [String: Any?]{
        var SaliencyData:[Data?] = []
        for Saliency in results {
            var maskImage = CIImage(cvPixelBuffer: Saliency.pixelBuffer)

            // Scale the mask image to fit the bounds of the video frame.
            let scaleX = imageSize.width / maskImage.extent.width
            let scaleY = imageSize.height / maskImage.extent.height
            maskImage = maskImage.transformed(by: .init(scaleX: scaleX, y: scaleY))
            
            #if os(iOS)
                SaliencyData.append(ciImage?.cgImage?.dataProvider?.data as Data?)
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
                    nsImage = NSBitmapImageRep(ciImage:maskImage).representation(
                        using: format!,
                        properties: [
                            NSBitmapImageRep.PropertyKey.currentFrame: NSBitmapImageRep.PropertyKey.currentFrame.self
                        ]
                    )
                    SaliencyData.append(nsImage)
                }
                else{
                    let u = NSBitmapImageRep(ciImage:maskImage)
                    let bytesPerRow = u.bytesPerRow
                    let height = Int(u.size.height)
                    
                    nsImage = Data(bytes: u.bitmapData!, count: Int(bytesPerRow*height))
                }
                SaliencyData.append(nsImage!)
            #endif
        }
        return [
            "name": "saliency",
            "data": SaliencyData,
        ]
    }
}
