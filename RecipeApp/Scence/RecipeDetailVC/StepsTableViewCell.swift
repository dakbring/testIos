//
//  StepsTableViewCell.swift
//  RecipeApp
//
//  Created by Lam Pham on 2/23/20.
//  Copyright © 2020 Lam Pham. All rights reserved.
//

import UIKit

class StepsTableViewCell: UITableViewCell {

    @IBOutlet weak var lbStepName: UILabel!
    @IBOutlet weak var lbStepDtail: UILabel!
    @IBOutlet weak var imvStep: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func bindData(data: StepItem) {
        lbStepName.text = data.stepName
        lbStepDtail.text = data.descriptionNote
        imvStep.image = data.imageStep == nil ? UIImage(named: "image_material_sample") : UIImage(data: data.imageStep!)
    }
    
    func setData(data: StepModelData) {
        lbStepName.text = data.stepName
        lbStepDtail.text = data.descriptionNote
        imvStep.image = data.imageData == nil ? UIImage(named: "image_material_sample") : UIImage(data: data.imageData!)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
    
}
