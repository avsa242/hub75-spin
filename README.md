# hub75-spin
------------

This is a P8X32A/Propeller, P2X8C4M64P/Propeller 2 driver object for HUB75 RGB LED matrix displays

**IMPORTANT**: This software is meant to be used with the [spin-standard-library](https://github.com/avsa242/spin-standard-library) (P8X32A) or [p2-spin-standard-library](https://github.com/avsa242/p2-spin-standard-library) (P2X8C4M64P). Please install the applicable library first before attempting to use this code, otherwise you will be missing several files required to build the project.

## Salient Features

* 3bpp color (8 colors), treated internally as 8-bit format
* Integration with generic bitmap graphics library

## Requirements

* x kB for display buffer, where x == panel width * height (e.g., 64x32 = 2048, or 2kBytes)

P1/SPIN1:
* spin-standard-library
* graphics.common.spinh (provided by spin-standard-library)
* 1 extra core/cog for the HUB75 engine

P2/SPIN2:
* p2-spin-standard-library
* graphics.common.spin2h (provided by p2-spin-standard-library)
* 1 extra core/cog for the HUB75 engine

## Compiler Compatibility

| Processor | Language | Compiler               | Backend      | Status                |
|-----------|----------|------------------------|--------------|-----------------------|
| P1        | SPIN1    | FlexSpin (6.8.0)       | Bytecode     | OK (not recommended)  |
| P1        | SPIN1    | FlexSpin (6.8.0)       | Native/PASM  | OK (recommended)      |
| P2        | SPIN2    | FlexSpin (6.8.0)       | NuCode       | OK (untested)         |
| P2        | SPIN2    | FlexSpin (6.8.0)       | Native/PASM2 | OK                    |

(other versions or toolchains not listed are not supported, and _may or may not_ work)


## Hardware Compatibility

* Tested using Adafruit 64x32 panel (*NOTE: Due to the many variations of components used on these panels, the driver may not work for all without modification*)
* Tested up to 180MHz Fsys on P2 (display was somewhat unstable at this speed)

## Limitations

* No brightness support
* No support for higher color depths
* Driver is currently written in spin (too slow to be of practical use when compiled as bytecode on P1; building to native code using FlexSpin is highly recommended)

