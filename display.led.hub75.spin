{
---------------------------------------------------------------------------------------------------
    Filename:       display.led.hub75.spin
    Description:    Driver for HUB75 RGB LED matrix displays
    Author:         Jesse Burt
    Started:        Oct 24, 2021
    Updated:        Jan 28, 2024
    Copyright (c) 2024 - See end of file for terms of use.
---------------------------------------------------------------------------------------------------
}

#define MEMMV_NATIVE bytemove
#include "graphics.common.spinh"
#ifdef GFX_DIRECT
#   error "GFX_DIRECT not supported by this driver"
#endif

CON

    BYTESPERPX  = 1
    MAX_COLOR   = 7

    { default I/O settings - can be overridden by the parent object }
    WIDTH       = 64
    HEIGHT      = 32
    RGB_BASE    = 0
    ADDR_BASE   = 6
    CLK         = 10
    LAT         = 11
    BL          = 12


    XMAX        = WIDTH-1
    YMAX        = HEIGHT-1
    CENTERX     = WIDTH/2
    CENTERY     = HEIGHT/2
    BPL         = WIDTH*BYTESPERPX

VAR

    long _eng_stack[50]
    long _bl, _clk, _lat

    byte _framebuffer[(WIDTH*HEIGHT)]
    byte _rgbio, _addr
    byte _vsync
    byte _cog

OBJ

    time    : "time"

PUB null{}
' This is not a top-level object

PUB start(): status
' Start the driver using default settings
    return startx(RGB_BASE, ADDR_BASE, BL, CLK, LAT, WIDTH, HEIGHT, @_framebuffer)

PUB startx(RGB_BASEPIN, ADDR_BASEPIN, BLPIN, CLKPIN, LATPIN, DISP_W, DISP_H, PTR_DISP=0): status
' Start using custom I/O settings
'   RGB_BASEPIN: starting (lowest) pin of 6 contiguous RGB data pins
'       (LSB..MSB: R0, G0, B0, R1, G1, B1)
'   ADDR_BASEPIN: starting (lowest) pin of 4 contiguous address pins
'       (LSB..MSB: A, B, C, D)
'   _____                                           __
'   BLPIN: blank control pin (sometimes labelled as OE)
'   CLKPIN: clock pin
'   LATPIN: latch pin
'   WIDTH, HEIGHT: dimensions of RGB matrix display, in pixels
'   PTR_DISP: pointer to display buffer
'       (must be at least (WIDTH * HEIGHT) bytes)
    if ( lookdown(RGB_BASEPIN: 0..25) and lookdown(ADDR_BASEPIN: 0..27) and ...
        lookdown(BLPIN: 0..31) and lookdown(CLKPIN: 0..31) and lookdown(LATPIN: 0..31) )
        if ( _cog := status := (cognew(hub75_engine{}, @_eng_stack) + 1) )
            set_dims(DISP_W, DISP_H)

            _rgbio := RGB_BASEPIN
            _addr := ADDR_BASEPIN
            longmove(@_bl, @BLPIN, 3)

            set_address(PTR_DISP)
            return
    ' if this point is reached, something above failed
    ' Double check I/O pin assignments, connections, power
    ' Lastly - make sure you have at least one free core/cog
    return FALSE

PUB stop{}
' Stop engine, clear variable space
    if ( _cog )
        cogstop(_cog-1)
        longfill(@_eng_stack, 0, 54)
        wordfill(@_disp_width, 0, 6)
        bytefill(@_rgbio, 0, 4)

#ifndef GFX_DIRECT
PUB clear{}
' Clear the display buffer
    bytefill(_ptr_drawbuffer, _bgcolor, _buff_sz)
#endif

PUB plot(x, y, color) | tmp
' Plot pixel at (x, y) in color
    if ( (x < 0) or (x > _disp_xmax) or (y < 0) or (y > _disp_ymax) )
        return                                  ' coords out of bounds, ignore
#ifdef GFX_DIRECT
' direct to display
'   (not implemented)
#else
' buffered display
    byte[_ptr_drawbuffer][x + (y * _disp_width)] := color
#endif

#ifndef GFX_DIRECT
PUB point(x, y): pix_clr
' Get color of pixel at x, y
    x := 0 #> x <# _disp_xmax
    y := 0 #> y <# _disp_ymax

    return byte[_ptr_drawbuffer][x + (y * _disp_width)]
#endif

PUB show{}
' dummy method for compatibility with other drivers

PRI hub75_engine{} | r0, g0, b0, r1, g1, b1, a, b, c, d, bl, clk, lat, tmp, {
} y, x, ty_offs, by_offs, top_offs, bot_offs, bnkht
' HUB75 engine (secondary cog)
    repeat until _lat                           ' wait until all vars are set

    repeat tmp from 0 to 5                      ' copy hub I/O pin vars to 
        long[@r0][tmp] := _rgbio+tmp            '   locals
    repeat tmp from 0 to 3                      '
        long[@a][tmp] := _addr+tmp              '
    longmove(@bl, @_bl, 3)                      '

    bnkht := _disp_height/2                     ' bank (top/bot half) height
    dira[bl..r0] := %1111111111111              ' init I/O pins outputs, and
    outa[b1..r0] := 0                           '   inactive
    outa[d..a] := 0
    outa[bl] := 1
    outa[clk] := 0
    outa[lat] := 0

    repeat                                      ' main loop
        repeat y from 0 to bnkht-1              ' (( Y/row loop ))
            outa[_lat] := 0
            ty_offs := (y * _disp_width)        ' precalc bank row offsets
            by_offs := ((y + bnkht) * _disp_width)
            outa[bl] := 1                       ' turn off output
            outa[d..a] := y                     ' set row address
            repeat x from 0 to _disp_xmax       ' (( X/column loop ))
                top_offs := (ty_offs + x)       ' calc top and bottom bank
                bot_offs := (by_offs + x)       '   offsets
                outa[b1..r0] := (   byte[_ptr_drawbuffer][bot_offs] << 3) | ...
                                    byte[_ptr_drawbuffer][top_offs] ' output the pixel data
                outa[clk] := 1                  ' clock it out
                outa[clk] := 0
            outa[lat] := 1                      ' latch the data shifted in
            outa[bl] := 0                       ' unblank the display
'            time.usleep(1)

#ifndef GFX_DIRECT
PRI memfill(xs, ys, val, count)
' Fill region of display buffer memory
'   xs, ys: Start of region
'   val: Color
'   count: Number of consecutive memory locations to write
    bytefill(_ptr_drawbuffer + (xs + (ys * _bytesperln)), val, count)
#endif

DAT
{
Copyright 2024 Jesse Burt

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
associated documentation files (the "Software"), to deal in the Software without restriction,
including without limitation the rights to use, copy, modify, merge, publish, distribute,
sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or
substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT
OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
}

