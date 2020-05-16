//
//  MetalFibonacci.swift
//  Closed-form Fibonacci on GPU
//
//  Created by Matthew Dooley on 5/15/20.
//  Copyright © 2020 Matthew Dooley. All rights reserved.
//

import Foundation
import Metal

class MetalFibonacci
{
    let start: UInt32
    let end: Int
    
    let length: Int
    let intBufferSize: Int = MemoryLayout<UInt32>.stride
    let resultBufferSize: Int
    
    let device: MTLDevice
    let fibonacciFunctionPSO: MTLComputePipelineState
    let commandQueue: MTLCommandQueue
    
    var startBuffer: MTLBuffer?
    var resultBuffer: MTLBuffer?
    
    init?(device: MTLDevice, start: Int, end: Int)
    {
        self.device = device
        self.start = UInt32(start)
        self.end = end
        self.length = end - start + 1 // convert from 0 based counting
        self.resultBufferSize = length * MemoryLayout<UInt32>.stride
        
        let defaultLibrary = self.device.makeDefaultLibrary()
        if (defaultLibrary == nil) {
            NSLog("Could not find library.")
            return nil
        }
        
        let fibonacciFunction = defaultLibrary!.makeFunction(name: "fibonacci")
        if (fibonacciFunction == nil) {
            NSLog("Could not find function.")
            return nil
        }
        
        do {
            try self.fibonacciFunctionPSO = self.device.makeComputePipelineState(function: fibonacciFunction!)
        } catch {
            NSLog("Could not create pipeline")
            return nil
        }
        
        self.commandQueue = self.device.makeCommandQueue()!
    }
    
    func prepareData()
    {
        self.startBuffer =
            self.device.makeBuffer(length: self.intBufferSize,
                                   options: MTLResourceOptions.storageModeShared)!
        
        self.resultBuffer =
            self.device.makeBuffer(length: self.resultBufferSize,
                                   options: MTLResourceOptions.storageModeShared)!
        let start: UnsafeMutablePointer<UInt32> =
            self.startBuffer!.contents().assumingMemoryBound(to: UInt32.self)
        
        start.pointee = self.start
    }
    
    func encodeFibonacciCommand(_ computeEncoder: MTLComputeCommandEncoder)
    {
        // Set the work
        computeEncoder.setComputePipelineState(self.fibonacciFunctionPSO)
        computeEncoder.setBuffer(self.startBuffer, offset: 0, index: 0)
        computeEncoder.setBuffer(self.resultBuffer, offset: 0, index: 1)
        
        let gridSize: MTLSize = MTLSizeMake(self.length, 1, 1)
        
        // Calculate a threadgroup size.
        var threadGroupSizeInt: Int = self.fibonacciFunctionPSO.maxTotalThreadsPerThreadgroup
        if (threadGroupSizeInt > self.length)
        {
            threadGroupSizeInt = self.length
        }
        let threadGroupSize: MTLSize = MTLSizeMake(threadGroupSizeInt, 1, 1)
                
        // Encode the compute command.
        computeEncoder.dispatchThreads(gridSize, threadsPerThreadgroup: threadGroupSize)
    }
    
    func sendComputeCommand()
    {
        let commandBuffer: MTLCommandBuffer = self.commandQueue.makeCommandBuffer()!
        let computeEncoder: MTLComputeCommandEncoder = commandBuffer.makeComputeCommandEncoder()!

        self.encodeFibonacciCommand(computeEncoder)
        
        computeEncoder.endEncoding()
        commandBuffer.commit()
        
        commandBuffer.waitUntilCompleted()
    }
    
    func printResults()
    {
        let result: UnsafeMutablePointer<UInt32> = self.resultBuffer!.contents().assumingMemoryBound(to: UInt32.self)
        
        for index in 0 ..< self.length
        {
            print("\(self.start + UInt32(index)): \(result[index])")
        }
    }
}
