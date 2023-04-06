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


#########################################
#
# Exported properties
#

@export_range( 2, 20, 1 ) var grid_size := 10


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


func _physics_process( _dt: float ):
    pass


#########################################
#
# Public methods
#


#########################################
#
# Private methods
#

func _generate_grid():
    for x in range( grid_size ):
        var p := Vector2.ZERO
        p.x = x * _TILE_SIZE * cos( deg_to_rad( 30 ) )
        p.y = 0 if x % 2 == 0 else _TILE_SIZE / 2

        for y in range( grid_size ):
            var tile: Node3D = _Hex.instantiate()
            tile.translate( Vector3( p.x, 0, p.y ) )
            add_child( tile )
            p.y += _TILE_SIZE


#########################################
#
# Event handlers
#


