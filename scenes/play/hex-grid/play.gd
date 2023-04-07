# MIT License
#
# Copyright (c) 2023 Robert Anderson
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

extends Node3D


#########################################
#
# Preloaded assets (scenes, resources, etc)
#

const _Hex := preload( "./tile.tscn" )


#########################################
#
# Signals
#


#########################################
#
# Enums & Constants
#

const _TILE_SIZE := 1.0
const _TILE_SHIFT := _TILE_SIZE * cos( deg_to_rad( 30 ) )

const _SIDE_V := [
    Vector4(  0.0,  1.0, -0.5,  1.0 ),      # bottom
    Vector4(  1.0,  0.5, -1.0,  0.0 ),      # bottom-right
    Vector4(  1.0, -0.5, -0.5, -1.0 ),      # top-right
    Vector4(  0.0, -1.0,  0.5, -1.0 ),      # top
    Vector4( -1.0, -0.5,  1.0,  0.0 ),      # top-left
    Vector4( -1.0,  0.5,  0.5,  1.0 ),      # bottom-left
]

enum GenerationMode {
    GRID,
    SPIRAL,
}

#########################################
#
# Exported properties
#

@export
var generation_mode: GenerationMode = GenerationMode.GRID:
        set( v ):
            generation_mode = v
            _reset_grid()
        get:
            return generation_mode

@export_range( 2, 20, 1 )
var grid_size: int = 7:
        set( v ):
            grid_size = v
            _reset_grid()
        get:
            return grid_size

@export_range( 2, 20, 1 )
var ring_count: int = 6:
        set( v ):
            ring_count = v
            _reset_grid()
        get:
            return ring_count


#########################################
#
# Private variables
#

@onready var _grid: Node3D = $Grid


#########################################
#
# Overrides (_init, _ready, others)
#

func _ready():
    _reset_grid()


func _unhandled_input( _ev: InputEvent ):
    if Input.is_key_pressed( KEY_G ):
        generation_mode = GenerationMode.GRID
    if Input.is_key_pressed( KEY_S ):
        generation_mode = GenerationMode.SPIRAL

    if Input.is_key_pressed( KEY_UP ):
        _bump_size( 1 )
    if Input.is_key_pressed( KEY_DOWN ):
        _bump_size( -1 )


#########################################
#
# Private methods
#

func _bump_size( c: int ):
    match generation_mode:
        GenerationMode.GRID:
            grid_size += c
        GenerationMode.SPIRAL:
            ring_count += c


func _reset_grid():
    for child in _grid.get_children():
        child.queue_free()

    match generation_mode:
        GenerationMode.GRID:
            _generate_grid.call_deferred( grid_size )
        GenerationMode.SPIRAL:
            _generate_spiral_grid.call_deferred( ring_count )


func _generate_grid( size: int ):
    var offset := ( size * _TILE_SIZE ) / 2.0
    for x in range( size ):
        var px = x * _TILE_SIZE * cos( deg_to_rad( 30 ) )
        var py = 0.0 if x % 2 == 0 else _TILE_SIZE / 2.0

        for y in range( size ):
            _make_tile( px - offset, py - offset )
            py += _TILE_SIZE


func _generate_spiral_grid( rings: int ):
    _make_tile( 0.0, 0.0 )      # Origin (middle) tile
    for r in range( 1, rings ):
        _generate_layer_n( r )


func _generate_layer_n( n: int ):
    var angle_shift := float( n ) * _TILE_SHIFT
    var tile_shift := float( n ) * _TILE_SIZE

    for side in _SIDE_V:
        for c in range( n ):
            _make_tile(
                side.x * angle_shift + c * _TILE_SHIFT * side.w,
                side.y * tile_shift  + c * _TILE_SIZE * side.z,
            )


func _make_tile( x: float, y: float ):
    var tile: Node3D = _Hex.instantiate()
    tile.translate( Vector3( x, 0, y ) )
    _grid.add_child( tile )
