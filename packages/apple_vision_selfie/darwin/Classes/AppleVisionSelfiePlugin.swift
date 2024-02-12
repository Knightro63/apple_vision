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
            
            let width = arguments["width"] as? Double ?? 0
            let height = arguments["height"] as? Double ?? 0
            let quality = arguments["quality"] as? Int ?? 0
            let background:FlutterStandardTypedData? = arguments["background"] as? FlutterStandardTypedData ?? nil
            let pf = arguments["format"] as! String
            let orientation = arguments["orientation"] as? String ?? "downMirrored"

            #if os(iOS)
                if #available(iOS 15.0, *) {
                    return result(convertImage(Data(data.data),CGSize(width: width , height: height),pf,CIFormat.BGRA8,quality,background?.data,orientation))
                } else {
                    return result(FlutterError(code: "INVALID OS", message: "requires version 15.0", details: nil))
                }
            #elseif os(macOS)
                return result(convertImage(Data(data.data),CGSize(width: width , height: height), pf,CIFormat.ARGB8,quality,background?.data,orientation))
            #endif
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    // Gets called when a new image is added to the buffer
    #if os(iOS)
    @available(iOS 15.0, *)
    #endif
    func convertImage(_ data: Data,_ imageSize: CGSize,_ fileType: String,_ format: CIFormat,_ quality:Int,_ background: Data?,_ oriString: String) -> [String:Any?]{
        let imageRequestHandler:VNImageRequestHandler

        var orientation:CGImagePropertyOrientation = CGImagePropertyOrientation.downMirrored
        switch oriString{
            case "down":
                orientation = CGImagePropertyOrientation.down
            case "right":
                orientation = CGImagePropertyOrientation.right
            case "rightMirrored":
                orientation = CGImagePropertyOrientation.rightMirrored
            case "left":
                orientation = CGImagePropertyOrientation.left
            case "leftMirrored":
                orientation = CGImagePropertyOrientation.leftMirrored
            case "up":
                orientation = CGImagePropertyOrientation.up
            case "upMirrored":
                orientation = CGImagePropertyOrientation.upMirrored
            default:
                orientation = CGImagePropertyOrientation.downMirrored
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
                        
                        #if os(iOS)
                            var uiImage:Data?
                            switch fileType {
                                case "jpg":
                                    uiImage = UIImage(ciImage: ciImage!).jpegData(compressionQuality: 1.0)
                                case "jpeg":
                                    uiImage = UIImage(ciImage: ciImage!).jpegData(compressionQuality: 1.0)
                                case "bmp":
                                    uiImage = nil
                                case "png":
                                    uiImage = UIImage(ciImage: ciImage!).pngData()
                                case "tiff":
                                    uiImage = nil
                                default:
                                    uiImage = nil
                            }
                            
                            if uiImage == nil{
                                let ciContext = CIContext()
                                let rowBytes = 4 * Int(ciImage!.extent.width) // 4 channels (RGBA) of 8-bit data
                                let dataSize = rowBytes * Int(ciImage!.extent.height)
                                var data = Data(count: dataSize)
                                data.withUnsafeMutableBytes { data in
                                    ciContext.render(ciImage!, toBitmap: data, rowBytes: rowBytes, bounds: ciImage!.extent, format: .RGBA8, colorSpace: CGColorSpace(name: CGColorSpace.sRGB)!)
                                }
                                if fileType == "bmp"{
                                    uiImage = self.rgba2bitmap(
                                        data,
                                        Int(ciImage!.extent.width),
                                        Int(ciImage!.extent.height)
                                    )
                                }
                                else{
                                    uiImage = data
                                }
                            }
                            selfieData.append(uiImage!)
                        #elseif os(macOS)
                            var nsImage:Data?
                            switch fileType {
                                case "jpg":
                                    nsImage = NSBitmapImageRep(ciImage:ciImage!).representation(
                                        using: .jpeg,
                                        properties: [:]
                                    )
                                case "jpeg":
                                    nsImage = NSBitmapImageRep(ciImage:ciImage!).representation(
                                        using: .jpeg2000,
                                        properties: [:]
                                    )
                                case "bmp":
                                    nsImage = NSBitmapImageRep(ciImage:ciImage!).representation(
                                        using: .bmp,
                                        properties: [:]
                                    )
                                case "png":
                                    nsImage = NSBitmapImageRep(ciImage:ciImage!).representation(
                                        using: .png,
                                        properties: [:]
                                    )
                                case "tiff":
                                    nsImage = NSBitmapImageRep(ciImage:ciImage!).representation(
                                        using: .tiff,
                                        properties: [:]
                                    )
                                default:
                                    nsImage = nil
                            }
                            
                            if nsImage == nil{
                                let u = NSBitmapImageRep(ciImage:ciImage!)
                                let bytesPerRow = u.bytesPerRow
                                let height = Int(u.size.height)
                                
                                nsImage = Data(bytes: u.bitmapData!, count: Int(bytesPerRow*height))
                            }
                            selfieData.append(nsImage)
                        #endif
                    }
                    event = [
                        "name": "selfie",
                        "data": selfieData,
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

    func rgba2bitmap(_ content:Data,_ width: Int,_ height: Int)-> Data{
        let headerSize:Int = 122;
        let contentSize:Int = content.count;
        let fileLength:Int =  contentSize + headerSize;

        var bd:[UInt8] = [UInt8](repeating: 0, count: fileLength);

        bd.insert(0x42, at: 0);
        bd.insert(0x4d, at: 0x1);
        bd.insert(contentsOf: UInt32(fileLength).toBytes, at: 0x2);
        bd.insert(contentsOf: UInt32(headerSize).toBytes, at: 0xa);
        bd.insert(contentsOf: UInt32(108).toBytes, at: 0xe);
        bd.insert(contentsOf: UInt32(width).toBytes, at: 0x12);
        bd.insert(contentsOf: UInt32(Int(UInt32.max)+1-height).toBytes, at: 0x16);
        bd.insert(contentsOf: UInt32(1).toBytes, at: 0x1a);
        bd.insert(contentsOf: UInt32(32).toBytes, at: 0x1c);
        bd.insert(contentsOf: UInt32(3).toBytes, at: 0x1e);
        bd.insert(contentsOf: UInt32(contentSize).toBytes, at: 0x22);
        bd.insert(contentsOf: UInt32(0x000000ff).toBytes, at: 0x36);
        bd.insert(contentsOf: UInt32(0x0000ff00).toBytes, at: 0x3a);
        bd.insert(contentsOf: UInt32(0x00ff0000).toBytes, at: 0x3e);
        bd.insert(contentsOf: UInt32(0xff000000).toBytes, at: 0x42);
        
        bd.replaceSubrange(headerSize...fileLength, with: content)
        
        return Data(bytes: bd, count: fileLength)
    }
}

extension UInt32{
    var toBytes: [UInt8] {
        return withUnsafeBytes(of: self.littleEndian) {Array($0)}
    }
}
