//
//  kernelShader.metal
//  iosGPUCalculate
//
//  Created by Ian Brown on 10/1/24.
//

#include <metal_stdlib>
using namespace metal;

kernel void add_arrays(const device float *a [[ buffer(0) ]],
                       const device float *b [[ buffer(1) ]],
                       device float *result [[ buffer(2) ]],
                       uint id [[ thread_position_in_grid ]]) {
    result[id] = a[id] + b[id];
}


