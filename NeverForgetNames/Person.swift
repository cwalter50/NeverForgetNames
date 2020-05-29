//
//  Person.swift
//  NeverForgetNames
//
//  Created by Christopher Walter on 5/26/20.
//  Copyright © 2020 Christopher Walter. All rights reserved.
//

import Foundation
import SwiftUI
import CoreLocation

class Person: Identifiable, ObservableObject, Codable, Comparable {

    
    var name: String = "Doc"
    var id = UUID()
    var uiImage: UIImage?
    var details: String = "A new friend"
    var location: CLLocationCoordinate2D = CLLocationCoordinate2D()
    
    
    
    init ()
    {
        self.uiImage = UIImage(named: "default")
    }
    
    init(uiImage: UIImage?)
    {
        self.uiImage = uiImage
    }
    init(uiImage: UIImage?, location: CLLocationCoordinate2D)
    {
        self.uiImage = uiImage
        self.location = location
        
    }
    
    
    var wrappedUIImage: UIImage {
        get {
            uiImage ?? UIImage(named: "default")!
        }
        
        set {
            uiImage = newValue
        }
    }
    
    // make this enum to help with encoding and decoding
    enum CodingKeys: CodingKey {
        case name, id, uiImage, details, latitude, longitude
    }
    
    public required init(from decoder: Decoder) throws {

        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        details = try container.decode(String.self, forKey: .details)
        id = try container.decode(UUID.self, forKey: .id)
        
        // grab lat and longitude, then create the location
        let latitude = try container.decode(CLLocationDegrees.self, forKey: .latitude)
        let longitude = try container.decode(CLLocationDegrees.self, forKey: .longitude)
        location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)

        // UIImage does not conform to codable, so we have to covert to Data before we then get the image
        let uiImageData = try container.decode(Data.self, forKey: .uiImage)
        uiImage = UIImage(data: uiImageData)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(details, forKey: .details)
        try container.encode(id, forKey: .id)
        try container.encode(location.latitude, forKey: .latitude)
        try container.encode(location.longitude, forKey: .longitude)
                // UIImage does not conform to codable, so we have to covert to Data first
        if let imageData = uiImage?.jpegData(compressionQuality: 0.8) {
            try container.encode(imageData, forKey: .uiImage)
        }
    }
    
    // For Comparable. Now we can easily sort!
    static func < (lhs: Person, rhs: Person) -> Bool {
        return lhs.name < rhs.name
    }
    
    static func == (lhs: Person, rhs: Person) -> Bool {
        return lhs.name == rhs.name
    }
}
