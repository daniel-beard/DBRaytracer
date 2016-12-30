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


let FLOAT_MAX = Float.greatestFiniteMagnitude

func frand48() -> Scalar {
    return Scalar(drand48())
}

func colorFromRay(ray: Ray, world: Hitable) -> Vector3 {

    var hitRecord = HitRecord()
    if world.hit(ray: ray, t_min: 0.0, t_max: FLOAT_MAX, hit_record: &hitRecord) {
        return 0.5*Vector3(hitRecord.normal.x + 1, hitRecord.normal.y + 1, hitRecord.normal.z + 1)
    } else {
        // Background color
        let unitDirection = ray.direction.unitVector()
        let t = 0.5 * (unitDirection.y + 1.0)
        return (1.0 - t) * Vector3(1, 1, 1) + t * Vector3(0.5, 0.7, 1.0)
    }
}

func ppmImage() -> String {

    //TODO: Only for testing
    let width = 200
    let height = 100
    let samples = 100

    // Seed random numbers, so we can produce the same image.
    srand48(0)

    let maxColorValue = "255"
    var output = "P3\n\(width) \(height)\n\(maxColorValue)\n"

    let world = HitableList(array: [
        Sphere(center: Vector3(0,0,-1), radius: 0.5),
        Sphere(center: Vector3(0,-100.5,-1), radius: 100)
    ])

    let camera = Camera()

    for j in (0..<height).reversed() {
        for i in 0..<width {

            let si = Scalar(i)
            let sj = Scalar(j)

            var color = Vector3(0,0,0)
            for _ in 0..<samples {
                let u = (si + frand48()) / Scalar(width)
                let v = (sj + frand48()) / Scalar(height)
                let ray = camera.getRay(u: u, v: v)
                //let p = ray.pointAtParameter(t: 2.0)
                color = color + colorFromRay(ray: ray, world: world)
            }

            color = color / Scalar(samples)
            let colorArray = color.toArray()

            let ir = Int(255.99*colorArray[0])
            let ig = Int(255.99*colorArray[1])
            let ib = Int(255.99*colorArray[2])

            output += "\(ir) \(ig) \(ib)\n"
        }
    }

    return output
}

let image = ppmImage()
try! image.write(toFile: "/Users/dbeard/output.ppm", atomically: true, encoding: .ascii)


//#warning At the start of Chapter 3...
