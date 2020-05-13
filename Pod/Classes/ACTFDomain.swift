//
//  ACTFWeightedDomain.swift
//  Pods
//
//  Created by Neil Francis Hipona on 9/15/17.
//  Copyright © 2017 AJ Bartocci. All rights reserved.
//

import Foundation

public struct ACTFDomain: Codable {
    
    public let text: String
    public var weight: Int
    
    // MARK: - Initializer
    
    public init(text t: String, weight w: Int) {
        
        text = t
        weight = w
    }
    
    // MARK: - Functions
    
    public mutating func updateWeightUsage() {
        
        weight += 1
    }
}

extension ACTFDomain {
    
    /// Store domain with a specific key
    public func store(withKey key: String) -> Bool {
        
        // store
        let encoded = try? PropertyListEncoder().encode(self)
        guard let data = encoded else { return false }
        let archived = NSKeyedArchiver.archivedData(withRootObject: data)
        UserDefaults.standard.set(archived, forKey: key)
        
        return true
    }
    
    // MARK: - Type-level Functions
    
    /// Retrieve domain with a specific key
    public static func domain(forKey key: String) -> ACTFDomain? {
        
        // retrieved
        guard let data = UserDefaults.standard.object(forKey: key) as? Data,
            let decoded = NSKeyedUnarchiver.unarchiveObject(with: data) as? Data else { return nil } // retrieve failed
        
        let domain = try? PropertyListDecoder().decode(ACTFDomain.self, from: decoded)
        return domain
    }
    
    /// Store domains for a specific key
    public static func store(domains: [ACTFDomain], withKey key: String) -> Bool {
        
        // store
        let encoded = try? PropertyListEncoder().encode(domains)
        guard let data = encoded else { return false }
        let archived = NSKeyedArchiver.archivedData(withRootObject: data)
        UserDefaults.standard.set(archived, forKey: key)
        
        return true
    }
    
    /// Retrieve domains for a specific key
    public static func domains(forKey key: String) -> [ACTFDomain]? {

        // retrieved
        guard let data = UserDefaults.standard.object(forKey: key) as? Data,
            let decoded = NSKeyedUnarchiver.unarchiveObject(with: data) as? Data else { return nil } // retrieve failed
        
        let domains = try? PropertyListDecoder().decode([ACTFDomain].self, from: decoded)
        return domains
    }
}
