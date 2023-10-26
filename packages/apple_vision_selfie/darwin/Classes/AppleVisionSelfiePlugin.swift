import Vision

#if os(iOS)
import Flutter
#elseif os(macOS)
import FlutterMacOS
#endif

import VideoToolbox
import CoreImage.CIFilterBuiltins

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
            guard let arguments = call.arguments as? [String:Any?],
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
            let quality = arguments["quality"] as? Int ?? 0
            let background:FlutterStandardTypedData? = arguments["background"] as? FlutterStandardTypedData ?? nil
            
            #if os(iOS)
                if #available(iOS 15.0, *) {
                    return result(convertImage(Data(data.data),CGSize(width: width , height: height),pictureFormat,CIFormat.BGRA8,quality,background?.data))
                } else {
                    return result(FlutterError(code: "INVALID OS", message: "requires version 15.0", details: nil))
                }
            #elseif os(macOS)
            return result(convertImage(Data(data.data),CGSize(width: width , height: height), pictureFormat,CIFormat.ARGB8,quality,background?.data))
            #endif
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    // Gets called when a new image is added to the buffer
    #if os(iOS)
    @available(iOS 15.0, *)
    #endif
    func convertImage(_ data: Data,_ imageSize: CGSize,_ fileType: NSBitmapImageRep.FileType,_ format: CIFormat,_ quality:Int,_ background: Data? ) -> [String:Any?]{
        let imageRequestHandler:VNImageRequestHandler
        var originalImage:CIImage?
        if data.count == (Int(imageSize.height)*Int(imageSize.width)*4){
            // Create a bitmap graphics context with the sample buffer data
            originalImage =  CIImage(bitmapData: data, bytesPerRow: Int(imageSize.width)*4, size: imageSize, format: format, colorSpace: nil)
            
            imageRequestHandler = VNImageRequestHandler(ciImage:originalImage!)
        }
        else{
            imageRequestHandler = VNImageRequestHandler(
                data: data,
                orientation: .up)
        }
        var event:[String:Any?] = ["name":"noData"];
        let selfieRequest = VNGeneratePersonSegmentationRequest(completionHandler: { (request, error) in
            if error == nil {
                if let results = request.results as? [VNPixelBufferObservation] {
                    var selfieData:[Data?] = []
                    for selfie in results {
                        // Create CIImage objects for the video frame and the segmentation mask.
                        var originalImageOr:CIImage
                        if originalImage == nil{
                            originalImageOr = CIImage(data:data)!
                        }
                        else{
                            originalImageOr = originalImage!
                        }
                        var maskImage = CIImage(cvPixelBuffer: selfie.pixelBuffer)

                        // Scale the mask image to fit the bounds of the video frame.
                        let scaleX = originalImageOr.extent.width / maskImage.extent.width
                        let scaleY = originalImageOr.extent.height / maskImage.extent.height
                        maskImage = maskImage.transformed(by: .init(scaleX: scaleX, y: scaleY))

                        // Define RGB vectors for CIColorMatrix filter.
                        let vectors2 = [
                            "inputRVector": CIVector(x: 0, y: 0, z: 0, w: 0),
                            "inputGVector": CIVector(x: 0, y: 0, z: 0, w: 0),
                            "inputBVector": CIVector(x: 0, y: 0, z: 0, w: 0),
                            "inputAVector": CIVector(x: 0, y: 0, z: 0, w: 0),
                        ]


                        // Create a colored background image.
                        var backgroundImage:CIImage = maskImage.applyingFilter("CIColorMatrix",parameters: vectors2)
                        
                        if background != nil{
                            backgroundImage = CIImage(data:background!)!
                        }
                            

                        let blendFilter = CIFilter.blendWithMask()
                        blendFilter.inputImage = originalImage
                        blendFilter.backgroundImage = backgroundImage
                        blendFilter.maskImage = maskImage
                        
                        // Set the new, blended image as current.
                        let ciImage = blendFilter.outputImage
                        
//                        var cgImage: CGImage?
//                        VTCreateCGImageFromCVPixelBuffer(selfie.pixelBuffer, options: nil, imageOut: &cgImage)

                        let nsImage = NSBitmapImageRep(ciImage:ciImage!).representation(
                            using: fileType,
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
        })
        
        selfieRequest.qualityLevel = quality == 0 ? .fast : quality == 1 ? .balanced : .accurate
        
        do {
            let requests: [VNRequest] = [selfieRequest]
            try imageRequestHandler.perform(requests)
        } catch {
            event = ["name":"error","code": "Data Corropted", "message": error.localizedDescription]
            print(error)
        }

        return event
    }
}
