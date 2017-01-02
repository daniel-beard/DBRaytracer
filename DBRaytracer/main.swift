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

let width = 400
let height = 200
let samples = 100

let FLOAT_MAX = Float.greatestFiniteMagnitude

// Seed random numbers, so we can produce the same image.
srand48(0)

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

func randomScene() -> HitableList {
    var list = [Hitable]()
    list.append(Sphere(center: Vector3(0, -1000, 0), radius: 1000, material: Lambertian(albedo: Vector3(0.5, 0.5, 0.5))))

    for a in stride(from: -11, to: 10, by: 1) {
        for b in stride(from: -11, to: 10, by: 1) {
            let chooseMat = frand48()
            let center = Vector3(Scalar(a)+0.9*frand48(), 0.2, Scalar(b)+0.9*frand48())
            if (center - Vector3(4,0.2,0)).length > 0.9 {
                // diffuse
                if chooseMat < 0.8 {
                    list.append(
                        Sphere(center: center,
                               radius: 0.2,
                               material: Lambertian(albedo: Vector3(frand48()*frand48(), frand48()*frand48(), frand48()*frand48())))
                    )
                // metal
                } else if chooseMat < 0.95 {
                    list.append(
                        Sphere(center: center,
                               radius: 0.2,
                               material: Metal(albedo: Vector3(0.5*(1+frand48()), 0.5*(1+frand48()), 0.5*(1+frand48())), fuzz: 0.5*frand48()))
                    )
                // glass
                } else {
                    list.append(
                        Sphere(center: center,
                               radius: 0.2,
                               material: Dialetric(reflectiveIndex: 1.5))
                    )
                }
            }
        }
    }
    list.append(
        Sphere(center: Vector3(0,1,0),
               radius: 1.0,
               material: Dialetric(reflectiveIndex: 1.5))
    )
    list.append(
        Sphere(center: Vector3(-4,1,0),
               radius: 1.0,
               material: Lambertian(albedo: Vector3(0.4,0.2,0.1)))
        )
    list.append(
        Sphere(center: Vector3(4,1,0),
               radius: 1.0,
               material:
            Metal(albedo: Vector3(0.7,0.6,0.5), fuzz: 0.0))
    )
    return HitableList(array: list)

}

func renderRow(row: Int, world: Hitable, camera: Camera, pixels: PixelArray) {
    let j = row
    for i in 0..<width {

        let si = Scalar(i)
        let sj = Scalar(j)

        var color = Vector3(0,0,0)
        for _ in 0..<samples {
            let u = (si + frand48()) / Scalar(width)
            let v = (sj + frand48()) / Scalar(height)
            let ray = camera.getRay(s: u, t: v)
            //let p = ray.pointAtParameter(t: 2.0)
            color = color + colorFromRay(ray: ray, world: world, depth: 0)
        }

        color = color / Scalar(samples)

        // gamma2, we want to raise the gamma by 1/2 to lighten up the image.
        color = Vector3(sqrt(color.r()), sqrt(color.g()), sqrt(color.b()))
        pixels[i, j] = color
    }
}

func render() -> String {

    // We treat this as an "embarrasingly" parallel problem, and render each image row separately
    // Don't have to protect against concurrent writes, as we only write to each pixel from a single
    // queue. Each queue handles multiple samples per pixel.
    let operationQueue = OperationQueue()
    operationQueue.maxConcurrentOperationCount = 16
    operationQueue.isSuspended = true
    let world = randomScene()
    let pixelArray = PixelArray(width: width, height: height)

    let lookFrom = Vector3(13,2,3)
    let lookAt = Vector3(0,0,0)
    let distToFocus = Scalar(10)
    let aperture = Scalar(0.1)
    let camera = Camera(lookFrom: lookFrom,
                        lookAt: lookAt,
                        viewUp: Vector3(0,1,0),
                        verticalFOV: 20,
                        aspect: Scalar(Scalar(width) / Scalar(height)),
                        aperture: aperture,
                        focusDistance: distToFocus)
    for j in (0..<height).reversed() {
        operationQueue.addOperation {
            print("Rendering row: \(j)")
            renderRow(row: j, world: world, camera: camera, pixels: pixelArray)
        }
    }
    operationQueue.isSuspended = false
    operationQueue.waitUntilAllOperationsAreFinished()
    return pixelArray.ppmImage()
}

let startDate = Date()
let image = render()
try! image.write(toFile: "/Users/dbeard/output.ppm", atomically: true, encoding: .ascii)
let endDate = Date()
let timeInterval = endDate.timeIntervalSince(startDate)
print("Finished! Took \(timeInterval) seconds")

