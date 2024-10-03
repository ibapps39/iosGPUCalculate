//
//  kernelShader.metal
//  iosGPUCalculate
//
//  Created by Ian Brown on 10/1/24.
//

#include <metal_stdlib>
using namespace metal;

// Kernel, Compute, function for vector addition
kernel void vectorAdd(
                      const device float* A [[ buffer(0)]],
                      const device float* B [[ buffer(1)]],
                      device float* result [[ buffer(2)]],
                      uint id [[ thread_position_in_grid ]]
                      ) 
{
    result[id] = A[id] + B[id];
}


