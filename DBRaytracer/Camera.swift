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

    /// verticalFOV is the top to bottom in degrees
    init(lookFrom: Vector3, lookAt: Vector3, viewUp: Vector3, verticalFOV: Scalar, aspect: Scalar) {
        let u: Vector3
        let v: Vector3
        let w: Vector3
        let theta = verticalFOV * Scalar(M_PI) / 180
        let half_height = tan(theta/2)
        let half_width = aspect * half_height

        origin = lookFrom
        w = (lookFrom - lookAt).unitVector()
        u = viewUp.cross(w).unitVector()
        v = w.cross(u)

        lowerLeftCorner = origin - half_width*u - half_height*v - w
        horizontal = 2*half_width*u
        vertical = 2*half_height*v
    }

    func getRay(u: Scalar, v: Scalar) -> Ray {
        return Ray(origin: origin, direction: lowerLeftCorner + u*horizontal + v*vertical - origin)
    }
}
