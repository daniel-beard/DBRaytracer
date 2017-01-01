//
//  Camera.swift
//  DBRaytracer
//
//  Created by Daniel Beard on 12/30/16.
//  Copyright © 2016 dbeard. All rights reserved.
//

import Foundation

func random_in_unit_disk() -> Vector3 {
    var p: Vector3
    repeat {
        p = 2.0 * Vector3(frand48(), frand48(), 0) - Vector3(1,1,0)
    } while p.dot(p) >= 1.0
    return p
}

class Camera {

    fileprivate let origin: Vector3
    fileprivate let lowerLeftCorner: Vector3
    fileprivate let horizontal: Vector3
    fileprivate let vertical: Vector3
    fileprivate let u: Vector3
    fileprivate let v: Vector3
    fileprivate let w: Vector3
    fileprivate let lensRadius: Scalar

    /// verticalFOV is the top to bottom in degrees
    init(lookFrom: Vector3,
         lookAt: Vector3,
         viewUp: Vector3,
         verticalFOV: Scalar,
         aspect: Scalar,
         aperture: Scalar,
         focusDistance: Scalar) {

        lensRadius = aperture / 2
        let theta = verticalFOV * Scalar(M_PI) / 180
        let half_height = tan(theta/2)
        let half_width = aspect * half_height

        origin = lookFrom
        w = (lookFrom - lookAt).unitVector()
        u = viewUp.cross(w).unitVector()
        v = w.cross(u)

        lowerLeftCorner = origin - half_width * focusDistance * u - half_height * focusDistance * v - focusDistance * w
        horizontal = 2*half_width*focusDistance*u
        vertical = 2*half_height*focusDistance*v
    }

    func getRay(s: Scalar, t: Scalar) -> Ray {
        let rd = lensRadius * random_in_unit_disk()
        let offset = u * rd.x * rd.y
        return Ray(origin: origin + offset, direction: lowerLeftCorner + s*horizontal + t*vertical - origin - offset)
    }
}
