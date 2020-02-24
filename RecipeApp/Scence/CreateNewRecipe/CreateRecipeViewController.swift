//
//  CreateRecipeViewController.swift
//  RecipeApp
//
//  Created by Lam Pham on 2/22/20.
//  Copyright © 2020 Lam Pham. All rights reserved.
//

import UIKit
import GPUImage
import MobileCoreServices
import CoreData

protocol CreateNewRecipeDelegate: class {
    func didCreate(with recipe: RecipeItem)
}

class CreateRecipeViewController: UIViewController {
    
    @IBOutlet weak var btnAddCover: UIButton!
    @IBOutlet weak var imvCover: UIImageView!
    
    @IBOutlet weak var tbvAddIngredient: OwnTableView!
    @IBOutlet weak var tbvAddSteps: OwnTableView!
    
    @IBOutlet weak var btnDone: UIButton!
    
    @IBOutlet weak var tfInputReName: UITextField!
    
    @IBOutlet weak var tfInputReType: UITextField!
    
    lazy var lbTitle:UILabel = {
        let lb = UILabel(frame: CGRect(x: (UIScreen.main.bounds.width - self.view.bounds.width/4)/2, y: 0,
                                       width: self.view.bounds.width, height: 44))
        
        lb.font = UIFont.boldSystemFont(ofSize: 20)
        lb.textAlignment = .center
        lb.numberOfLines = 2
        return lb
    }()
    
    var ingredientItemList: [IngredientModelData]? {
        didSet {
            guard let _ = self.tbvAddIngredient else { return }
            self.tbvAddIngredient.reloadData()
        }
    }
    
    var stepItemList: [StepModelData]? {
        didSet {
            guard let _ = self.tbvAddSteps else { return }
            self.tbvAddSteps.reloadData()
        }
    }
    
    var recipeData: RecipeItem?
    var contextIndex: Int?
    
    var coreDataStack: CoreDataStack!
    var fetchedResultsController : NSFetchedResultsController<RecipeItem>!
    
