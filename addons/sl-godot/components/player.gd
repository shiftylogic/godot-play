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

class_name Player3D
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

@export_category( "Character" )
@export var head: Node3D

@export_group( "Tuning" )
@export_range( 0.0, 100.0, 0.5 ) var walk_speed: float = 5.0
@export_range( 0.0, 100.0, 0.5 ) var sprint_speed: float = 10.0
@export_range( 0.0, 100.0, 0.5 ) var jump_velocity: float = 5.5

@export_group( "Input Actions" )
@export_subgroup( "Movement" )
@export var forward: StringName = &"forward"
@export var backward: StringName = &"backward"
@export var strafe_left: StringName = &"left"
@export var strafe_right: StringName = &"right"

@export_subgroup( "Look" )
@export var look_left: StringName = &"look_left"
@export var look_right: StringName = &"look_right"
@export var look_up: StringName = &"look_up"
@export var look_down: StringName = &"look_down"

@export_subgroup( "Actions" )
@export var jump: StringName = &"jump"
@export var sprint: StringName = &"sprint"


@export_category( "Tuning" )

@export_group( "Gamepad" )
@export_range( 0.0, 10.0, 0.5 ) var gamepad_sensitivity: float = 3.0
@export var gamepad_sensitivity_curve: Curve

@export_group( "Mouse" )
@export_range( 0.0, 1.0, 0.05 ) var mouse_sensitivity: float = 0.1



#########################################
#
# Private variables
#

var _gravity = ProjectSettings.get_setting( "physics/3d/default_gravity" )



#########################################
#
# Overrides (_init, _ready, others)
#

func _init():
    _check_action( forward, "forward" )
    _check_action( backward, "backward" )
    _check_action( strafe_left, "strafe_left" )
    _check_action( strafe_right, "strafe_right" )
    _check_action( jump, "jump" )
    _check_action( sprint, "sprint" )
    _check_action( look_left, "look_left" )
    _check_action( look_right, "look_right" )
    _check_action( look_up, "look_up" )
    _check_action( look_down, "look_down" )


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

func _camera_rotate( v: Vector2, sensitivity: float ):
    rotate_y( deg_to_rad( -v.x * sensitivity ) )
    head.rotate_x( deg_to_rad( -v.y * sensitivity ) )
    head.rotation.x = clamp( head.rotation.x, -_LOOK_LIMIT, _LOOK_LIMIT )


func _check_action( action: StringName, tag: String ):
    if not ProjectSettings.has_setting( "input/%s" % action ):
        print_debug( "input '%s' for %s action is not a defined input mapping" % [ action, tag ] )


func _handle_controller_look():
    var look_dir := Input.get_vector( look_left, look_right, look_up, look_down )
    var final_dir := look_dir.abs()
    final_dir.x = gamepad_sensitivity_curve.sample_baked( final_dir.x )
    final_dir.y = gamepad_sensitivity_curve.sample_baked( final_dir.y )
    final_dir *= Vector2( sign( look_dir.x ), sign( look_dir.y ) )

    _camera_rotate( look_dir, gamepad_sensitivity )


func _handle_movement( dt: float ):
    var speed := sprint_speed if is_on_floor() and Input.is_action_pressed( sprint ) else walk_speed
    var input_dir := Input.get_vector( strafe_left, strafe_right, forward, backward )
    var direction := ( transform.basis * Vector3( input_dir.x, 0, input_dir.y ) ).normalized()

    if direction:
        velocity.x = direction.x * speed
        velocity.z = direction.z * speed
    else:
        velocity.x = move_toward( velocity.x, 0, speed )
        velocity.z = move_toward( velocity.z, 0, speed )

    if not is_on_floor():
        velocity.y -= _gravity * dt

    if is_on_floor() and Input.is_action_just_pressed( jump ):
            velocity.y = jump_velocity

    move_and_slide()
