//
//  Metal.swift
//  iosGPUCalculate
//
//  Created by Ian Brown on 10/1/24.
//

import Foundation
import Metal
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
        
        guard let library: MTLLibrary = device.makeDefaultLibrary() else {
            fatalError("Error: Unable to create default library")
        }
        self.library = library
        
        self.pipelineComputeStates = [:]
        
    }
    
    func loadAllFunctions(from library: MTLLibrary) {
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
