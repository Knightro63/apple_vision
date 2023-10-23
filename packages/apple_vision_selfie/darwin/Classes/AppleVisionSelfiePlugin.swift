import Vision

#if os(iOS)
import Flutter
#elseif os(macOS)
import FlutterMacOS
#endif

import VideoToolbox

public class AppleVisionSelfiePlugin: NSObject, FlutterPlugin {

    let registry: FlutterTextureRegistry
    
    init(_ registry: FlutterTextureRegistry) {
        self.registry = registry
        super.init()
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        #if os(iOS)
        let method = FlutterMethodChannel(name:"apple_vision/selfie", binaryMessenger: registrar.messenger())
        let instance = AppleVisionSelfiePlugin(registrar.textures())
        #elseif os(macOS)
        let method = FlutterMethodChannel(name:"apple_vision/selfie", binaryMessenger: registrar.messenger)
        let instance = AppleVisionSelfiePlugin(registrar.textures)
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
            var pictureFormat = NSBitmapImageRep.FileType.tiff
            switch arguments["format"] as! String{
                case "jpg":
                    pictureFormat = NSBitmapImageRep.FileType.jpeg
                    break
                case "jepg":
                    pictureFormat = NSBitmapImageRep.FileType.jpeg2000
                    break
                case "bmp":
                    pictureFormat = NSBitmapImageRep.FileType.bmp
                    break
                case "png":
                    pictureFormat = NSBitmapImageRep.FileType.png
                    break
                default:
                    pictureFormat = NSBitmapImageRep.FileType.tiff
                    break
            }
            
            let width = arguments["width"] as? Double ?? 0
            let height = arguments["height"] as? Double ?? 0
            #if os(iOS)
                if #available(iOS 15.0, *) {
                    return result(convertImage(Data(data.data),CGSize(width: width , height: height)))
                } else {
                    return result(FlutterError(code: "INVALID OS", message: "requires version 15.0", details: nil))
                }
            #elseif os(macOS)
            return result(convertImage(Data(data.data),CGSize(width: width , height: height), pictureFormat))
            #endif
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    // Gets called when a new image is added to the buffer
    #if os(iOS)
    @available(iOS 15.0, *)
    #endif
    func convertImage(_ data: Data,_ imageSize: CGSize, _ format: NSBitmapImageRep.FileType) -> [String:Any?]{
        let imageRequestHandler = VNImageRequestHandler(
            data: data,
            orientation: .up)
        var event:[String:Any?] = ["name":"noData"];
        do {
            try imageRequestHandler.perform([VNGeneratePersonSegmentationRequest { (request, error) in
                if error == nil {
                    if let results = request.results as? [VNPixelBufferObservation] {
                        var selfieData:[Data?] = []
                        for selfie in results {
                            var cgImage: CGImage?
                            VTCreateCGImageFromCVPixelBuffer(selfie.pixelBuffer, options: nil, imageOut: &cgImage)

                            let nsImage = NSBitmapImageRep(cgImage:cgImage!).representation(
                                using: format,
                                properties: [
                                    NSBitmapImageRep.PropertyKey.currentFrame: NSBitmapImageRep.PropertyKey.currentFrame.self
                                ]
                            )
                            selfieData.append(nsImage)

                        }
                        event = [
                            "name": "selfie",
                            "data": selfieData,
                            //"imageSize": imageSize
                        ]
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
}
