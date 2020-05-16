//
//  main.swift
//  Closed-form Fibonacci on GPU
//
//  Created by Matthew Dooley on 5/14/20.
//  Copyright © 2020 Matthew Dooley. All rights reserved.
//
//  CPU accurate (0, 70] then datatypes start to become annoying
//  GPU accurate (0, 32] then datatypes start to become annoying
//

import Foundation
import ArgumentParser
import Metal
import Darwin

// get command line arguments
struct FibonacciOptions: ParsableArguments {
    @Flag(help: "Should we use the CPU instead?")
    var cpu: Bool

    @Option(name: .shortAndLong, help: "The start position for getting a range.")
    var start: Int?

    @Argument(help: "The position to get (or end at).")
    var index: Int
}

// force correct datatypes and any computed values
struct Config {
    static let options     = FibonacciOptions.parseOrExit()
    static let cpu:   Bool = options.cpu
    static let range: Bool = (options.start != nil)
    static let start: Int? = options.start
    static let end:   Int  = options.index
    static let index: Int  = options.index
}

if (Config.index < 0) {
    print("Error: '<index>' must be >= 0. \(Config.index) < 0")
    Darwin.exit(1)
} else if (Config.range && Config.start! < 0) {
    print("Error: '<start>' must be >= 0. \(Config.start!) < 0")
    Darwin.exit(1)
} else if (Config.range && Config.start! >= Config.index) {
    print("Error: '<start>' must be < '<index>'. \(Config.start!) >= \(Config.index)")
    Darwin.exit(1)
}

extension Double {
    func toString(decimalPrecision decimal: Int = 9) -> String {
        let value = decimal < 0 ? 0 : decimal
        var string = String(format: "%.\(value)f", self)

        while string.last == "." {
            if string.last == "." { string = String(string.dropLast()); break}
            string = String(string.dropLast())
        }
        return string
    }
}

func fibonacciRange(_ start: Int, to end: Int) -> [Double]
{
    var output: [Double] = []
    
    for i in start...end
    {
        output.append(fibonacciCPU(i))
    }
    
    return output
}

func fibonacciCPU(_ n: Int) -> Double
{
    let n = Double(n)
    let n1 = n - 1
    let n2 = n1 - 1
    
    let resultn1 = binetsFormula(n1)
    let resultn2 = binetsFormula(n2)

    let result = resultn1 + resultn2
    return result
}

func binetsFormula(_ nth: Double) -> Double
{
    let goldenRatio = ((1 + Double(5).squareRoot()) / 2)
    let psi = (1 - goldenRatio)

    return Double(
        (pow(goldenRatio, nth) - pow(psi, nth))
            / (Double(5).squareRoot()))
}

if Config.cpu {
    // accurate up to and including 70
    print("Calculating with CPU")
    
    if !Config.range {
        print("\(Config.index): \(fibonacciCPU(Config.index).toString(decimalPrecision: 0))")
    } else {
        var current: Int = Config.start!
        for i in fibonacciRange(Config.start!, to: Config.index)
        {
            print("\(current): \(i.toString(decimalPrecision: 0))")
            current += 1
        }
    }
} else  {
    // accurate up to and including 32
    print("Calculating with GPU")
    
    let device: MTLDevice = MTLCreateSystemDefaultDevice()!
    let fibonacci: MetalFibonacci = MetalFibonacci(device: device,
                                                   start: Config.start ?? Config.end,
                                                   end: Config.end)!
    
    fibonacci.prepareData()
    fibonacci.sendComputeCommand()
    fibonacci.printResults()
}
