import Vision

#if os(iOS)
import Flutter
#elseif os(macOS)
import FlutterMacOS
#endif

import VideoToolbox
import CoreImage.CIFilterBuiltins

public class AppleVisionLiftSubjectsPlugin: NSObject, FlutterPlugin {

    let registry: FlutterTextureRegistry
    
    init(_ registry: FlutterTextureRegistry) {
        self.registry = registry
        super.init()
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        #if os(iOS)
        let method = FlutterMethodChannel(name:"apple_vision/lift_subjects", binaryMessenger: registrar.messenger())
        let instance = AppleVisionLiftSubjectsPlugin(registrar.textures())
        #elseif os(macOS)
        let method = FlutterMethodChannel(name:"apple_vision/lift_subjects", binaryMessenger: registrar.messenger)
        let instance = AppleVisionLiftSubjectsPlugin(registrar.textures)
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
            let background:FlutterStandardTypedData? = arguments["background"] as? FlutterStandardTypedData ?? nil
            let x:Double? = arguments["x"] as? Double
            let y:Double? = arguments["y"] as? Double
            let crop:Bool = arguments["crop"] as? Bool ?? false
            var atPoint:CGPoint?
            if x != nil && y != nil{
                atPoint = CGPoint(x: x!, y: y!)
            }
            let pf = arguments["format"] as! String
            let orientation = arguments["orientation"] as? String ?? "downMirrored"

            #if os(iOS)
                if #available(iOS 17.0, *) {
                    return result(
                        convertImage(
                            Data(data.data),
                            CGSize(width: width , height: height),
                            pf,
                            CIFormat.BGRA8,
                            atPoint,
                            background?.data,
                            orientation,
                            crop
                        )
                    )
                } else {
                    return result(FlutterError(code: "INVALID OS", message: "requires version 15.0", details: nil))
                }
            #elseif os(macOS)
                if #available(macOS 14.0, *) {
                    return result(
                        convertImage(
                            Data(data.data),
                            CGSize(width: width , height: height), 
                            pf,
                            CIFormat.ARGB8,
                            atPoint,
                            background?.data,
                            orientation,
                            crop
                        )
                    )
                } else {
                    return result(FlutterError(code: "INVALID OS", message: "requires version 14.0", details: nil))
                }
            #endif
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    // Gets called when a new image is added to the buffer
    #if os(iOS)
    @available(iOS 17.0, *)
    #elseif os(macOS)
    @available(macOS 14.0, *)
    #endif
    func convertImage(
        _ data: Data,
        _ imageSize: CGSize,
        _ fileType: String,
        _ format: CIFormat,
        _ atPoint: CGPoint?,
        _ background: Data?,
        _ oriString: String,
        _ crop: Bool
    ) -> [String:Any?]{
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
                orientation: orientation
            )
        }
        var event:[String:Any?] = ["name":"noData"];
        let liftRequest = VNGenerateForegroundInstanceMaskRequest()
        do {
            try imageRequestHandler.perform([liftRequest])
        } catch {
            return ["name":"error","code": "Data Corropted", "message": error.localizedDescription]
        }
        
        guard let lifted = liftRequest.results?.first else{
            return ["name":"data","code": "No Data"]
        }
        
        var liftData:Data?

        do{
            var output:CVPixelBuffer
            output = try lifted.generateMaskedImage(
                ofInstances: self.instances(atPoint: atPoint, inObservation: lifted),
                from: imageRequestHandler,
                croppedToInstancesExtent: crop
            )
                
            let maskImage = CIImage(cvPixelBuffer: output)
            var ciImage:CIImage? = maskImage
            // Create a colored background image.
            
            if background != nil{
                let backgroundImage = CIImage(data:background!)!
            
                let blendFilter = CIFilter.sourceOverCompositing()
                blendFilter.inputImage = maskImage
                blendFilter.backgroundImage = backgroundImage
                //blendFilter.maskImage = maskImage
                
                // Set the new, blended image as current.
                ciImage = blendFilter.outputImage
            }
            
            #if os(iOS)
                liftData = ciImage?.cgImage?.dataProvider?.data as Data?
            #elseif os(macOS)
                var nsImage:Data?
                switch fileType {
                    case "jpg":
                        nsImage = NSBitmapImageRep(ciImage:ciImage!).representation(
                            using: .jpeg,
                            properties: [:]
                        )
                    case "jepg":
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
                
                if nsImage != nil{
                    liftData = nsImage
                }
                else{
                    let u = NSBitmapImageRep(ciImage:ciImage!)
                    let bytesPerRow = u.bytesPerRow
                    let height = Int(u.size.height)
                    
                    nsImage = Data(bytes: u.bitmapData!, count: Int(bytesPerRow*height))
                }
                liftData = nsImage!
            #endif
        }
        catch{
            
        }
        
        event = [
            "name": "lift",
            "data": liftData,
        ]
        
        //liftRequest.qualityLevel = quality == 0 ? .fast : quality == 1 ? .balanced : .accurate
        return event
    }
    
    #if os(iOS)
    @available(iOS 17.0, *)
    #elseif os(macOS)
    @available(macOS 14.0, *)
    #endif
    func instances(atPoint maybePoint: CGPoint?, inObservation observation: VNInstanceMaskObservation)-> IndexSet{
        guard let point = maybePoint else{
            return observation.allInstances
        }
        
        let mask = observation.instanceMask
        let coords = VNImagePointForNormalizedPoint(
            point, CVPixelBufferGetWidth(mask)-1, CVPixelBufferGetHeight(mask)-1)
        
        CVPixelBufferLockBaseAddress(mask,.readOnly)
        let pixels = CVPixelBufferGetBaseAddress(mask)!
        let bytesPerRow = CVPixelBufferGetBytesPerRow(mask)
        let instanceLabel = pixels.load(fromByteOffset: Int(coords.y)*bytesPerRow+Int(coords.x), as: UInt8.self)
        
        CVPixelBufferUnlockBaseAddress(mask,.readOnly)
        
        return instanceLabel == 0 ? observation.allInstances : [Int(instanceLabel)]
    }
}
