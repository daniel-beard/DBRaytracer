//
//  Sphere.swift
//  DBRaytracer
//
//  Created by Daniel Beard on 12/30/16.
//  Copyright © 2016 dbeard. All rights reserved.
//

import Foundation

class Sphere {

    fileprivate let center: Vector3
    fileprivate let radius: Scalar

    init(center: Vector3, radius: Scalar) {
        self.center = center
        self.radius = radius
    }
}

extension Sphere: Hitable {
    func hit(ray: Ray, t_min: Scalar, t_max: Scalar, hit_record: inout HitRecord) -> Bool {
        let oc = ray.origin - center
        let a = ray.direction.dot(ray.direction)
        let b = oc.dot(ray.direction)
        let c = oc.dot(oc) - radius * radius
        let discriminant = b*b - a*c
        if discriminant > 0 {
            var temp = (-b - sqrt(b*b-a*c)) / a
            if temp < t_max && temp > t_min {
                hit_record.t = temp
                hit_record.p = ray.pointAtParameter(t: hit_record.t)
                hit_record.normal = (hit_record.p - center) / radius
                return true
            }
            temp = (-b + sqrt(b*b-a*c)) / a
            if temp < t_max && temp > t_min {
                hit_record.t = temp
                hit_record.p = ray.pointAtParameter(t: hit_record.t)
                hit_record.normal = (hit_record.p - center) / radius
                return true
            }
        }
        return false
    }
}
