//
//  main.swift
//  DBRaytracer
//
//  Created by Daniel Beard on 12/29/16.
//  Copyright © 2016 dbeard. All rights reserved.
//

import Foundation


var pixels = PixelArray(width: 2, height: 2)
pixels[1, 0] = Vector3(0.5, 0.5, 0.5)
print(pixels)




// Camera center will be at (0,0,0)
// Y-axis goes up
// X-axis goes to the right
// Z-axis is negative into the screen (right handed coordinate system)

// Returns true when a ray hits a sphere for any value of t
// Discriminant is 0 for no hits, 1 for a hit on the very edge
// Discriminant is 2 for most hits (hits on entry and exit of the sphere).
func hitSphere(center: Vector3, radius: Scalar, ray: Ray) -> Scalar {
    let oc = ray.origin - center
    let a = ray.direction.dot(ray.direction)
    let b = 2.0 * oc.dot(ray.direction)
    let c = oc.dot(oc) - radius * radius
    let discriminant = b * b - 4 * a * c
    if discriminant < 0 {
        return -1.0
    } else {
        return (-b - sqrt(discriminant)) / (2.0*a)
    }
}

func colorFromRay(ray: Ray) -> Vector3 {

    // Hard coded sphere test, shows sphere normals.
    var t = hitSphere(center: Vector3(0,0,-1), radius: 0.5, ray: ray)
    if t > 0.0 {
        let N = ray.pointAtParameter(t: t).unitVector() - Vector3(0,0,-1)
        return 0.5 * Vector3(N.x + 1, N.y + 1, N.z + 1)
    }

    let unitDirection = ray.direction.unitVector()
    t = 0.5 * (unitDirection.y + 1.0)
    return (1.0 - t) * Vector3(1, 1, 1) + t * Vector3(0.5, 0.7, 1.0)
}

func ppmImage() -> String {

    //TODO: Only for testing
    let width = 200
    let height = 100

    let maxColorValue = "255"
    var output = "P3\n\(width) \(height)\n\(maxColorValue)\n"

    let lowerLeftCorner = Vector3(-2.0, -1.0, -1.0)
    let horizontal = Vector3(4.0, 0.0, 0.0)
    let vertical = Vector3(0.0, 2.0, 0.0)
    let origin = Vector3(0.0, 0.0, 0.0)

    for j in (0..<height).reversed() {
        for i in 0..<width {

            let u = Scalar(i) / Scalar(width)
            let v = Scalar(j) / Scalar(height)
            let ray = Ray(origin: origin, direction: lowerLeftCorner + u * horizontal + v * vertical)
            let color = colorFromRay(ray: ray).toArray()

            let ir = Int(255.99*color[0])
            let ig = Int(255.99*color[1])
            let ib = Int(255.99*color[2])

            output += "\(ir) \(ig) \(ib)\n"
        }
    }

    return output
}

let image = ppmImage()
try! image.write(toFile: "/Users/dbeard/output.ppm", atomically: true, encoding: .ascii)


//#warning At the start of Chapter 3...
