//
//  main.swift
//  DBRaytracer
//
//  Created by Daniel Beard on 12/29/16.
//  Copyright © 2016 dbeard. All rights reserved.
//

import Foundation

// Camera center will be at (0,0,0)
// Y-axis goes up
// X-axis goes to the right
// Z-axis is negative into the screen (right handed coordinate system)


let FLOAT_MAX = Float.greatestFiniteMagnitude

func frand48() -> Scalar {
    return Scalar(drand48())
}

// Picks a random point in a unit radius sphere, centered at the origin.
// This is a rejection method, we pick a random point in the unit cube where
// x,y,z all range from -1 to 1
// Reject if the point is outside the sphere and try again
func randomInUnitSphere() -> Vector3 {
    var p: Vector3
    repeat {
        p = 2.0*Vector3(frand48(), frand48(), frand48()) - Vector3(1,1,1)
    } while p.lengthSquared >= 1
    return p
}

func reflect(v: Vector3, n: Vector3) -> Vector3 {
    return v - 2*v.dot(n) * n
}

func refract(v: Vector3, n: Vector3, ni_over_nt: Scalar, refracted: inout Vector3) -> Bool {
    let uv = v.unitVector()
    let dt = uv.dot(n)
    let discriminant = 1.0 - ni_over_nt * ni_over_nt * (1 - dt*dt)
    if discriminant > 0 {
        refracted = ni_over_nt * (uv - n * dt) - n * sqrt(discriminant)
        return true
    }
    return false
}

func schlick(cosine: Scalar, reflectiveIndex: Scalar) -> Scalar {
    var r0 = (1-reflectiveIndex) / (1+reflectiveIndex)
    r0 = r0*r0
    return r0 + (1-r0) * pow((1-cosine), 5)
}

func colorFromRay(ray: Ray, world: Hitable, depth: Int) -> Vector3 {

    var hitRecord = HitRecord()
    if world.hit(ray: ray, t_min: 0.001, t_max: FLOAT_MAX, hit_record: &hitRecord) {

        var scattered = Ray()
        var attenuation = Vector3.zero

        if depth < 50 && hitRecord.material?.scatter(ray: ray, hitRecord: hitRecord, attenuation: &attenuation, scattered: &scattered) ?? false {
            return attenuation * colorFromRay(ray: scattered, world: world, depth: depth+1)
        } else {
            return Vector3.zero
        }
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

    let R = Scalar(cos(Scalar(M_PI)/4))
    let world = HitableList(array: [
        Sphere(center: Vector3(0,0,-1),
               radius: 0.5,
               material: Lambertian(albedo: Vector3(0.1, 0.2, 0.5))),
        Sphere(center: Vector3(0,-100.5,-1),
               radius: 100,
               material: Lambertian(albedo: Vector3(0.8, 0.8, 0.0))),
        Sphere(center: Vector3(1,0,-1),
               radius: 0.5, material:
            Metal(albedo: Vector3(0.8, 0.6, 0.2), fuzz: 0.3)),
        Sphere(center: Vector3(-1,0,-1),
               radius: -0.45,
               material: Dialetric(reflectiveIndex: 1.5))
//        Sphere(center: Vector3(-R,0,-1), radius: R, material: Lambertian(albedo: Vector3(0,0,1))),
//        Sphere(center: Vector3(R,0,-1), radius: R, material: Lambertian(albedo: Vector3(1,0,0))),
    ])

    let camera = Camera(lookFrom: Vector3(-2,2,1),
                        lookAt: Vector3(0,0,-1),
                        viewUp: Vector3(0,1,0),
                        verticalFOV: 90,
                        aspect: Scalar(Scalar(width) / Scalar(height)))
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
                color = color + colorFromRay(ray: ray, world: world, depth: 0)
            }

            color = color / Scalar(samples)

            // gamma2, we want to raise the gamma by 1/2 to lighten up the image.
            color = Vector3(sqrt(color.r()), sqrt(color.g()), sqrt(color.b()))
            let colorArray = color.toArray()

            let ir = Int(255.99*colorArray[0])
            let ig = Int(255.99*colorArray[1])
            let ib = Int(255.99*colorArray[2])

            output += "\(ir) \(ig) \(ib)\n"
        }
    }

    return output
}

let startDate = Date()
let image = ppmImage()
try! image.write(toFile: "/Users/dbeard/output.ppm", atomically: true, encoding: .ascii)
let endDate = Date()
let timeInterval = endDate.timeIntervalSince(startDate)
print("Finished! Took \(timeInterval) seconds")

