//
//  HitableList.swift
//  DBRaytracer
//
//  Created by Daniel Beard on 12/30/16.
//  Copyright © 2016 dbeard. All rights reserved.
//

import Foundation

final class HitableList: Hitable {
    fileprivate let list: [Hitable]

    init(array: [Hitable]) {
        list = array
    }

    override func hit(ray: Ray, t_min: Scalar, t_max: Scalar, hit_record: inout HitRecord) -> Bool {
        var hitAnything = false
        var closestSoFar: Scalar = t_max
        var tempHitRecord = HitRecord()
        for element in list {
            if element.hit(ray: ray, t_min: t_min, t_max: closestSoFar, hit_record: &tempHitRecord) {
                hitAnything = true
                closestSoFar = tempHitRecord.t
                hit_record = tempHitRecord
            }
        }
        return hitAnything
    }
}
