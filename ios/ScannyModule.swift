import ExpoModulesCore
import UIKit
import AVFoundation
import Photos

public class ScannyModule: Module {
  fileprivate var scan: ScanCamera = ScanCamera()

  public func definition() -> ModuleDefinition {
    Name("Scanny")

    AsyncFunction("openCamera") { (promise: Promise) in
    DispatchQueue.main.async {
        self.scan.presentCameraViewController(promise: promise)
      }    
    }
  }
}
