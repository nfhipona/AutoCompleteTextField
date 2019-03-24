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
    
    func autoCompleteTextFieldDataSource(_ autoCompleteTextField: AutoCompleteTextField) -> [ACTFDomain] // called when in need of suggestions.
}
