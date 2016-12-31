//
//  Material.swift
//  DBRaytracer
//
//  Created by Daniel Beard on 12/31/16.
//  Copyright © 2016 dbeard. All rights reserved.
//

import Foundation

protocol Material {
    func scatter(ray: Ray, hitRecord: HitRecord, attenuation: inout Vector3, scattered: inout Ray) -> Bool
}
