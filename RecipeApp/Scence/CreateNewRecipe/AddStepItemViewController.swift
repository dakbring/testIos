//
//  AddStepItemViewController.swift
//  RecipeApp
//
//  Created by Lam Pham on 2/24/20.
//  Copyright © 2020 Lam Pham. All rights reserved.
//

import UIKit
import GPUImage
import MobileCoreServices

protocol AddStepItemViewControllerDelegate: class {
    func didDoneStepwith(with data: StepModelData, isEdit: Bool)
}

class AddStepItemViewController: UIViewController {
    
    @IBOutlet weak var tfStepName: UITextField!
    @IBOutlet weak var tvNote: UITextView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var imvStep: UIImageView!
    
    var stepOrder: Int?
    var imvData: Data?
    
    var dataStepEdit: StepModelData?
    
    var dataStepItem: StepItem?
    
    weak var delegate: AddStepItemViewControllerDelegate?
    
    lazy var lbTitle:UILabel = {
        let lb = UILabel(frame: CGRect(x: (UIScreen.main.bounds.width - self.view.bounds.width/4)/2, y: 0,
                                       width: self.view.bounds.width, height: 44))
        
        lb.font = UIFont.boldSystemFont(ofSize: 20)
        lb.textAlignment = .center
        lb.numberOfLines = 2
        return lb
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let data = dataStepEdit {
            tfStepName.text = data.stepName
            tvNote.text = data.descriptionNote
            if data.imageData == nil {     
            } else {
                imvStep.image = UIImage(data: data.imageData!)
            }
        } else {}
        
        if let itemData = dataStepItem {
            tfStepName.text = itemData.stepName
            tvNote.text = itemData.descriptionNote
            if itemData.imageStep == nil {
            } else {
                imvStep.image = UIImage(data: itemData.imageStep!)
            }
             lbTitle.text = "Step Update".uppercased()
        } else {
             lbTitle.text = "Step Add".uppercased()
        }
        
        lbTitle.sizeToFit()
        self.navigationItem.titleView = lbTitle
        self.navigationController?.navigationBar.setTitleVerticalPositionAdjustment(3, for: UIBarMetrics.default)
        self.navigationController?.navigationBar.tintColor = .darkGray
        
    }
    
    @IBAction func btnDoneTapped(_ sender: Any) {
        if (tfStepName.text?.isEmpty)! || (tvNote.text?.isEmpty)! {
            let choicePicker = UIAlertController(title: "Make sure all informaiton are correct",
                                                 message: "Ok to again!",
                                                 preferredStyle: .actionSheet)
            
            let okButton = UIAlertAction(
                title: "OK",
                style: .default) { (alert) -> Void in
                    self.view.endEditing(true)
            }
            choicePicker.addAction(okButton)
            
            present(choicePicker, animated: true)
            return
        } else {
            
            let item = StepModelData(stepOrder: String(stepOrder ?? 1), stepName: tfStepName.text!, descriptionNote: tvNote.text!, imageData: imvData ?? nil)
            
            if (dataStepEdit == nil) && (dataStepItem == nil) {
                //edit
                 delegate?.didDoneStepwith(with: item, isEdit: false)
            } else {
                 delegate?.didDoneStepwith(with: item, isEdit: true)
            }
            
            navigationController?.popViewController(animated: true)
        }
        
    }
    
    @IBAction func btnAddImageTapped(_ sender: Any) {
        let imagePickerActionSheet = UIAlertController(title: "Upload Image",
                                                       message: nil,
                                                       preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraButton = UIAlertAction(
                title: "Take Photo",
                style: .default) { (alert) -> Void in
                    self.activityIndicator.startAnimating()
                    let imagePicker = UIImagePickerController()
                    imagePicker.delegate = self
                    imagePicker.sourceType = .camera
                    imagePicker.mediaTypes = [kUTTypeImage as String]
                    self.present(imagePicker, animated: true, completion: {
                        self.activityIndicator.stopAnimating()
                        
                    })
            }
            imagePickerActionSheet.addAction(cameraButton)
        }
        
        let libraryButton = UIAlertAction(
            title: "Choose Existing",
            style: .default) { (alert) -> Void in
                self.activityIndicator.startAnimating()
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .photoLibrary
                imagePicker.mediaTypes = [kUTTypeImage as String]
                self.present(imagePicker, animated: true, completion: {
                    self.activityIndicator.stopAnimating()
                })
        }
        
        imagePickerActionSheet.addAction(libraryButton)
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel)
        imagePickerActionSheet.addAction(cancelButton)
        
        present(imagePickerActionSheet, animated: true)
        
    }
    
}

// MARK: - UIImagePickerControllerDelegate
extension AddStepItemViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedPhoto = info[.originalImage] as? UIImage else {
            dismiss(animated: true)
            return
        }
        dismiss(animated: true) {
            //do some thing
            self.imvStep.image = selectedPhoto
            self.imvData = selectedPhoto.pngData()
        }
    }
    
}
