import ExpoModulesCore
import UIKit
import AVFoundation
import Photos

internal class ScanCamera: NSObject {
    var name : String!
    var image: UIImage!
    var cameraViewController: UIViewController?
    
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var captureOutput: AVCapturePhotoOutput?
    
    public func presentCameraViewController(promise: Promise) {
        guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else {
          promise.reject(NSError(domain: "CameraModule", code: 1, userInfo: [NSLocalizedDescriptionKey: "No root view controller"]))
          return
        }

        // Create a new view controller
        self.cameraViewController = UIViewController()
        self.cameraViewController!.view.backgroundColor = .black
        
        // Setup the AVCaptureSession and preview layer
        setupCameraSession(in: cameraViewController!)

        // Add the Capture button
        let captureButton = UIButton(type: .system)
        captureButton.frame = CGRect(x: self.cameraViewController!.view.bounds.midX - 35, y: self.cameraViewController!.view.bounds.maxY - 150, width: 70, height: 70)
        //captureButton.setTitle("Capture", for: .normal)
        captureButton.backgroundColor = .white
        captureButton.layer.cornerRadius = captureButton.bounds.width / 2
        captureButton.addTarget(self, action: #selector(self.handleTakePhoto), for: .touchUpInside)
        
        self.cameraViewController!.view.addSubview(captureButton)

        // Add the Close button
        let closeButton = UIButton(type: .system)
        closeButton.frame = CGRect(x: 20, y: 20, width: 70, height: 40)
        closeButton.setTitle("Close", for: .normal)
        closeButton.backgroundColor = .white
        closeButton.layer.cornerRadius = 10
        closeButton.addTarget(self, action: #selector(self.closeCameraViewController), for: .touchUpInside)
        /*if let closeImage = UIImage(named: "close") {
            closeButton.setImage(closeImage, for: .normal)
        }*/
        self.cameraViewController!.view.addSubview(closeButton)

        // Add the Rectangle Overlay
        if let rectangleImage = UIImage(named: "overlay") {
          let rectangleImageView = UIImageView(image: rectangleImage)
          rectangleImageView.contentMode = .scaleAspectFit
            rectangleImageView.frame = CGRect(x: 20, y: -30, width: self.cameraViewController!.view.bounds.width - 40, height: (self.cameraViewController!.view.bounds.height - 40))
            self.cameraViewController!.view.addSubview(rectangleImageView)
        }

        // Present the new view controller
        rootViewController.present(self.cameraViewController!, animated: true) {
          promise.resolve("Camera view controller presented successfully")
        }
      }

    private func setupCameraSession(in viewController: UIViewController) {
        self.captureSession = AVCaptureSession()
        self.captureSession?.sessionPreset = .photo
        guard let captureSession = self.captureSession else { return }
        
        let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice!), captureSession.canAddInput(videoDeviceInput) else { return }
        
        captureSession.addInput(videoDeviceInput)
        
        self.captureOutput = AVCapturePhotoOutput()
        guard let captureOutput = self.captureOutput, captureSession.canAddOutput(captureOutput) else { return }
        
        captureSession.addOutput(captureOutput)
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = viewController.view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        viewController.view.layer.addSublayer(previewLayer)
        self.previewLayer = previewLayer
        
        DispatchQueue.global(qos: .background).async {
            captureSession.startRunning()
        }
    }
  
    @objc func handleTakePhoto(_ sender: UIButton) {
        let settings = AVCapturePhotoSettings()
        if let photoPreviewType = settings.availablePreviewPhotoPixelFormatTypes.first {
            settings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: photoPreviewType]
            self.captureOutput?.capturePhoto(with: settings, delegate: self)
        }
    }
    
    @objc func closeCameraViewController(_ sender: UIButton) {
        guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else { return }
        rootViewController.dismiss(animated: true, completion: nil)
    }

}

extension ScanCamera: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Error capturing photo: \(error)")
            return
        }
        
        guard let data = photo.fileDataRepresentation(), let image = UIImage(data: data) else {
            print("Error processing photo data")
            return
        }
        
        // Process the image as needed, e.g., save or send it back to React Native
        print("Captured image size: \(image.size)")

        let photoPreviewContainer = PhotoPreviewView(frame: self.cameraViewController!.view.frame)
        photoPreviewContainer.photoImageView.image = image
        self.cameraViewController!.view.addSubview(photoPreviewContainer)
        
        // Optionally, stop the capture session and remove the preview
        self.captureSession?.stopRunning()
    }
}

class PhotoPreviewView: UIView {
    
    let photoImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    lazy private var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        button.tintColor = .white
        return button
    }()
    
    lazy private var savePhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "square.and.arrow.down"), for: .normal)
        button.addTarget(self, action: #selector(handleSavePhoto), for: .touchUpInside)
        button.tintColor = .white
        return button
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(photoImageView)
        self.addSubview(cancelButton)
        self.addSubview(savePhotoButton)
        
        savePhotoButton.centerYAnchor.constraint(equalTo: cancelButton.centerYAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    @objc private func handleCancel() {
        DispatchQueue.main.async {
            self.removeFromSuperview()
        }
    }
    
    @objc private func handleSavePhoto() {
        
        guard let previewImage = self.photoImageView.image else { return }
        
        PHPhotoLibrary.requestAuthorization { (status) in
            if status == .authorized {
                do {
                    try PHPhotoLibrary.shared().performChangesAndWait {
                        PHAssetChangeRequest.creationRequestForAsset(from: previewImage)
                        print("photo has saved in library...")
                        self.handleCancel()
                    }
                } catch let error {
                    print("failed to save photo in library: ", error)
                }
            } else {
                print("Something went wrong with permission...")
            }
        }
    }
}
