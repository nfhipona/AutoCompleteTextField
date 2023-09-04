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
    /// Will auto store on `weight` update using `text` default to `true`
    public let isAutoStoringEnabled: Bool
    
    // MARK: - Initializer
    
    public init(text t: String, weight w: Int, isAutoStoringEnabled autoStoringEnabled: Bool = true) {
        text = t
        weight = w
        isAutoStoringEnabled = autoStoringEnabled
    }
    
    // MARK: - Functions
    
    public mutating func updateWeightUsage() {
        weight += 1
        
        store(withKey: text)
    }
}

extension ACTFDomain {
    
    /// Store domain with a specific key
    @discardableResult
    public func store(withKey key: String? = nil) -> Bool {
        // store
        let storeKey = key ?? text
        guard let encoded = try? PropertyListEncoder().encode(self),
              let archived = try? NSKeyedArchiver.archivedData(withRootObject: encoded, requiringSecureCoding: true)
        else { return false }
        
        UserDefaults.standard.set(archived, forKey: storeKey)
        return true
    }
    
    // MARK: - Type-level Functions
    
    /// Retrieve domain with a specific key
    @discardableResult
    public static func domain(forKey key: String) -> ACTFDomain? {
        // retrieved
        guard let data = UserDefaults.standard.object(forKey: key) as? Data,
              let decoded = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSData.self, from: data) as? Data,
              let domain = try? PropertyListDecoder().decode(ACTFDomain.self, from: decoded)
        else { return nil } // retrieve failed
        
        return domain
    }
    
    /// Store domains for a specific key
    @discardableResult
    public static func store(domains: [ACTFDomain], withKey key: String) -> Bool {
        // store
        guard let encoded = try? PropertyListEncoder().encode(domains),
              let archived = try? NSKeyedArchiver.archivedData(withRootObject: encoded, requiringSecureCoding: true)
        else { return false }
        
        UserDefaults.standard.set(archived, forKey: key)
        
        return true
    }
    
    /// Retrieve domains for a specific key
    @discardableResult
    public static func domains(forKey key: String) -> [ACTFDomain]? {
        // retrieved
        guard let data = UserDefaults.standard.object(forKey: key) as? Data,
              let decoded = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSData.self, from: data) as? Data,
              let domains = try? PropertyListDecoder().decode([ACTFDomain].self, from: decoded)
        else { return nil } // retrieve failed
        
        return domains
    }
}
