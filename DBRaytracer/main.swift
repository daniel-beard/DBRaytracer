//
//  main.swift
//  DBRaytracer
//
//  Created by Daniel Beard on 12/29/16.
//  Copyright © 2016 dbeard. All rights reserved.
//

import Foundation

print("Hello, World!")

var pixels = PixelArray(width: 2, height: 2)
pixels[1, 0] = Color(0.5, 0.5, 0.5)
print(pixels)

let ppmImage = pixels.ppmImage()
try! ppmImage.write(toFile: "/Users/dbeard/output.ppm", atomically: true, encoding: .ascii)
