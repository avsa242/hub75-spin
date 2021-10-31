# hub75-spin
------------

This is a P8X32A/Propeller, P2X8C4M64P/Propeller 2 driver object for HUB75 RGB LED matrix displays

**IMPORTANT**: This software is meant to be used with the [spin-standard-library](https://github.com/avsa242/spin-standard-library) (P8X32A) or [p2-spin-standard-library](https://github.com/avsa242/p2-spin-standard-library) (P2X8C4M64P). Please install the applicable library first before attempting to use this code, otherwise you will be missing several files required to build the project.

## Salient Features

* 3bpp color (7 colors)
* Integration with generic bitmap graphics library

## Requirements

* 2kB for display buffer

P1/SPIN1:
* spin-standard-library
* presence of lib.gfx.bitmap.spin
* 1 extra core/cog for the HUB75 engine

P2/SPIN2:
* p2-spin-standard-library
* presence of lib.gfx.bitmap.spin2
* 1 extra core/cog for the HUB75 engine

## Compiler Compatibility

* P1/SPIN1 OpenSpin (bytecode): OK, tested with 1.00.81
* P1/SPIN1 FlexSpin (bytecode): OK, tested with 5.9.4-beta
* P1/SPIN1 FlexSpin (native): OK, tested with 5.9.4-beta
* ~~P2/SPIN2 FlexSpin (bytecode): FTBFS, tested with 5.9.4-beta~~
* P2/SPIN2 FlexSpin (native): OK, tested with 5.9.4-beta
* ~~BST~~ (incompatible - no preprocessor)
* ~~Propeller Tool~~ (incompatible - no preprocessor)
* ~~PNut~~ (incompatible - no preprocessor)

## Hardware Compatibility

* Tested using Adafruit 64x32 panel (*NOTE: Due to the many variations of components used on these panels, the driver may not work for all without modification*)

## Limitations

* Very early in development - may malfunction, or outright fail to build
* No brightness support
* No support for higher color depths
* Driver is currently written in spin (too slow to be of practical use when compiled as bytecode; building to native code using FlexSpin is highly recommended)

