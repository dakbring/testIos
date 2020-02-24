//
//  RecipesListViewController.swift
//  RecipeApp
//
//  Created by Lam Pham on 2/22/20.
//  Copyright © 2020 Lam Pham. All rights reserved.
//

import UIKit
import CoreData

class RecipesListViewController: UIViewController {
    
    @IBOutlet weak var tbvRecipesList: UITableView!
    @IBOutlet weak var pickerView: UIPickerView!
    
    @IBOutlet weak var lcsPikerHeight: NSLayoutConstraint!
    
    var rightButton: UIBarButtonItem?
    var filter: Bool = false
    
    lazy var lbTitle:UILabel = {
        let lb = UILabel(frame: CGRect(x: (UIScreen.main.bounds.width - self.view.bounds.width/4)/2, y: 0,
                                       width: self.view.bounds.width, height: 44))
        
        lb.font = UIFont.boldSystemFont(ofSize: 20)
        lb.textAlignment = .center
        lb.numberOfLines = 2
        return lb
    }()
    
    var fetchRequest: NSFetchRequest<RecipeItem>!
    
    var coreDataStack: CoreDataStack!
    var fetchedResultsController : NSFetchedResultsController<RecipeItem>!
    var pickerData: [String] = [String]()
    
    var recipeItem: [RecipeItem]? {
        didSet {
            tbvRecipesList.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        setUpComponent()
        dataSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tbvRecipesList.reloadData()
        
        filter = false
        if !(pickerData.isEmpty) {
            pickerData.removeAll()
            pickerData = ["All"]
            fetchedResultsController.fetchedObjects?.forEach({ (returnData) in
                self.pickerData.append(returnData.type ?? "type")
            })
               pickerView.reloadAllComponents()
        } else {}
    }
    
    private func setUpView() {
        lbTitle.text = "Recipe List".uppercased()
        lbTitle.sizeToFit()
        self.navigationItem.titleView = lbTitle
        self.navigationController?.navigationBar.setTitleVerticalPositionAdjustment(3, for: UIBarMetrics.default)
        self.navigationController?.navigationBar.tintColor = .darkGray
    }
    
    private func setUpComponent() {
        tbvRecipesList.register(UINib(nibName: "RecipeItemTableViewCell", bundle:  nil), forCellReuseIdentifier: "RecipeItemTableViewCell")
        tbvRecipesList.delegate = self
        tbvRecipesList.dataSource = self
        tbvRecipesList.rowHeight = UITableView.automaticDimension
        tbvRecipesList.estimatedRowHeight = 600
        
        rightButton = UIBarButtonItem(title: "ADD+", style: .done, target: self, action: #selector(nextTapped))
        rightButton?.tintColor = .darkGray
        self.navigationItem.rightBarButtonItem = rightButton
        
        pickerView.delegate = self
        pickerView.dataSource = self
        
    }
    
    private func dataSetup() {
        pickerData.removeAll()
        pickerData = ["All"]
        fetchRequest = RecipeItem.fetchRequest()
        
        let date = NSSortDescriptor(key: #keyPath(RecipeItem.dateCreated), ascending: false)
        
        fetchRequest.sortDescriptors = [date]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                              managedObjectContext: coreDataStack.managedContext,
                                                              sectionNameKeyPath: #keyPath(RecipeItem.dateCreated),
                                                              cacheName: "reList")
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
            fetchedResultsController.fetchedObjects?.forEach({ (returnData) in
                self.pickerData.append(returnData.type ?? "type")
            })
        } catch let error as NSError {
            print("Fetching error: \(error), \(error.userInfo)")
        }
    }
    
    @objc func nextTapped(sender: AnyObject) {
        let vc = CreateRecipeViewController.instantiateFromNib()
        vc.delegate = self
        vc.ingredientItemList = [IngredientModelData]()
        vc.stepItemList = [StepModelData]()
        vc.coreDataStack = self.coreDataStack
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension RecipesListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filter == true {
            return recipeItem?.count ?? 0
        } else {
            let sectionInfo = fetchedResultsController.sections![section]
            return sectionInfo.numberOfObjects
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if filter == true {
            return 1
        } else {
            return fetchedResultsController.sections?.count ?? 0
        }
          
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tbvRecipesList.dequeueReusableCell(withIdentifier: "RecipeItemTableViewCell", for: indexPath) as! RecipeItemTableViewCell
        if filter == true {
            let dataToShow = recipeItem?[indexPath.row]
            cell.lbReNAme.text = dataToShow?.name
            
            cell.imvCover?.image = dataToShow?.coverImage == nil ? UIImage(named: "image_material_sample") : UIImage(data: (dataToShow?.coverImage!)!)
        } else {
            let dataToShow = fetchedResultsController.object(at: indexPath)
            cell.lbReNAme.text = dataToShow.name
            
            cell.imvCover?.image = dataToShow.coverImage == nil ? UIImage(named: "image_material_sample") : UIImage(data: dataToShow.coverImage!)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if filter == false {
            let vc = RecipeDetailViewController.instantiateFromNib()
            vc.recipeData = fetchedResultsController.object(at: indexPath)
            vc.contextIndex = indexPath.row
            vc.coreDataStack = self.coreDataStack
            navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = RecipeDetailViewController.instantiateFromNib()
            vc.recipeData = recipeItem?[indexPath.row]
            vc.contextIndex = indexPath.row
            vc.coreDataStack = self.coreDataStack
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let recipe = fetchedResultsController.object(at: indexPath)
        coreDataStack.managedContext.delete(recipe)
        do {
             try coreDataStack.managedContext.save()
             
            tableView.reloadData()
           } catch let error as NSError {
             print("Saving error: \(error), description: \(error.userInfo)")
           }
    }
    
}

extension RecipesListViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any, at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            break
        case .delete:
            tbvRecipesList.reloadData()
            break
        case .update:
            break
        case .move:
            break
        }
    }
}

extension RecipesListViewController: CreateNewRecipeDelegate {
    func didCreate(with recipe: RecipeItem) {
        tbvRecipesList.reloadData()
        dataSetup()
    }
    
}
extension RecipesListViewController: UIPickerViewDelegate, UIPickerViewDataSource {


    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int,
                    forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int,
                    inComponent component: Int) {
        print(pickerData[row])

        if pickerData[row] == "All" {
            filter = false
            tbvRecipesList.reloadData()
        } else {
            
            let predicate: NSPredicate = {
                return NSPredicate(format: "%K == %@", #keyPath(RecipeItem.type), pickerData[row])
            }()
            
            fetchRequest.predicate = nil
            fetchRequest.sortDescriptors = nil
            
            fetchRequest.predicate = predicate
            let date = NSSortDescriptor(key: #keyPath(RecipeItem.dateCreated), ascending: false)
            
            fetchRequest.sortDescriptors = [date]
            
            fetchAndReload()
        }
    }
    
    func fetchAndReload() {
        do {
            filter = true
            recipeItem?.removeAll()
            recipeItem = try coreDataStack.managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
}
