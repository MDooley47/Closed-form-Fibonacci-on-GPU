//
//  fibonacci.metal
//  Closed-form Fibonacci on GPU
//
//  Created by Matthew Dooley on 5/14/20.
//  Copyright © 2020 Matthew Dooley. All rights reserved.
//

#include <metal_stdlib>

using namespace metal;

// declare methods
kernel void fibonacci(device unsigned int* start,
                      device unsigned int* result,
                      unsigned int index);
unsigned int fibonacci(unsigned int index);
unsigned int binetsFormula(unsigned int n);

// initialize methods
kernel void fibonacci(device unsigned int* start,
                      device unsigned int* result,
                      unsigned int index [[thread_position_in_grid]])
{
    result[index] = fibonacci(*start + index);
}

unsigned int fibonacci(unsigned int index)
{
    return binetsFormula(index);
    
    unsigned int n1 = binetsFormula(index - 1);
    unsigned int n2 = binetsFormula(index - 2);
    
    return n1 + n2;
}

unsigned int binetsFormula(unsigned int n)
{
    const float sqrt5 = sqrt(5.0);
    const float goldenRatio = (1 + sqrt5) / 2;
    const float psi = (1 - goldenRatio);
    
    return (unsigned int)((pow(goldenRatio, n) - pow(psi, n)) / sqrt5);
}
