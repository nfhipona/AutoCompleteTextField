//
//  ACTFProtocols.swift
//  Pods
//
//  Created by Neil Francis Hipona on 16/07/2016.
//  Copyright (c) 2016 Neil Francis Ramirez Hipona. All rights reserved.
//

import Foundation
import UIKit

// MARK: - AutoCompleteTextField Protocol

public protocol ACTFDataSource: AnyObject {
    // Required protocols
    
    /// called when in need of suggestions.
    func autoCompleteTextFieldDataSource(_ autoCompleteTextField: AutoCompleteTextField) -> [ACTFDomain]
}

public protocol ACTFDelegate: AnyObject {
    /// will be called upon successful suggestion
    func autoCompleteTextField(_ autoCompleteTextField: AutoCompleteTextField, didSuggestDomain domain: ACTFDomain)
}
