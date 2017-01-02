//
//  PixelArray.swift
//  DBRaytracer
//
//  Created by Daniel Beard on 12/29/16.
//  Copyright © 2016 dbeard. All rights reserved.
//

import Foundation

class PixelArray {

    fileprivate var matrix: [[Vector3]]
    let width: Int
    let height: Int

    init(width: Int, height: Int) {
        self.width = width
        self.height = height
        matrix = [[Vector3]](repeating:[Vector3](repeating:Vector3(0, 0, 0), count:width), count:height)
    }

    subscript(row: Int, col: Int) -> Vector3 {
        get {
            return matrix[col][row]
        }
        set {
            matrix[col][row] = newValue
        }
    }
}

// Debug description
extension PixelArray: CustomStringConvertible {
    var description: String {
        var output = ""
        for x in 0..<width {
            for y in 0..<height {
                output += "\(matrix[x][y]), "
            }
            output += "\n"
        }
        return output
    }
}

// Image output
extension PixelArray {

    func colorFromRay(ray: Ray) -> Vector3 {
        let unitDirection = ray.direction.unitVector()
        let t: Scalar = 0.5 * (unitDirection.y + 1.0)
        return (1.0 - t) * Vector3(1, 1, 1) + t * Vector3(0.5, 0.7, 1.0)
    }

    func ppmImage() -> String {

        let maxColorValue = "255"
        var output = "P3\n\(width) \(height)\n\(maxColorValue)\n"

        for j in (0..<height).reversed() {
            for i in 0..<width {

                let color = self[i, j].toArray()
                let ir = Int(255.99*color[0])
                let ig = Int(255.99*color[1])
                let ib = Int(255.99*color[2])
                output += "\(ir) \(ig) \(ib)\n"
            }
        }
        return output
    }
}


