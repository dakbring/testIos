//
//  RecipeDetailViewController.swift
//  RecipeApp
//
//  Created by Lam Pham on 2/22/20.
//  Copyright © 2020 Lam Pham. All rights reserved.
//

import UIKit
import CoreData

class RecipeDetailViewController: UIViewController {
    
    @IBOutlet weak var tbvIngresdient: OwnTableView!
    
    @IBOutlet weak var tbvSteps: OwnTableView!
    
    @IBOutlet weak var lbRecipeName: UILabel!
    
    @IBOutlet weak var imvRecipe: UIImageView!
    
    lazy var lbTitle:UILabel = {
        let lb = UILabel(frame: CGRect(x: (UIScreen.main.bounds.width - self.view.bounds.width/4)/2, y: 0,
                                       width: self.view.bounds.width, height: 44))
        
        lb.font = UIFont.boldSystemFont(ofSize: 20)
        lb.textAlignment = .center
        lb.numberOfLines = 2
        return lb
    }()
    
    var coreDataStack: CoreDataStack!
    var fetchedResultsController : NSFetchedResultsController<RecipeItem>!
    var contextIndex: Int?
    
    var rightButton: UIBarButtonItem?
    
    var recipeData: RecipeItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        setupComponent()
        
    }
    
    private func setUpView() {
        imvRecipe.image = recipeData?.coverImage == nil ? UIImage(named: "image_material_sample") : UIImage(data: (recipeData?.coverImage!)!)
        lbRecipeName.text = recipeData?.name
        lbTitle.text = "Recipe Detail".uppercased()
        lbTitle.sizeToFit()
        self.navigationItem.titleView = lbTitle
        self.navigationController?.navigationBar.setTitleVerticalPositionAdjustment(3, for: UIBarMetrics.default)
        self.navigationController?.navigationBar.tintColor = .darkGray
        
        rightButton = UIBarButtonItem(title: "Edit", style: .done, target: self, action: #selector(editTapped))
        rightButton?.tintColor = .darkGray
        self.navigationItem.rightBarButtonItem = rightButton
    }
    
    private func setupComponent() {
        tbvIngresdient.delegate = self
        tbvIngresdient.dataSource = self
        tbvIngresdient.register(UINib(nibName: "IngredientTableViewCell", bundle:  nil), forCellReuseIdentifier: "IngredientTableViewCell")
        tbvIngresdient.rowHeight = UITableView.automaticDimension
        tbvIngresdient.estimatedRowHeight = 600
        
        tbvSteps.delegate = self
        tbvSteps.dataSource = self
        tbvSteps.register(UINib(nibName: "StepsTableViewCell", bundle:  nil), forCellReuseIdentifier: "StepsTableViewCell")
        tbvSteps.rowHeight = UITableView.automaticDimension
        tbvSteps.estimatedRowHeight = 600
    }
    
    @objc func editTapped(sender: AnyObject) {
        let vc = CreateRecipeViewController.instantiateFromNib()
        vc.delegate = self
        vc.contextIndex = self.contextIndex
        vc.coreDataStack = self.coreDataStack
        vc.recipeData = self.recipeData
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension RecipeDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tbvIngresdient {
            return recipeData?.ingredients?.count ?? 0
        } else {
            return recipeData?.stepsRecipe?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == tbvIngresdient {
            let cell = tableView.dequeueReusableCell(withIdentifier: "IngredientTableViewCell", for: indexPath) as! IngredientTableViewCell
            cell.bindData(data: recipeData?.ingredients?[indexPath.row] as! IngredientItem)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "StepsTableViewCell", for: indexPath) as! StepsTableViewCell
            cell.bindData(data: recipeData?.stepsRecipe?[indexPath.row] as! StepItem)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
    }
    
}

extension RecipeDetailViewController: CreateNewRecipeDelegate {
    func didCreate(with recipe: RecipeItem) {
        tbvSteps.reloadData()
        tbvIngresdient.reloadData()
        lbRecipeName.text = recipe.name
        DispatchQueue.main.async {
            self.imvRecipe.image = UIImage(data: recipe.coverImage!) //Alway not-nil
        }
    }
}