    weak var delegate: CreateNewRecipeDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imvCover.contentMode = .scaleAspectFit
        setUpView()
        setupComponent()
    }
    
    private func setUpView() {
        lbTitle.sizeToFit()
        self.navigationItem.titleView = lbTitle
        self.navigationController?.navigationBar.setTitleVerticalPositionAdjustment(3, for: UIBarMetrics.default)
        self.navigationController?.navigationBar.tintColor = .darkGray
        
        if recipeData != nil {
            //edit
            lbTitle.text = "Update Recipe".uppercased()
            tfInputReName.text = recipeData?.name
            tfInputReType.text = recipeData?.type
            imvCover.image = recipeData?.coverImage == nil ? UIImage(named: "image_material_sample") : UIImage(data: (recipeData?.coverImage!)!)
        } else {
            lbTitle.text = "Create Recipe".uppercased()
        }
    }
    
    private func setupComponent() {
        tbvAddIngredient.delegate = self
        tbvAddIngredient.dataSource = self
        tbvAddIngredient.register(UINib(nibName: "IngredientTableViewCell", bundle:  nil), forCellReuseIdentifier: "IngredientTableViewCell")
        tbvAddIngredient.register(UINib(nibName: "AddingCellTableViewCell", bundle:  nil), forCellReuseIdentifier: "AddingCellTableViewCell")
        tbvAddIngredient.rowHeight = UITableView.automaticDimension
        tbvAddIngredient.estimatedRowHeight = 600
        
        tbvAddSteps.delegate = self
        tbvAddSteps.dataSource = self
        tbvAddSteps.register(UINib(nibName: "StepsTableViewCell", bundle:  nil), forCellReuseIdentifier: "StepsTableViewCell")
        tbvAddSteps.register(UINib(nibName: "AddingCellTableViewCell", bundle:  nil), forCellReuseIdentifier: "AddingCellTableViewCell")
        tbvAddSteps.rowHeight = UITableView.automaticDimension
        tbvAddSteps.estimatedRowHeight = 600
    }
    
    private func dataSetup() {
        
        let fetchRequest: NSFetchRequest<RecipeItem> = RecipeItem.fetchRequest()
        
        let date = NSSortDescriptor(key: #keyPath(RecipeItem.dateCreated), ascending: false)
        
        fetchRequest.sortDescriptors = [date]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                              managedObjectContext: coreDataStack.managedContext,
                                                              sectionNameKeyPath: #keyPath(RecipeItem.dateCreated),
                                                              cacheName: "reList")
        //        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
            
        } catch let error as NSError {
            print("Fetching error: \(error), \(error.userInfo)")
        }
    }
    
    @IBAction func btnAddCoverTapper(_ sender: Any) {
        let imagePickerActionSheet = UIAlertController(title: "Upload Image",
                                                       message: nil,
                                                       preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraButton = UIAlertAction(
                title: "Take Photo",
                style: .default) { (alert) -> Void in
                    
                    let imagePicker = UIImagePickerController()
                    imagePicker.delegate = self
                    imagePicker.sourceType = .camera
                    imagePicker.mediaTypes = [kUTTypeImage as String]
                    self.present(imagePicker, animated: true, completion: {
                        
                    })
            }
            imagePickerActionSheet.addAction(cameraButton)
        }
        
        let libraryButton = UIAlertAction(
            title: "Choose Existing",
            style: .default) { (alert) -> Void in
                
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .photoLibrary
                imagePicker.mediaTypes = [kUTTypeImage as String]
                self.present(imagePicker, animated: true, completion: {
                    
                })
        }
        
        imagePickerActionSheet.addAction(libraryButton)
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel)
        imagePickerActionSheet.addAction(cancelButton)
        
        present(imagePickerActionSheet, animated: true)
    }
    
    @IBAction func btnDoneTapped(_ sender: Any) {
        //This is just for the update of detail page
        if recipeData != nil {
            recipeData?.name = tfInputReName.text!
            recipeData?.type = tfInputReType.text!
            recipeData?.coverImage = imvCover.image?.pngData()
            coreDataStack.saveContext()
            delegate?.didCreate(with: recipeData!) //Alway not-nil
            
            navigationController?.popViewController(animated: true)
        } else {
            if (tfInputReType.text?.isEmpty)! || (tfInputReName.text?.isEmpty)! || (ingredientItemList?.count == 0) || ((ingredientItemList?.count == 0)) {
                let choicePicker = UIAlertController(title: "Make sure all informaiton should be input",
                                                     message: "Ok to Input Again!",
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
            
            //persistent data
            let igradientEntity = NSEntityDescription.entity(forEntityName: "IngredientItem", in: coreDataStack.managedContext)!
            let stepEntity = NSEntityDescription.entity(forEntityName: "StepItem", in: coreDataStack.managedContext)!
            let recipeEntity = NSEntityDescription.entity(forEntityName: "RecipeItem", in: coreDataStack.managedContext)!
            
            let recipe = RecipeItem(entity: recipeEntity, insertInto: coreDataStack.managedContext)
            
            ingredientItemList?.forEach({ (dataIng) in
                let ingredient = IngredientItem(entity: igradientEntity, insertInto: coreDataStack.managedContext)
                ingredient.materialName = dataIng.materialName
                ingredient.quantity = dataIng.quantity
                ingredient.descriptionNote = dataIng.descriptionNote
                recipe.addToIngredients(ingredient)
            })
            
            stepItemList?.forEach({ (dataStep) in
                let step = StepItem(entity: stepEntity, insertInto: coreDataStack.managedContext)
                step.stepName = dataStep.stepName
                step.stepOrder = dataStep.stepOrder
                step.descriptionNote = dataStep.descriptionNote
                step.imageStep = dataStep.imageData
                
                recipe.addToStepsRecipe(step)
                
            })
            
            recipe.name =  tfInputReName.text!
            recipe.type = tfInputReType.text!
            recipe.dateCreated = Date().formattedShoter()
            recipe.coverImage = imvCover.image?.pngData()
            
            if coreDataStack.managedContext.hasChanges {
                coreDataStack.saveContext()
            }
            
            delegate?.didCreate(with: recipe) //Alway not-nil
            
            navigationController?.popViewController(animated: true)
        }
        
    }
    
}
extension CreateRecipeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tbvAddIngredient {
            if section == 0 {
                if recipeData == nil {
                    return ingredientItemList?.count ?? 0
                } else {
                    return recipeData?.ingredients?.count ?? 0
                }
            } else {
                return 1
            }
        } else {
            if section == 0 {
                if recipeData == nil {
                    return stepItemList?.count ?? 0
                } else {
                    return recipeData?.stepsRecipe?.count ?? 0
                }
            } else {
                return 1
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let addingCell = tableView.dequeueReusableCell(withIdentifier: "AddingCellTableViewCell", for: indexPath) as! AddingCellTableViewCell
        if tableView == tbvAddIngredient {
            if indexPath.section == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "IngredientTableViewCell", for: indexPath) as! IngredientTableViewCell
                if recipeData != nil {
                    cell.bindData(data: recipeData?.ingredients?[indexPath.row] as! IngredientItem)
                } else {
                    guard let dataList = ingredientItemList else { return cell }
                    cell.setData(data: dataList[indexPath.row])
                }
                return cell
            } else {
                return addingCell
            }
            
        } else {
            if indexPath.section == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "StepsTableViewCell", for: indexPath) as! StepsTableViewCell
                
                if recipeData != nil {
                    cell.bindData(data: recipeData?.stepsRecipe?[indexPath.row] as! StepItem)
                } else {
                    guard let dataList = stepItemList else { return cell }
                    cell.setData(data: dataList[indexPath.row])
                }
                return cell
            } else {
                return addingCell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == tbvAddIngredient {
            if recipeData != nil {
                if indexPath.section == 0 {
                    //edit
                    let vc = AddingIngredientViewController.instantiateFromNib()
                    vc.delegate = self
                    vc.ingredientOrder = indexPath.row
                    vc.dataEditIngredientItem = recipeData?.ingredients?[indexPath.row] as? IngredientItem
                    navigationController?.pushViewController(vc, animated: true)
                    
                } else {
                    let vc = AddingIngredientViewController.instantiateFromNib()
                    vc.delegate = self
                    
                    vc.ingredientOrder = (recipeData?.ingredients?.count ?? 0)
                    navigationController?.pushViewController(vc, animated: true)
                }
            } else {
                if indexPath.section == 0 {
                    //edit
                    guard let dataList = ingredientItemList else { return }
                    let vc = AddingIngredientViewController.instantiateFromNib()
                    vc.delegate = self
                    vc.dataEditIngredient = dataList[indexPath.row]
                    navigationController?.pushViewController(vc, animated: true)
                } else {
                    let vc = AddingIngredientViewController.instantiateFromNib()
                    vc.delegate = self
                    vc.ingredientOrder = (ingredientItemList?.count ?? 0)
                    navigationController?.pushViewController(vc, animated: true)
                }
            }
            
        } else {
            if recipeData != nil {
                if indexPath.section == 0 {
                    let vc = AddStepItemViewController.instantiateFromNib()
                    vc.delegate = self
                    vc.stepOrder = indexPath.row
                    vc.dataStepItem = recipeData?.stepsRecipe?[indexPath.row] as? StepItem
                    navigationController?.pushViewController(vc, animated: true)
                } else {
                    let vc = AddStepItemViewController.instantiateFromNib()
                    vc.delegate = self
                    vc.stepOrder = (recipeData?.stepsRecipe?.count ?? 0)
                    navigationController?.pushViewController(vc, animated: true)
                }
            } else {
                if indexPath.section == 0 {
                    guard let dataList = stepItemList else { return }
                    let vc = AddStepItemViewController.instantiateFromNib()
                    vc.delegate = self
                    vc.dataStepEdit = dataList[indexPath.row]
                    navigationController?.pushViewController(vc, animated: true)
                } else {
                    let vc = AddStepItemViewController.instantiateFromNib()
                    vc.stepOrder = (stepItemList?.count ?? 0) + 1
                    vc.delegate = self
                    navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if recipeData != nil {
            //edit
            if tableView == tbvAddIngredient {
                if editingStyle == .delete {
                    recipeData?.removeFromIngredients(at: indexPath.row)
                    tbvAddIngredient.reloadData()
                } else {}
            } else {
                if editingStyle == .delete {
                    recipeData?.removeFromStepsRecipe(at: indexPath.row)
                    tbvAddSteps.reloadData()
                } else {}
            }
            
        } else {
            if tableView == tbvAddIngredient {
                if editingStyle == .delete {
                    self.ingredientItemList?.remove(at: indexPath.row)
                } else {}
            } else {
                if editingStyle == .delete {
                    self.stepItemList?.remove(at: indexPath.row)
                } else {}
            }
        }
    }
}


// MARK: - UIImagePickerControllerDelegate
extension CreateRecipeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedPhoto = info[.originalImage] as? UIImage else {
            dismiss(animated: true)
            return
        }
        dismiss(animated: true) {
            //do some thing
            self.imvCover.contentMode = .scaleAspectFit
            self.imvCover.image = selectedPhoto
        }
    }
    
}


