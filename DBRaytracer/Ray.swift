//
//  Ray.swift
//  DBRaytracer
//
//  Created by Daniel Beard on 12/30/16.
//  Copyright © 2016 dbeard. All rights reserved.
//

import Foundation

final class Ray {

    let origin: Vector3
    let direction: Vector3


    init(origin: Vector3, direction: Vector3) {
        self.origin = origin
        self.direction = direction
    }

    func pointAtParameter(t: Scalar) -> Vector3 {
        return origin + direction * t
    }
}
