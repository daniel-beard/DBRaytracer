//
//  Dialetric.swift
//  DBRaytracer
//
//  Created by Daniel Beard on 12/31/16.
//  Copyright © 2016 dbeard. All rights reserved.
//

import Foundation

class Dialetric {
    fileprivate let reflectiveIndex: Scalar

    init(reflectiveIndex: Scalar) {
        self.reflectiveIndex = reflectiveIndex
    }
}

extension Dialetric: Material {
    func scatter(ray: Ray, hitRecord: HitRecord, attenuation: inout Vector3, scattered: inout Ray) -> Bool {
        var outwardNormal: Vector3
        let reflected = reflect(v: ray.direction, n: hitRecord.normal)
        var ni_over_nt: Scalar
        attenuation = Vector3(1,1,1)
        var refracted = Vector3.zero
        let reflectProb: Scalar
        let cosine: Scalar
        if ray.direction.dot(hitRecord.normal) > 0 {
            outwardNormal = -hitRecord.normal
            ni_over_nt = reflectiveIndex
            cosine = reflectiveIndex * ray.direction.dot(hitRecord.normal) / ray.direction.length
        } else {
            outwardNormal = hitRecord.normal
            ni_over_nt = 1.0 / reflectiveIndex
            cosine = -ray.direction.dot(hitRecord.normal) / ray.direction.length
        }



        if refract(v: ray.direction, n: outwardNormal, ni_over_nt: ni_over_nt, refracted: &refracted) {

            reflectProb = schlick(cosine: cosine, reflectiveIndex: reflectiveIndex)
        } else {
            reflectProb = 1
        }

        if frand48() < reflectProb {
            scattered = Ray(origin: hitRecord.p, direction: reflected)
        } else {
            scattered = Ray(origin: hitRecord.p, direction: refracted)
        }
        return true
    }
}
