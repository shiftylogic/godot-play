# MIT License
#
# Copyright (c) 2023-present Robert Anderson
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

class_name HexGrid
extends Node3D


#########################################
#
# Enums & Constants
#

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

@export_category( "Grid Settings" )

@export
var tile: PackedScene

@export
var tile_size: float = 1.0


@export_category( "Generation Settings" )

@export
var generation_mode: GenerationMode = GenerationMode.GRID:
        set( v ):
            generation_mode = v
            _reset()
        get:
            return generation_mode

@export_range( 2, 20, 1 )
var grid_size: int = 7:
        set( v ):
            grid_size = v
            _reset()
        get:
            return grid_size



#########################################
#
# Overrides (_init, _ready, others)
#

func _ready():
    _reset()



#########################################
#
# Private methods
#

func _reset():
    Global.clear_children( self )

    match generation_mode:
        GenerationMode.GRID:
            _generate_grid.call_deferred()
        GenerationMode.SPIRAL:
            _generate_spiral_grid.call_deferred()


func _generate_grid():
    var offset := ( grid_size * tile_size ) / 2.0
    for x in range( grid_size ):
        var px = x * tile_size * cos( deg_to_rad( 30 ) )
        var py = 0.0 if x % 2 == 0 else tile_size / 2.0

        for y in range( grid_size ):
            _make_tile( px - offset, py - offset )
            py += tile_size


func _generate_spiral_grid():
    _make_tile( 0.0, 0.0 )      # Origin (middle) tile
    for r in range( 1, grid_size ):
        _generate_layer_n( r )


func _generate_layer_n( n: int ):
    var tile_shift := tile_size * cos( deg_to_rad( 30 ) )
    var tile_shift_n := float( n ) * tile_shift
    var tile_size_n := float( n ) * tile_size

    for side in _SIDE_V:
        for c in range( n ):
            _make_tile(
                side.x * tile_shift_n + c * tile_shift * side.w,
                side.y * tile_size_n  + c * tile_size * side.z,
            )


func _make_tile( x: float, y: float ):
    if not tile:
        return

    var t: Node3D = tile.instantiate()
    t.translate( Vector3( x, 0, y ) )
    add_child( t )
