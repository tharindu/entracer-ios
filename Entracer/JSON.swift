//
//  JSON.swift
//  Entracer
//
//  Created by Tharindu Madushanka on 10/16/18.
//  Copyright © 2018 Entracer. All rights reserved.
//

import Foundation

/// JSON type definitions.
public enum JSONType: Int {
    /// Number type json.
    case number
    /// String type json.
    case string
    /// Boolean type json.
    case bool
    /// Array type json.
    case array
    /// Dictionary type json.
    case dictionary
    /// Null type json.
    case null
    /// Unknown json type.
    case unknown
}

/// Main struct for JSON handling.
public struct JSON {
    
    /// JSON type, fileprivate setter.
    public fileprivate(set) var type: JSONType = .null
    
    /// Private raw objects.
    fileprivate var rawArray: [Any] = []
    fileprivate var rawDictionary: [String: Any] = [:]
    fileprivate var rawString: String = ""
    fileprivate var rawNumber: NSNumber = 0
    fileprivate var rawNull: NSNull = NSNull()
    fileprivate var rawBool: Bool = false
    
    /**
     Returns a json data object to be communicated with a server as JSON data.
     
     - parameter: dictionary object.
     - returns: JSON data to be communicated with a server.
    */
    static func data(with dictionary: [String: AnyObject]) throws -> Data {
        
        let data = try JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted)
        return data
    }
    
    /**
     Initializes a JSON object using data.
     
     - parameter data: Data used to convert to JSON, Top level object in data is an array or dictionary.
     - throws: json serialization error.
     
     - returns: JSON object.
     */
    public init(with data: Data) throws {
        
        let objct = try JSONSerialization.jsonObject(with: data, options: [])
        self.init(jsonObject: objct)
    }
    
    /**
     Initializes a JSON using the object.
     
     - parameter jsonObject: Object used to create JSON.
     
     - returns: JSON object.
    */
    fileprivate init(jsonObject: Any) {
        self.object = jsonObject
    }

    /// Object in JSON.
    public var object: Any {
        get {
            switch self.type {
            case .array:
                return self.rawArray
            case .dictionary:
                return self.rawDictionary
            case .string:
                return self.rawString
            case .number:
                return self.rawNumber
            case .bool:
                return self.rawBool
            default:
                return self.rawNull
            }
        }
        set {
            switch unwrap(newValue) {
            case let number as NSNumber:
                if number.isBool {
                    type = .bool
                    self.rawBool = number.boolValue
                } else {
                    type = .number
                    self.rawNumber = number
                }
            case let string as String:
                type = .string
                self.rawString = string
            case _ as NSNull:
                type = .null
            case nil:
                type = .null
            case let array as [Any]:
                type = .array
                self.rawArray = array
            case let dictionary as [String: Any]:
                type = .dictionary
                self.rawDictionary = dictionary
            default:
                type = .unknown
            }
        }
    }
    
    /// Private method to unwarp an object recursively.
    private func unwrap(_ object: Any) -> Any {
        switch object {
        case let array as [Any]:
            return array.map(unwrap)
        case let dictionary as [String: Any]:
            var unwrappedDic = dictionary
            for (k, v) in dictionary {
                unwrappedDic[k] = unwrap(v)
            }
            return unwrappedDic
        default:
            return object
        }
    }
    
}

/// Extension for dictionary and array object handling.
extension JSON {
    
    /// Array object of `JSON`.
    public var array: [Any]? {
        switch self.type {
        case .array:
            return rawArray
        default:
            return nil
        }
    }
    
    /// Dictionary object of `JSON`.
    public var dictionary: [String: Any]? {
        switch self.type {
        case .dictionary:
            return rawDictionary
        default:
            return nil
        }
    }
}

/// Extension for checking boolean type of a `NSNumber` object.
extension NSNumber {
    
    /// Returns true if number is of type `Bool`.
    fileprivate var isBool: Bool
    {
        let boolID = CFBooleanGetTypeID() // the type ID of CFBoolean
        let numID = CFGetTypeID(self) // the type ID of number
        return numID == boolID
    }
}