extension CreateRecipeViewController: AddingIngredientViewControllerDelegate, AddStepItemViewControllerDelegate {
    func didDoneIngredient(with data: IngredientModelData, isEdit: Bool) {
        
        if recipeData != nil {
            let igradientEntity = NSEntityDescription.entity(forEntityName: "IngredientItem", in: coreDataStack.managedContext)!
           
            let ingredient = IngredientItem(entity: igradientEntity, insertInto: coreDataStack.managedContext)
            ingredient.quantity = data.quantity
            ingredient.materialName = data.materialName
            ingredient.descriptionNote = data.descriptionNote
            
            if isEdit == true {
                recipeData?.removeFromIngredients(at: Int(data.ingredientOrder ?? "0") ?? 0)
                recipeData?.insertIntoIngredients(ingredient, at: Int(data.ingredientOrder ?? "0") ?? 0)
            } else {
                recipeData?.insertIntoIngredients(ingredient, at: Int(data.ingredientOrder ?? "0") ?? 0)
            }
            
            tbvAddIngredient.reloadData()
            
        } else {
            if isEdit == true {
                if let row = self.ingredientItemList?.firstIndex(where: {$0.ingredientOrder == data.ingredientOrder}) {
                    ingredientItemList?[row] = data
                }
                tbvAddIngredient.reloadData()
            } else {
                ingredientItemList?.insert(data, at: Int(data.ingredientOrder ?? "0") ?? 0)
            }
        }
    }
    
    func didDoneStepwith(with data: StepModelData, isEdit: Bool) {
       
        if recipeData != nil {
            let stepEntity = NSEntityDescription.entity(forEntityName: "StepItem", in: coreDataStack.managedContext)!
            
            let step = StepItem(entity: stepEntity, insertInto: coreDataStack.managedContext)
            step.stepName = data.stepName
            step.imageStep = data.imageData
            step.descriptionNote = data.descriptionNote
            
            if isEdit == true {
                recipeData?.removeFromStepsRecipe(at: Int(data.stepOrder ?? "0") ?? 0)
                recipeData?.insertIntoStepsRecipe(step, at: Int(data.stepOrder ?? "0") ?? 0)
            } else {
                recipeData?.insertIntoStepsRecipe(step, at: Int(data.stepOrder ?? "0") ?? 0)
            }
            
            tbvAddSteps.reloadData()
            
        } else {
            if isEdit == true {
                if let row = self.stepItemList?.firstIndex(where: {$0.stepOrder == data.stepOrder}) {
                    stepItemList?[row] = data
                }
                tbvAddSteps.reloadData()
            } else {
                stepItemList?.append(data)
            }
        }
    }
    
}
