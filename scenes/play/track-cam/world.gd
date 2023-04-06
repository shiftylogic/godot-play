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


#########################################
#
# Enums & Constants
#

const _ANCHOR_COUNT := 100

const _ANCHOR_HEIGHT_MIN: float = 0.5
const _ANCHOR_HEIGHT_MAX: float = 25.0

const _GROUND_SIZE: float = 100.0
const _GROUND_REGION_MIN: float = -1.0 * _GROUND_SIZE / 2.0
const _GROUND_REGION_MAX: float = _GROUND_SIZE / 2.0

const _CAMERA_EASING := [
    Tween.EASE_IN,
    Tween.EASE_IN_OUT,
    Tween.EASE_OUT,
    Tween.EASE_OUT_IN,
]
const _CAMERA_EASING_NAMES := [
    "EASE_IN",
    "EASE_IN_OUT",
    "EASE_OUT",
    "EASE_OUT_IN",
]
const _CAMERA_TRANSITIONS := [
    Tween.TRANS_BACK,
    Tween.TRANS_BOUNCE,
    Tween.TRANS_CIRC,
    Tween.TRANS_CUBIC,
    Tween.TRANS_ELASTIC,
    Tween.TRANS_EXPO,
    Tween.TRANS_LINEAR,
    Tween.TRANS_QUAD,
    Tween.TRANS_QUART,
    Tween.TRANS_QUINT,
    Tween.TRANS_SINE,
]
const _CAMERA_TRANSITION_NAMES := [
    "TRANS_BACK",
    "TRANS_BOUNCE",
    "TRANS_CIRC",
    "TRANS_CUBIC",
    "TRANS_ELASTIC",
    "TRANS_EXPO",
    "TRANS_LINEAR",
    "TRANS_QUAD",
    "TRANS_QUART",
    "TRANS_QUINT",
    "TRANS_SINE",
]


#########################################
#
# Exported properties
#


#########################################
#
# Private variables
#

@onready var _anchors: MultiMeshInstance3D = $Anchors
@onready var _observer: Camera3D = $Observer

var _moving: bool = false


#########################################
#
# Overrides (_init, _ready, others)
#

func _ready():
    _generate_anchors()
    _animate_camera( randi_range( 0, _ANCHOR_COUNT ) )


func _process( _dt: float ):
    if Input.is_key_pressed( KEY_SPACE ):
        _animate_camera( randi_range( 0, _ANCHOR_COUNT ) )


#########################################
#
# Private methods
#

func _generate_anchors():
    var mm := _anchors.multimesh
    mm.instance_count = _ANCHOR_COUNT

    for idx in range( _ANCHOR_COUNT ):
        var col := Color( randf(), randf(), randf() )
        var pos := Vector3(
            randf_range( _GROUND_REGION_MIN, _GROUND_REGION_MAX ),
            randf_range( _ANCHOR_HEIGHT_MIN, _ANCHOR_HEIGHT_MAX ),
            randf_range( _GROUND_REGION_MIN, _GROUND_REGION_MAX ),
        )
        mm.set_instance_color( idx, col )
        mm.set_instance_transform( idx, Transform3D( Basis(), pos ) )


func _animate_camera( idx: int ):
    if _moving:
        return

    _moving = true

    var duration := randf_range( 1.0, 5.0 )
    var easing = _CAMERA_EASING.pick_random()
    var transition = _CAMERA_TRANSITIONS.pick_random()
    print( "Animating in %.3f seconds using %s, %s" % [
        duration,
        _CAMERA_TRANSITION_NAMES[ transition ],
        _CAMERA_EASING_NAMES[ easing ],
    ] )

    var t := create_tween()
    t.set_ease( easing )
    t.set_trans( transition )
    t.tween_method(
        func( pos: Vector3 ): _observer.look_at_from_position( pos, Vector3.ZERO ),
        _observer.global_position,
        _anchors.multimesh.get_instance_transform( idx ).origin,
        duration
    )

    await t.finished
    print( "  => complete." )
    _moving = false


#########################################
#
# Event handlers
#
