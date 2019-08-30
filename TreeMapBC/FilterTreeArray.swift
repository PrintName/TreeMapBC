//
//  FilterTreeArray.swift
//  TreeMapBC
//
//  Created by Allen on 11/07/2019.
//  Copyright © 2019 Allen+Megan. All rights reserved.
//

import Foundation

func filterArray(originalTreeArray: [Tree], filterData: [String:String]) -> [Tree]{
    
    // If no filters, reset
    if filterData["commonNameText"]!.isEmpty && filterData["botanicalNameText"]!.isEmpty && filterData["tagLowText"]!.isEmpty && filterData["tagHighText"]!.isEmpty && filterData["diameterLowText"]!.isEmpty && filterData["diameterHighText"]!.isEmpty && filterData["mainCampus"]!.isEmpty && filterData["pineTreeReserve"]!.isEmpty && filterData["brightonCampus"]!.isEmpty && filterData["newtonCampus"]!.isEmpty {
        return originalTreeArray
    }
    
    
    var arrayOfSets = [Set<Tree>]()
    
    if !filterData["commonNameText"]!.isEmpty {
        let commonNameArray = originalTreeArray.filter { nameDictionary.dict[$0.detail[3]]!.lowercased() == filterData["commonNameText"]!.lowercased() }
        arrayOfSets.append(Set(commonNameArray))
    }
    if !filterData["botanicalNameText"]!.isEmpty {
        let botanicalNameArray = originalTreeArray.filter { $0.detail[4].lowercased() == filterData["botanicalNameText"]!.lowercased() }
        arrayOfSets.append(Set(botanicalNameArray))
    }
    if !filterData["tagLowText"]!.isEmpty {
        let tagLowArray = originalTreeArray.filter { Int($0.detail[0])! >= Int(filterData["tagLowText"]!)! }
        arrayOfSets.append(Set(tagLowArray))
    }
    if !filterData["tagHighText"]!.isEmpty {
        let tagHighArray = originalTreeArray.filter { Int($0.detail[0])! <= Int(filterData["tagHighText"]!)! }
        arrayOfSets.append(Set(tagHighArray))
    }
    if !filterData["diameterLowText"]!.isEmpty {
        let diameterLowArray = originalTreeArray.filter { Int($0.detail[6])! >= Int(filterData["diameterLowText"]!)! }
        arrayOfSets.append(Set(diameterLowArray))
    }
    if !filterData["diameterHighText"]!.isEmpty {
        let diameterHighArray = originalTreeArray.filter { Int($0.detail[6])! <= Int(filterData["diameterHighText"]!)! }
        arrayOfSets.append(Set(diameterHighArray))
    }
    if filterData["mainCampus"] == "false" {
        let mainCampusArray = originalTreeArray.filter { $0.detail[5] != "Chestnut Hill Campus" && $0.detail[5] != "N/A" }
        arrayOfSets.append(Set(mainCampusArray))
    }
    if filterData["pineTreeReserve"] == "false" {
        let pineTreeReserveArray = originalTreeArray.filter { $0.detail[5] != "Pine Tree Reserve" && $0.detail[5] != "N/A" }
        arrayOfSets.append(Set(pineTreeReserveArray))
    }
    if filterData["brightonCampus"] == "false" {
        let brightonCampusArray = originalTreeArray.filter { $0.detail[5] != "Brighton Campus" && $0.detail[5] != "N/A" }
        arrayOfSets.append(Set(brightonCampusArray))
    }
    if filterData["newtonCampus"] == "false" {
        let newtonCampusArray = originalTreeArray.filter { $0.detail[5] != "Newton Campus" && $0.detail[5] != "N/A" }
        arrayOfSets.append(Set(newtonCampusArray))
    }
    
    var filteredTreeSet = arrayOfSets[0]
    if arrayOfSets.count > 1 {
        for i in 1 ..< arrayOfSets.count {
            filteredTreeSet.formIntersection(arrayOfSets[i])
        }
    }
    
    let filteredTreeArray = Array(filteredTreeSet)
    
    var co2Offset = 0.0
    var distanceDriven = 0.0
    var carbonStorage = 0.0
    var pollutionRemoved = 0.0
    var waterIntercepted = 0.0

    for tree in filteredTreeArray {
        co2Offset = co2Offset + Double(tree.detail[8])!
        distanceDriven = distanceDriven + Double(tree.detail[9])!
        carbonStorage = carbonStorage + Double(tree.detail[10])!
        pollutionRemoved = pollutionRemoved + Double(tree.detail[11])!
        waterIntercepted = waterIntercepted + Double(tree.detail[12])!
    }
    
    FilteredImpact.data.append(String(Int(co2Offset).commas))
    FilteredImpact.data.append(String(Int(distanceDriven).commas))
    FilteredImpact.data.append(String(Int(Double(carbonStorage)).commas))
    FilteredImpact.data.append(String(Int(pollutionRemoved).commas))
    FilteredImpact.data.append(String(Int(waterIntercepted).commas))
    
    return filteredTreeArray
    
}

class FilteredImpact {
    static var data: [String] = []
}

extension Int {
    
    private static var addCommas: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter
    }()
    
    internal var commas: String {
        return Int.addCommas.string(from: NSNumber(value: self)) ?? ""
    }
}
