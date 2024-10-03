//
//  Metal.swift
//  iosGPUCalculate
//
//  Created by Ian Brown on 10/1/24.
//

import Foundation
import Metal
// Useful if you're doing math on CPU
import simd

// command buffers will be function specific
class MetalManager: ObservableObject {
    
    // Setup Metal device
    let device: MTLDevice
    var commandQueue: MTLCommandQueue
    var library: MTLLibrary
    var pipelineComputeStates: [String: MTLComputePipelineState]
    init() {
        
        guard let device: MTLDevice = MTLCreateSystemDefaultDevice() else {
            fatalError("Error: No Metal Compatabile Device")
        }
        self.device = device
        
        guard let commandQueue: MTLCommandQueue = device.makeCommandQueue() else {
            fatalError("Error: Unable to create CMDQ")
        }
        self.commandQueue = commandQueue
        
        self.pipelineComputeStates = [:]
        
        guard let library: MTLLibrary = device.makeDefaultLibrary() else {
            fatalError("Error: Unable to create default library")
        }
        self.library = library
        loadAllFunctions(from: library)
    }
    
    func calcCPU_ApB(A: [Float], B: [Float]) -> String {
        // Ensure A and B are of the same length
        guard A.count == B.count else {
            fatalError("Arrays A and B must be of the same length")
        }
        
        let startTime = DispatchTime.now()
        let result = zip(A, B).map(+)
        let endTime = DispatchTime.now()
        
        let timeInterval = endTime.uptimeNanoseconds - startTime.uptimeNanoseconds
        print("CPU Calculation took: \(Double(timeInterval) / 1_000_000_000) seconds")
        let returnResult = "Result: \(result[A.count-1]), \n CPU Calculation took: \(Double(timeInterval) / 1_000_000_000) seconds"
        return returnResult
    }
    
    func calcGPU_ApB(A: [Float], B: [Float]) -> String? {
        // Ensure A and B are of the same length
        guard A.count == B.count else {
            fatalError("Arrays A and B must be of the same length")
        }
        
        let length = A.count
        let bufferSize = length * MemoryLayout<Float>.size
        
        // Create buffers
        let ABuffer = device.makeBuffer(bytes: A, length: bufferSize, options: [])
        let BBuffer = device.makeBuffer(bytes: B, length: bufferSize, options: [])
        let resultBuffer = device.makeBuffer(length: bufferSize, options: [])
        
        guard let computePipelineState = pipelineComputeStates["vectorAdd"] else {
            fatalError("Error: Compute pipeline state not found for vectorAdd")
        }
        
        // Start timing
        let startTime = DispatchTime.now()
        
        // Create command buffer
        let commandBuffer = commandQueue.makeCommandBuffer()
        let commandEncoder = commandBuffer?.makeComputeCommandEncoder()
        
        // Set buffers and pipeline state
        commandEncoder?.setComputePipelineState(computePipelineState)
        commandEncoder?.setBuffer(ABuffer, offset: 0, index: 0)
        commandEncoder?.setBuffer(BBuffer, offset: 0, index: 1)
        commandEncoder?.setBuffer(resultBuffer, offset: 0, index: 2)
        
        // Dispatch thread groups
        let threadGroupSize = MTLSize(width: 1, height: 1, depth: 1)
        let threadGroups = MTLSize(width: (length + threadGroupSize.width - 1) / threadGroupSize.width,
                                    height: 1,
                                    depth: 1)
        
        commandEncoder?.dispatchThreadgroups(threadGroups, threadsPerThreadgroup: threadGroupSize)
        
        commandEncoder?.endEncoding()
        commandBuffer?.commit()
        commandBuffer?.waitUntilCompleted() // Wait for the GPU to finish
        
        // End timing
        let endTime = DispatchTime.now()
        let timeInterval = endTime.uptimeNanoseconds - startTime.uptimeNanoseconds
        print("GPU Calculation took: \(Double(timeInterval) / 1_000_000_000) seconds")
        
        // Read back result
        let resultPointer = resultBuffer?.contents().bindMemory(to: Float.self, capacity: length)
        let result = Array(UnsafeBufferPointer(start: resultPointer, count: length))
        let returnResult = "Result: \(result[A.count-1]), \n GPU Calculation took: \(Double(timeInterval) / 1_000_000_000) seconds"
        return returnResult
    }
    
    func makeBigArray(size: Int, min: Float = 0.0, max: Float = 1.0) -> [Float] {
        return (0..<size).map { _ in
            Float.random(in: min...max)
        }
    }

    
    private func loadAllFunctions(from library: MTLLibrary) {
        let functionNames = library.functionNames
        for name in functionNames {
            guard let function = library.makeFunction(name: name) else {
                print("Warning: function \(name) couldnt be loaded from the library: \(library), continuing")
                continue
            }
            // if not a kernel, continue onto the next.
            // guard instead of to avoid nesting/force an exit of scope
            guard function.functionType == .kernel else {
                print("\(name) isn't a kernel/compute type, continuing...")
                continue
            }
            do {
                let computeState = try device.makeComputePipelineState(function: function)
                pipelineComputeStates[name] = computeState
            } catch {
                print("Error: Caught error trying to make state for func: \(name), caughtError: \(error)")
            }
        }
        
    }
}
