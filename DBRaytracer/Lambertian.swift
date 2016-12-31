//
//  Lambertian.swift
//  DBRaytracer
//
//  Created by Daniel Beard on 12/31/16.
//  Copyright © 2016 dbeard. All rights reserved.
//

import Foundation

class Lambertian {
    fileprivate let albedo: Vector3

    init(albedo: Vector3) {
        self.albedo = albedo
    }
}

extension Lambertian: Material {
    func scatter(ray: Ray, hitRecord: HitRecord, attenuation: inout Vector3, scattered: inout Ray) -> Bool {
        let target = hitRecord.p + hitRecord.normal + randomInUnitSphere()
        scattered = Ray(origin: hitRecord.p, direction: target - hitRecord.p)
        attenuation = albedo
        return true
    }
}
