//
//  AddingIngredientViewController.swift
//  RecipeApp
//
//  Created by Lam Pham on 2/24/20.
//  Copyright © 2020 Lam Pham. All rights reserved.
//

import UIKit

protocol AddingIngredientViewControllerDelegate: class {
    func didDoneIngredient(with data: IngredientModelData, isEdit: Bool)
}

class AddingIngredientViewController: UIViewController {
    
    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var tfQuantity: UITextField!
    @IBOutlet weak var tvNote: UITextView!
    
    lazy var lbTitle:UILabel = {
        let lb = UILabel(frame: CGRect(x: (UIScreen.main.bounds.width - self.view.bounds.width/4)/2, y: 0,
                                       width: self.view.bounds.width, height: 44))
        
        lb.font = UIFont.boldSystemFont(ofSize: 20)
        lb.textAlignment = .center
        lb.numberOfLines = 2
        return lb
    }()
    
    weak var delegate: AddingIngredientViewControllerDelegate?
    var ingredientOrder: Int?
    
    var dataEditIngredient: IngredientModelData?
    
    var dataEditIngredientItem: IngredientItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let data = dataEditIngredient {
            tfName.text = data.materialName
            tfQuantity.text = data.quantity
            tvNote.text = data.descriptionNote
        } else { }
        
        if let data = dataEditIngredientItem {
            tfName.text = data.materialName
            tfQuantity.text = data.quantity
            tvNote.text = data.descriptionNote
              lbTitle.text = "Ingradient Update".uppercased()
        } else {
              lbTitle.text = "Ingradient Add".uppercased()
        }
        
      
        lbTitle.sizeToFit()
        self.navigationItem.titleView = lbTitle
        self.navigationController?.navigationBar.setTitleVerticalPositionAdjustment(3, for: UIBarMetrics.default)
        self.navigationController?.navigationBar.tintColor = .darkGray
        
    }
    
    @IBAction func btnDoneTapped(_ sender: Any) {
        if (tfName.text?.isEmpty)! || (tfQuantity.text?.isEmpty)! || (tvNote.text?.isEmpty)! {
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
        }  else {}
        
        
        let item = IngredientModelData(ingredientOrder: String(ingredientOrder!), materialName: tfName.text!, quantity: tfQuantity.text!, image: "", descriptionNote: tvNote.text!)
        
        if (dataEditIngredient == nil) && (dataEditIngredientItem == nil) {
            delegate?.didDoneIngredient(with: item, isEdit: false)
        } else {
            delegate?.didDoneIngredient(with: item, isEdit: true)
        }
        
        navigationController?.popViewController(animated: true)
    }
    
}
