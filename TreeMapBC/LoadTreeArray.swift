//
//  LoadTreeArray.swift
//  TreeMapBC
//
//  Created by Allen on 11/07/2019.
//  Copyright © 2019 Allen+Megan. All rights reserved.
//

import Foundation
import MapKit
import SwiftCSV

func loadTreeArray() -> [Tree]{
    // Load CSV file into Tree Data Array
    var treeDataArray = [[String]]()
    let filePath = Bundle.main.url(forResource: "BCTrees", withExtension: "csv")
    do {
        let csvFile: CSV = try CSV(url: filePath!)
        let rows = csvFile.enumeratedRows
        for row in rows {
            let tag = row[0]
            let latitude = row[1]
            let longitude = row[2]
            let commonName = row[3]
            let botanicalName = row[4]
            let campus = row[5]
            let dbh = row[6]
            let status = row[7]
            let co2Offset = row[10]
            let distanceDriven = String(format: "%.1f", Double(co2Offset)! * 2.475 )
            let carbonStorage = row[11]
            let pollutionRemoved = row[12]
            let waterIntercepted = String(format: "%.1f", Double(row[13])! * 7.48052 )
            let treeData = [tag,latitude,longitude,commonName,botanicalName,campus,dbh,status,co2Offset,distanceDriven,carbonStorage,pollutionRemoved,waterIntercepted]
            treeDataArray.append(treeData)
        }
    } catch {
    }
    // Populate Tree Array with Tree Data Array
    var treeArray = [Tree]()
    for treeData in treeDataArray {
        if treeData[7] == "Living" {
            let originalName = treeData[3]
            let fixedName = nameDictionary.dict[originalName]
            let tree = Tree(title: fixedName!, detail: treeData, coordinate: CLLocationCoordinate2D(latitude: Double(treeData[1])!, longitude: Double(treeData[2])!))
            treeArray.append(tree)
        }
    }
    return treeArray
}

class treeData{
    static let array: [Tree] = loadTreeArray()
}
