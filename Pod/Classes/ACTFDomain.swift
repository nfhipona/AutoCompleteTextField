//
//  ACTFWeightedDomain.swift
//  Pods
//
//  Created by Neil Francis Hipona on 9/15/17.
//  Copyright © 2017 AJ Bartocci. All rights reserved.
//

import Foundation

public class ACTFDomain: Codable {
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
    
    public func updateWeightUsage() {
        weight += 1
        
        if isAutoStoringEnabled {
            store()
        }
    }
}

extension ACTFDomain {
    
    /// Store domain with a specific key
    @discardableResult
    public func store() -> Bool {
        // store
        guard let encoded = try? PropertyListEncoder().encode(self),
              let archived = try? NSKeyedArchiver.archivedData(withRootObject: encoded, requiringSecureCoding: true)
        else { return false }
        
        UserDefaults.standard.set(archived, forKey: text)
        UserDefaults.standard.synchronize()
        return true
    }
    
    // MARK: - Type-level Functions
    
    /// Retrieve domain with a specific key
    @discardableResult
    public static func domain(for key: String) -> ACTFDomain? {
        // retrieved
        guard let data = UserDefaults.standard.object(forKey: key) as? Data,
              let decoded = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSData.self, from: data) as? Data,
              let domain = try? PropertyListDecoder().decode(ACTFDomain.self, from: decoded)
        else { return nil } // retrieve failed
        return domain
    }
    
    /// Retrieve domains with keys
    @discardableResult
    public static func domain(for keys: [String]) -> [ACTFDomain] {
        var collection: [ACTFDomain] = []
        for key in keys {
            if let domain = domain(for: key) {
                collection.append(domain)
            }
        }
        return collection
    }
    
    /// Store domains for a specific key
    @discardableResult
    public static func store(domains: [ACTFDomain]) -> [String] {
        var errors: [String] = []
        for domain in domains {
            if !domain.store() {
                errors.append("Domain '\(domain.text)' store failed")
            }
        }
        
        return errors
    }
}
