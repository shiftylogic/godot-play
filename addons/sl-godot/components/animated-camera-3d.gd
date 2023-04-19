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

class_name AnimatedCamera3D
extends Camera3D


#########################################
#
# Exported properties
#

@export_category( "Animation Tuning" )

@export
var ease_type: Tween.EaseType = Tween.EASE_IN

@export
var transition_type: Tween.TransitionType = Tween.TRANS_CUBIC

@export
var transition_duration: float = 0.5


@export_category( "Anchors" )

@export
var position_anchor: Node3D:
        set( anchor ):
            position_anchor = anchor
            _animate_transition()
        get:
            return position_anchor

@export
var view_anchor: Node3D:
        set( anchor ):
            view_anchor = anchor
            _animate_transition()
        get:
            return view_anchor


#########################################
#
# Private variables
#

var _transition_tween: Tween



#########################################
#
# Private methods
#

func _animate_transition():
    if _transition_tween:
        _transition_tween.kill()

    var final_transform := Transform3D(
        Basis.IDENTITY,
        position_anchor.global_position if position_anchor else Vector3.ZERO
    ).looking_at(
        view_anchor.global_position if view_anchor else Vector3.ZERO,
        Vector3.UP
    )

    _transition_tween = create_tween()
    _transition_tween.set_ease( ease_type )
    _transition_tween.set_trans( transition_type )
    _transition_tween.set_parallel()
    _transition_tween.tween_property(
        self,
        "global_position",
        final_transform.origin,
        transition_duration
    )
    _transition_tween.tween_property(
        self,
        "global_transform:basis:x",
        final_transform.basis.x,
        transition_duration
    )
    _transition_tween.tween_property(
        self,
        "global_transform:basis:y",
        final_transform.basis.y,
        transition_duration
    )
    _transition_tween.tween_property(
        self,
        "global_transform:basis:z",
        final_transform.basis.z,
        transition_duration
    )
