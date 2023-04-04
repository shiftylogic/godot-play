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
# Signals
#


#########################################
#
# Preloaded assets (scenes, resources, etc)
#

const _DarkNormal = preload( "./dark-normal.material" )
const _LightNormal = preload( "./light-normal.material" )
const _Square = preload( "./chess-square.tscn" )


#########################################
#
# Enums & Constants
#

const _GRID_SIZE := 8
const _TILE_SIZE := 1.0


#########################################
#
# Exported properties
#


#########################################
#
# Private variables
#


#########################################
#
# Overrides (_init, _ready, others)
#

func _ready():
    _generate_grid()


#########################################
#
# Private methods
#

func _generate_grid():
    var start_offset := ( _GRID_SIZE / 2.0 ) * _TILE_SIZE - ( _TILE_SIZE / 2.0 )
    var light := true
    var py := -start_offset

    for y in range( _GRID_SIZE ):
        var px := -start_offset
        for x in range( _GRID_SIZE ):
            _create_square( px, py, light )

            px += _TILE_SIZE
            light = not light

        py += _TILE_SIZE
        light = not light


func _create_square( px: float, py: float, light: bool ):
    var sq: ChessSquare = _Square.instantiate()
    sq.NormalMaterial = _LightNormal if light else _DarkNormal
    sq.translate( Vector3( px, 0, py ) )
    add_child( sq )


#########################################
#
# Event handlers
#
