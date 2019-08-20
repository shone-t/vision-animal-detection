//
//  ClassifarViewController.swift
//  AnimalClassifireApp
//
//  Created by MacBook Pro on 8/20/19.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ClassifarViewController: UIViewController {
    
    // Outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var classificationLabel: UILabel!
    
    lazy var classificationRequest: VNCoreMLRequest = {
        do {
            let model = try VNCoreMLModel(for: AnimalClassifier().model)
            
            let request = VNCoreMLRequest(model: model, completionHandler: { (request, error) in
                // Process classification
                self.processClassification(for: request, error: error)
            })
            request.imageCropAndScaleOption = .centerCrop
            return request
        } catch {
            fatalError("Faild to load Vision ML model: \(error)")
        }
    }()
    
    func processClassification(for request: VNRequest, error: Error?){
        DispatchQueue.main.async {
            guard let classifications = request.results as? [VNClassificationObservation] else {
                self.classificationLabel.text = "Unable to classify image. \n\(error?.localizedDescription ?? "Error")"
                return
            }
            
            if classifications.isEmpty {
                self.classificationLabel.text = "Nothing recognized."
            } else {
                let topClassifications = classifications.prefix(2)
                let descriptions = topClassifications.map { classifications in
                    return String(format: "%.2f", classifications.confidence * 100) + "% - " + classifications.identifier
                }
                
                self.classificationLabel.text = "Classifications:\n" + descriptions.joined(separator: "\n")
            }
        }
        
    }
    
    func updateClassifications(for image: UIImage) {
        classificationLabel.text = "Classifying..."
        
        guard let orientation = CGImagePropertyOrientation(rawValue: UInt32(image.imageOrientation.rawValue)), let ciImage = CIImage(image: image) else {
            // display error
            displayError()
            return
        }
        // sve sto menja UI treba da ima i ovaj DisptachQueue blok
        DispatchQueue.global(qos: .userInteractive).async {
            
            let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
            
            do {
                try handler.perform([self.classificationRequest])
            } catch  {
                print("Faild to perform classification. \n\(error.localizedDescription)")
            }
            
        }
        
    }
    
    func displayError() {
        classificationLabel.text = "Something went wrong...\n Please try again."
    }
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        // Do any additional setup after loading the view.
//    }

    @IBAction func cameraBtnWasPressed(_ sender: Any) {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            //present photo picker
            presentPhotoPicker(sourceType: .photoLibrary)
            return
        }
        
        let photoSourcePicker = UIAlertController()
        let takePhotoAction = UIAlertAction(title: "Take Photo", style: .default) { _ in
            // present photo picker with camera
            self.presentPhotoPicker(sourceType: .camera)
        }
        let choosePhotoAction = UIAlertAction(title: "Chose Photo", style: .default) { _ in
            // present photo picker with photo picker
            self.presentPhotoPicker(sourceType: .photoLibrary)
        }
        photoSourcePicker.addAction(takePhotoAction)
        photoSourcePicker.addAction(choosePhotoAction)
        photoSourcePicker.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(photoSourcePicker, animated: true, completion: nil)
    }
    
    func presentPhotoPicker(sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        present(picker, animated: true, completion: nil)
    }
    
}

extension ClassifarViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { fatalError("No image returned") }
        imageView.image = image
        
        // Use image to make prediction with CoreML model
        updateClassifications(for: image)
    }
    
}

