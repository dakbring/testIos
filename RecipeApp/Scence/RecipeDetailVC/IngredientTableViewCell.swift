//
//  IngredientTableViewCell.swift
//  RecipeApp
//
//  Created by Lam Pham on 2/23/20.
//  Copyright © 2020 Lam Pham. All rights reserved.
//

import UIKit

class IngredientTableViewCell: UITableViewCell {

    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbQuantity: UILabel!
    @IBOutlet weak var lbNote: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func bindData(data: IngredientItem) {
        lbName.text = data.materialName
        lbQuantity.text = data.quantity
        lbNote.text = data.descriptionNote
    }
    
    func setData(data: IngredientModelData) {
        lbName.text = data.materialName
        lbQuantity.text = data.quantity
        lbNote.text = data.descriptionNote
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
    
}
