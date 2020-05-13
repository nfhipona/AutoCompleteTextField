//
//  ViewController.swift
//  AutoCompleteTextField
//
//  Created by Neil Francis Ramirez Hipona on 03/19/2016.
//  Copyright (c) 2016 Neil Francis Ramirez Hipona. All rights reserved.
//

import UIKit
import AutoCompleteTextField

class ViewController: UIViewController, ACTFDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var txtEmail: AutoCompleteTextField!
    @IBOutlet weak var txtReEmail: AutoCompleteTextField!
    @IBOutlet weak var txtPassword: AutoCompleteTextField!
    
    let domainNames = ["gmail.com",
                       "yahoo.com",
                       "hotmail.com",
                       "aol.com",
                       "comcast.net",
                       "me.com",
                       "msn.com",
                       "live.com",
                       "sbcglobal.net",
                       "ymail.com",
                       "icloud.com"]
    
    // add weighted domain names
    var weightedDomains: [ACTFDomain] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Optional setting for delegate if not setted in IB
        // txtEmail.dataSource = self
        txtReEmail.dataSource = self
        
        txtEmail.setDelimiter("@")
        txtReEmail.setDelimiter("@")
        
        txtEmail.delegate = self
        txtReEmail.delegate = self
        
        // Show right side complete button
        txtEmail.showAutoCompleteButtonWithImage(UIImage(named: "checked"), viewMode: .whileEditing)
        txtReEmail.showAutoCompleteButtonWithImage(UIImage(named: "checked"), viewMode: .whileEditing)
        
        // Initializing with datasource and delegate
        /*let actfWithDelegateAndDataSource = AutoCompleteTextField(frame: CGRect(x: 20, y: 64, width: view.frame.width - 40, height: 40), dataSource: self, delegate: self)
        actfWithDelegateAndDataSource.backgroundColor = .red
        view.addSubview(actfWithDelegateAndDataSource)*/
        
        let g1 = ACTFDomain(text: "gmail.com", weight: 10)
        let g2 = ACTFDomain(text: "googlemail.com", weight: 5)
        let g3 = ACTFDomain(text: "google.com", weight: 4)
        let g4 = ACTFDomain(text: "georgetown.edu", weight: 1)
        weightedDomains = [g1, g2, g3, g4]
        
        // store single
        if g1.store(withKey: "Domain") {
            print("Store success")
        }
        // store multiple
        if ACTFDomain.store(domains: weightedDomains, withKey: "Domains") {
            print("Store success")
        }
        
        // retrieved single
        if let domain = ACTFDomain.domain(forKey: "Domain") {
            print("Retrieved: ", domain)
        }
        
        // retrieved multiple
        if let domains = ACTFDomain.domains(forKey: "Domains") {
            print("Retrieved: ", domains)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - ACTFDataSource
    
    func autoCompleteTextFieldDataSource(_ autoCompleteTextField: AutoCompleteTextField) -> [ACTFDomain] {
        
        return weightedDomains // AutoCompleteTextField.domainNames // [ACTFDomain(text: "gmail.com", weight: 0), ACTFDomain(text: "hotmail.com", weight: 0), ACTFDomain(text: "domain.net", weight: 0)]
    }
    
    // MARK: - UITextFieldDelegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == txtEmail {
            return txtReEmail.becomeFirstResponder()
        } else if textField == txtReEmail {
            return txtPassword.becomeFirstResponder()
        } else {
            return txtPassword.resignFirstResponder()
        }
    }
}

