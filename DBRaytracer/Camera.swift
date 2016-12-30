//
//  Camera.swift
//  DBRaytracer
//
//  Created by Daniel Beard on 12/30/16.
//  Copyright © 2016 dbeard. All rights reserved.
//

import Foundation

class Camera {

    fileprivate let origin: Vector3
    fileprivate let lowerLeftCorner: Vector3
    fileprivate let horizontal: Vector3
    fileprivate let vertical: Vector3

    init() {
        lowerLeftCorner = Vector3(-2.0, -1.0, -1.0)
        horizontal = Vector3(4.0, 0.0, 0.0)
        vertical = Vector3(0.0, 2.0, 0.0)
        origin = Vector3(0.0, 0.0, 0.0)
    }

    func getRay(u: Scalar, v: Scalar) -> Ray {
        return Ray(origin: origin, direction: lowerLeftCorner + u*horizontal + v*vertical - origin)
    }
}
