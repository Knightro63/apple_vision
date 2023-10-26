import AVFoundation
import Vision

#if os(iOS)
import Flutter
import UIKit
#elseif os(macOS)
import FlutterMacOS
import AppKit
#endif

public class AppleVisionScannerPlugin: NSObject, FlutterPlugin {
    let registry: FlutterTextureRegistry
    var scanWindow: CGRect?
    
    init(_ registry: FlutterTextureRegistry) {
        self.registry = registry
        super.init()
    }

    public static func register(with registrar: FlutterPluginRegistrar) {
        #if os(iOS)
        let method = FlutterMethodChannel(name:"apple_vision/scanner", binaryMessenger: registrar.messenger())
        let instance = AppleVisionScannerPlugin(registrar.textures())
        #elseif os(macOS)
        let method = FlutterMethodChannel(name:"apple_vision/scanner", binaryMessenger: registrar.messenger)
        let instance = AppleVisionScannerPlugin(registrar.textures)
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
            #if os(iOS)
                if #available(iOS 13.0, *) {
                    return result(convertImage(Data(data.data),CGSize(width: width , height: height),CIFormat.BGRA8))
                } else {
                    return result(FlutterError(code: "INVALID OS", message: "requires version 13.0", details: nil))
                }
            #elseif os(macOS)
                return result(convertImage(Data(data.data),CGSize(width: width , height: height),CIFormat.ARGB8))
            #endif
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    
    // Gets called when a new image is added to the buffer
    #if os(iOS)
    @available(iOS 13.0, *)
    #endif
    func convertImage(_ data: Data,_ imageSize: CGSize,_ format: CIFormat) -> [String:Any?]{
        let imageRequestHandler:VNImageRequestHandler
        if data.count == (Int(imageSize.height)*Int(imageSize.width)*4){
            // Create a bitmap graphics context with the sample buffer data
            let context =  CIImage(bitmapData: data, bytesPerRow: Int(imageSize.width)*4, size: imageSize, format: format, colorSpace: nil)
            
            imageRequestHandler = VNImageRequestHandler(ciImage:context)
        }
        else{
            imageRequestHandler = VNImageRequestHandler(
                data: data,
                orientation: .downMirrored)
        }
        
        var event:[String:Any?] = ["name":"noData"];

        do {
            try imageRequestHandler.perform([VNDetectBarcodesRequest { (request, error) in
                if error == nil {
                    if let results = request.results as? [VNBarcodeObservation] {
                        var barCodes:[[String:Any?]] = []
                        for barcode in results {
                            if self.scanWindow != nil {
                                let match = self.isbarCodeInScanWindow(self.scanWindow!, barcode,imageSize)
                                if (!match) {
                                    continue
                                }
                            }
                            let barcodeType = String(barcode.symbology.rawValue).replacingOccurrences(of: "VNBarcodeSymbology", with: "")
                            barCodes.append([
                                "displayValue": barcode.payloadStringValue,
                                "format": barcodeType,
                                "boundingBoxLeft": barcode.boundingBox.minX*imageSize.width,
                                "boundingBoxTop": barcode.boundingBox.minY*imageSize.height,
                                "boundingBoxRight": barcode.boundingBox.maxX*imageSize.width,
                                "boundingBoxBottom": barcode.boundingBox.maxY*imageSize.height,
                            ])
                        }
                        event = [
                            "name": "barcode",
                            "data": barCodes
                        ]
                    }

                } else {
                    print(error!.localizedDescription)
                }
            }])
        } catch {
            print(error)
        }

        return event
    }

    func updateScanWindow(_ call: FlutterMethodCall) {
        let argReader = MapArgumentReader(call.arguments as? [String: Any])
        let scanWindowData: Array? = argReader.floatArray(key: "rect")

        if (scanWindowData == nil) {
            return 
        }

        let minX = scanWindowData![0] 
        let minY = scanWindowData![1]

        let width = scanWindowData![2]  - minX
        let height = scanWindowData![3] - minY

        scanWindow = CGRect(x: minX, y: minY, width: width, height: height)
    }

    func isbarCodeInScanWindow(_ scanWindow: CGRect, _ barcode: VNBarcodeObservation, _ imageSize: CGSize) -> Bool {

        let imageWidth = imageSize.width;
        let imageHeight = imageSize.height;

        let minX = scanWindow.minX * imageWidth
        let minY = scanWindow.minY * imageHeight
        let width = scanWindow.width * imageWidth
        let height = scanWindow.height * imageHeight

        let scaledScanWindow = CGRect(x: minX, y: minY, width: width, height: height)
        return scaledScanWindow.contains(barcode.boundingBox)
    }
}

class MapArgumentReader {
  
  let args: [String: Any]?
  
  init(_ args: [String: Any]?) {
    self.args = args
  }
  
  func string(key: String) -> String? {
    return args?[key] as? String
  }
  
  func int(key: String) -> Int? {
    return (args?[key] as? NSNumber)?.intValue
  }
    
    func bool(key: String) -> Bool? {
      return (args?[key] as? NSNumber)?.boolValue
    }

  func stringArray(key: String) -> [String]? {
    return args?[key] as? [String]
  }

  func floatArray(key: String) -> [CGFloat]? {
    return args?[key] as? [CGFloat]
  }
  
}
