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

@onready var _anchor_visuals: MultiMeshInstance3D = $Anchors
@onready var _observer: AnimatedCamera3D = $Observer

var _anchors: Array[Node3D] = []
var _t_type_idx: int = 0
var _e_type_idx: int = 0
var _o_idx: int = 0


#########################################
#
# Overrides (_init, _ready, others)
#

func _ready():
    _generate_anchors()
#    _observer.look_at_from_position(
#        _anchors.multimesh.get_instance_transform( 0 ).origin,
#        Vector3.ZERO
#    )


func _process( _dt: float ):
    if Input.is_action_just_pressed( "ui_left" ):
        _e_type_idx = ( _e_type_idx + 1 ) % _CAMERA_EASING.size()
        _observer.ease_type = _CAMERA_EASING[ _e_type_idx ]
        print( "Switching ease type: %s" % _CAMERA_EASING_NAMES[ _e_type_idx ] )

    if Input.is_action_just_pressed( "ui_up" ):
        _t_type_idx = (_t_type_idx + 1) % _CAMERA_TRANSITIONS.size()
        _observer.transition_type = _CAMERA_TRANSITIONS[ _t_type_idx ]
        print( "Switching transition type: %s" % _CAMERA_TRANSITION_NAMES[ _t_type_idx ] )

    if Input.is_action_just_pressed( "ui_down" ):
        _o_idx = (_o_idx + 1) % 6
        match _o_idx:
            0: _observer.view_anchor = $Origin as Node3D
            1: _observer.view_anchor = $Thing1 as Node3D
            2: _observer.view_anchor = $Thing2 as Node3D
            3: _observer.view_anchor = $Thing3 as Node3D
            4: _observer.view_anchor = $Thing4 as Node3D
            5: _observer.view_anchor = $Thing5 as Node3D

    if Input.is_action_just_pressed( "ui_accept" ):
        var idx := randi_range( 0, _ANCHOR_COUNT - 1 )
        var duration := randf_range( 5.5, 10.0 )

        print( "Selecting anchor #%d. Moving to (%.3f, %.3f, %.3f) over %.3f seconds." % [
            idx,
            _anchors[ idx ].global_position.x,
            _anchors[ idx ].global_position.y,
            _anchors[ idx ].global_position.z,
            duration
        ] )

        _observer.transition_duration = duration
        _observer.position_anchor = _anchors[ idx ]


#########################################
#
# Private methods
#

func _generate_anchors():
    var mm := _anchor_visuals.multimesh
    mm.instance_count = _ANCHOR_COUNT

    for idx in range( _ANCHOR_COUNT ):
        var col := Color( randf(), randf(), randf() )
        var pos := Vector3(
            randf_range( _GROUND_REGION_MIN, _GROUND_REGION_MAX ),
            randf_range( _ANCHOR_HEIGHT_MIN, _ANCHOR_HEIGHT_MAX ),
            randf_range( _GROUND_REGION_MIN, _GROUND_REGION_MAX ),
        )
        var xform := Transform3D( Basis.IDENTITY, pos )
        mm.set_instance_color( idx, col )
        mm.set_instance_transform( idx, xform )

        var anchor := Node3D.new()
        anchor.global_transform = xform
        _anchors.append( anchor )
        add_child( anchor )



#########################################
#
# Event handlers
#
