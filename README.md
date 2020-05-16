# Closed-form Fibonacci on GPU
Using Swift and Metal this project implements Closed-form Fibonacci on a GPU

## Requirements
This project uses [apple/swift-arguments-parser](https://github.com/apple/swift-argument-parser)

## How to use
After building in Xcode, simply run in the command line.
For one result at index use:
```bash
  Closed-form\ Fibonacci\ on\ GPU <index>
```
To do a range set a start:
```bash
  Closed-form\ Fibonacci\ on\ GPU --start <start_index> <index>
```
To run on the CPU instead include the CPU flag:
```bash
  Closed-form\ Fibonacci\ on\ GPU --cpu --start <start_index> <index>
```

## Limitations
The CPU calculations (using the --cpu flag) are only accurate in the range (0, 70].

The GPU calculations are only accurate in the range (0, 32].

## Improvements
This project could be improved by implementing a arbitrary-precision arithmetic.
This would require a new data structure on both the Swift and MSL sides.
And it would need a way to accurately pass the data between the CPU and GPU.
