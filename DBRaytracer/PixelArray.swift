//
//  PixelArray.swift
//  DBRaytracer
//
//  Created by Daniel Beard on 12/29/16.
//  Copyright © 2016 dbeard. All rights reserved.
//

import Foundation

struct Color {
    let red: Double
    let green: Double
    let blue: Double
    init(_ red: Double, _ green: Double, _ blue: Double) {
        self.red = red
        self.blue = blue
        self.green = green
        if (red < 0 || red > 1 || green < 0 || green > 1 || blue < 0 || blue > 1) {
            fatalError("Color values must be within 0..<1")
        }
    }
}

class PixelArray {

    fileprivate var matrix: [[Color]]
    let width: Int
    let height: Int

    init(width: Int, height: Int) {
        self.width = width
        self.height = height
        matrix = [[Color]](repeating:[Color](repeating:Color(0, 0, 0), count:width), count:height)
    }

    subscript(row: Int, col: Int) -> Color? {
        get {
            return matrix[col][row]
        }
        set {
            matrix[col][row] = newValue!
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
    func ppmImage() -> String {

        //TODO: Only for testing
        let width = 200
        let height = 100

        let maxColorValue = "255"
        var output = "P3\n\(width) \(height)\n\(maxColorValue)\n"
        for j in (0..<height).reversed() {
            for i in 0..<width {
                let r: Double = Double(i) / Double(width)
                let g: Double = Double(j) / Double(height)
                let b: Double = 0.2

                let ir = Int(255.99*r)
                let ig = Int(255.99*g)
                let ib = Int(255.9*b)
                output += "\(ir) \(ig) \(ib)\n"
            }
        }

        return output
    }
}


