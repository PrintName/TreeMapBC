//
//  FilterViewController.swift
//  TreeMapBC
//
//  Created by Allen on 11/07/2019.
//  Copyright © 2019 Allen+Megan. All rights reserved.
//

import UIKit
import SideMenu

protocol dataProtocal {
    func sendData(filterData: [String:String])
}

class FilterViewController: UIViewController, UITextFieldDelegate {
    
    var delegate: dataProtocal? = nil
    
    @IBOutlet weak var commonNameText: UITextField!
    
    @IBOutlet weak var botanicalNameText: UITextField!
    
    @IBOutlet weak var tagLowText: UITextField!
    @IBOutlet weak var tagHighText: UITextField!
    
    @IBOutlet weak var diameterLowText: UITextField!
    @IBOutlet weak var diameterHighText: UITextField!
    
    @IBOutlet weak var mainCampus: UISwitch!
    @IBOutlet weak var pineTreeReserve: UISwitch!
    @IBOutlet weak var brightonCampus: UISwitch!
    @IBOutlet weak var newtonCampus: UISwitch!
    
    var oldFilterData : [String:String] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SideMenuManager.default.menuPresentMode = .menuSlideIn
        SideMenuManager.default.menuFadeStatusBar = false
        SideMenuManager.default.menuWidth = 245
        
        // Set old filter text values
        commonNameText.text = oldFilterData["commonNameText"]
        botanicalNameText.text = oldFilterData["botanicalNameText"]
        tagLowText.text = oldFilterData["tagLowText"]
        tagHighText.text = oldFilterData["tagHighText"]
        diameterLowText.text = oldFilterData["diameterLowText"]
        diameterHighText.text = oldFilterData["diameterHighText"]
        
        if oldFilterData["mainCampus"] == "false" {
            mainCampus.setOn(false, animated: true)
        }
        if oldFilterData["pineTreeReserve"] == "false" {
            pineTreeReserve.setOn(false, animated: true)
        }
        if oldFilterData["brightonCampus"] == "false" {
            brightonCampus.setOn(false, animated: true)
        }
        if oldFilterData["newtonCampus"] == "false" {
            newtonCampus.setOn(false, animated: true)
        }
        
        // Keyboard setup
        self.commonNameText.delegate = self
        self.botanicalNameText.delegate = self
        self.tagLowText.delegate = self
        self.tagHighText.delegate = self
        self.diameterLowText.delegate = self
        self.diameterHighText.delegate = self
        self.addDoneButtonOnKeyboard()
        // Keyboard set numerical keyboards
        tagLowText.keyboardType = UIKeyboardType.numberPad
        tagHighText.keyboardType = UIKeyboardType.numberPad
        diameterLowText.keyboardType = UIKeyboardType.numberPad
        diameterHighText.keyboardType = UIKeyboardType.numberPad
    }
    
    // Keyboard add "Done" button toolbar
    func addDoneButtonOnKeyboard()
    {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))

        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.commonNameText.inputAccessoryView = doneToolbar
        self.botanicalNameText.inputAccessoryView = doneToolbar
        self.tagLowText.inputAccessoryView = doneToolbar
        self.tagHighText.inputAccessoryView = doneToolbar
        self.diameterLowText.inputAccessoryView = doneToolbar
        self.diameterHighText.inputAccessoryView = doneToolbar
    }
    // keyboard pressed "Done"
    @objc func doneButtonAction()
    {
        self.view.endEditing(true);
    }

    @IBAction func filter(_ sender: Any) {
        
        filteredImpact.data=[]
        
        if self.delegate != nil {
            var filterData : [String:String] = [:]
            
            // Text boxes
            filterData["commonNameText"] = commonNameText.text
            filterData["botanicalNameText"] = botanicalNameText.text
            filterData["tagLowText"] = tagLowText.text
            filterData["tagHighText"] = tagHighText.text
            filterData["diameterLowText"] = diameterLowText.text
            filterData["diameterHighText"] = diameterHighText.text
            
            // Switches on
            filterData["mainCampus"] = ""
            filterData["pineTreeReserve"] = ""
            filterData["brightonCampus"] = ""
            filterData["newtonCampus"] = ""
            
            // Switches off
            if self.mainCampus.isOn == false {
                filterData["mainCampus"] = "false"
            }
            if self.pineTreeReserve.isOn == false {
                filterData["pineTreeReserve"] = "false"
            }
            if self.brightonCampus.isOn == false {
                filterData["brightonCampus"] = "false"
            }
            if self.newtonCampus.isOn == false {
                filterData["newtonCampus"] = "false"
            }
            
            self.delegate?.sendData(filterData: filterData)
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func reset(_ sender: Any) {
        
        filteredImpact.data=[]
        
        var filterData : [String:String] = [:]
        filterData["commonNameText"] = ""
        filterData["botanicalNameText"] = ""
        filterData["tagLowText"] = ""
        filterData["tagHighText"] = ""
        filterData["diameterLowText"] = ""
        filterData["diameterHighText"] = ""
        filterData["mainCampus"] = ""
        filterData["pineTreeReserve"] = ""
        filterData["brightonCampus"] = ""
        filterData["newtonCampus"] = ""
        
        self.delegate?.sendData(filterData: filterData)
        dismiss(animated: true, completion: nil)
    }
    
}

// White status bar
extension UINavigationController {
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
