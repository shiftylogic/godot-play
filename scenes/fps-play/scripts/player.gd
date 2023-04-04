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

extends CharacterBody3D


#########################################
#
# Enums & Constants
#

const _LOOK_LIMIT = deg_to_rad( 89 )


#########################################
#
# Exported properties
#

@export_category( "Gamepad" )
@export var gamepad_sensitivity_curve: Curve
@export_range( 1.0, 5.0, 0.5 ) var gamepad_sensitivity := 3.0

@export_category( "Keyboard / Mouse" )
@export_range( 0.01, 0.05, 0.5 )
var mouse_sensitivity := 0.1

@export_category( "Character" )
@export_range( 0.0, 20.0, 0.25 )
var walk_speed := 5.0

@export_range( 0.0, 50.0, 0.25 )
var sprint_speed := 10.0

@export_range( 0.0, 100.0, 0.25 )
var jump_velocity := 4.5


#########################################
#
# Private variables
#

@onready var _head: Node3D = $Head

var _gravity = ProjectSettings.get_setting( "physics/3d/default_gravity" )


#########################################
#
# Overrides (_init, _ready, others)
#

func _input( event: InputEvent ):
    if event is InputEventMouseMotion:
        var mevent := event as InputEventMouseMotion
        _camera_rotate( Vector2( mevent.relative.x, mevent.relative.y ), mouse_sensitivity )


func _physics_process( dt: float ):
    _handle_movement( dt )
    _handle_controller_look()


#########################################
#
# Private methods
#

func _handle_controller_look():
    var look_dir := Input.get_vector( "look_left", "look_right", "look_up", "look_down" )
    var signs := Vector2( sign( look_dir.x ), sign( look_dir.y ) )

    look_dir = look_dir.abs()
    look_dir.x = gamepad_sensitivity_curve.sample_baked( look_dir.x )
    look_dir.y = gamepad_sensitivity_curve.sample_baked( look_dir.y )
    look_dir *= signs

    _camera_rotate( look_dir, gamepad_sensitivity )


func _camera_rotate( v: Vector2, sensitivity: float ):
    rotate_y( deg_to_rad( -v.x * sensitivity ) )
    _head.rotate_x( deg_to_rad( -v.y * sensitivity ) )
    _head.rotation.x = clamp( _head.rotation.x, -_LOOK_LIMIT, _LOOK_LIMIT )


func _handle_movement( dt: float ):
    if not is_on_floor():
        velocity.y -= _gravity * dt

    if Input.is_action_just_pressed( "jump" ) and is_on_floor():
        velocity.y = jump_velocity

    var speed := sprint_speed if Input.is_action_pressed( "sprint" ) and is_on_floor() else walk_speed
    var input_dir := Input.get_vector( "left", "right", "forward", "backward" )
    var direction := ( transform.basis * Vector3( input_dir.x, 0, input_dir.y ) ).normalized()

    if direction:
        velocity.x = direction.x * speed
        velocity.z = direction.z * speed
    else:
        velocity.x = move_toward( velocity.x, 0, speed )
        velocity.z = move_toward( velocity.z, 0, speed )

    move_and_slide()
