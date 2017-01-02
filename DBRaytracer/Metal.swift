//
//  Metal.swift
//  DBRaytracer
//
//  Created by Daniel Beard on 12/31/16.
//  Copyright © 2016 dbeard. All rights reserved.
//

import Foundation

final class Metal: Material {
    fileprivate let albedo: Vector3
    fileprivate let fuzz: Scalar

    init(albedo: Vector3, fuzz: Scalar) {
        self.albedo = albedo
        if fuzz < 1 {
            self.fuzz = fuzz
        } else {
            self.fuzz = 1
        }
    }

    override func scatter(ray: Ray, hitRecord: HitRecord, attenuation: inout Vector3, scattered: inout Ray) -> Bool {
        let reflected = reflect(v: ray.direction.unitVector(), n: hitRecord.normal)
        scattered = Ray(origin: hitRecord.p, direction: reflected + fuzz * randomInUnitSphere())
        attenuation = albedo
        return scattered.direction.dot(hitRecord.normal) > 0
    }
}

