//
//  RecipeModel.swift
//  RecipeApp
//
//  Created by Lam Pham on 2/23/20.
//  Copyright © 2020 Lam Pham. All rights reserved.
//

import XMLMapper


class ListDataModel: XMLMappable {
    var nodeName: String!
    
    var dataList: [RecipeModel]!
 
    required init?(map: XMLMap) { }
    
    func mapping(map: XMLMap) {
        dataList    <- map["dataList"]
    }
}

class RecipeModel: XMLMappable {
    var nodeName: String!
    
    var name: String!
    var dateCreated: String?
    var type: String?
    var coverImage: String?
    var ingredients: [IngredientModel]?
    var steps: [StepModel]?
    
    
    required init?(map: XMLMap) { }
    
    func mapping(map: XMLMap) {
        name    <- map["name"]
        dateCreated        <- map["dateCreated"]
        type    <- map["type"]
        coverImage        <- map["coverImage"]
        ingredients    <- map["ingredients"]
        steps        <- map["steps"]
    }
}

class StepModel: XMLMappable {
    var nodeName: String!
    
    var stepOrder: String!
    var stepName: String!
    var descriptionNote: String!
    
    required init?(map: XMLMap) { }
    
    func mapping(map: XMLMap) {
        stepOrder    <- map["stepOrder"]
        stepName        <- map["stepName"]
        descriptionNote        <- map["descriptionNote"]
    }
}


class IngredientModel: XMLMappable {
    var nodeName: String!
    
    var materialName: String!
    var quantity: String!
    var image: String!
    var descriptionNote: String!
    
    required init?(map: XMLMap) { }
    
    func mapping(map: XMLMap) {
        materialName    <- map["materialName"]
        quantity        <- map["quantity"]
        image    <- map["image"]
        descriptionNote        <- map["descriptionNote"]
    }
}

struct IngredientModelData {
    var ingredientOrder: String?
    var materialName: String?
    var quantity: String?
    var image: String?
    var descriptionNote: String?
}

struct StepModelData {
    var stepOrder: String?
    var stepName: String?
    var descriptionNote: String?
    var imageData: Data?
}
