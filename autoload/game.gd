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

extends Node


#########################################
#
# Enums & Constants
#

const MINIMUM_LOADING_DELAY: float = 1.0    # seconds

const LoadingScene := preload( "res://scenes/loading/loading.tscn" )


#########################################
#
# Private variables
#

@onready var _loader = preload( "res://utils/loader.gd" ).new()
@onready var _root = Node.new()


#########################################
#
# Overrides (_init, _ready, others)
#

func _ready():
    _loader.connect( "resource_error", _report_error_terminate )
    _loader.connect( "resource_ready", _swap_to_scene_from_intro, CONNECT_ONE_SHOT )

    add_child( _loader )
    add_child( _root )

    # On game startup, the "intro" screen is running while we prepare the
    # main scene. We will then swap out the "intro" with a generic loading
    # screen for future scene changes.
    _root.add_child( preload("res://scenes/intro/intro.tscn").instantiate() )
    print( "Game ready!" )


#########################################
#
# Public methods
#

func change_scene( scene: String, show_loading = true ) -> void:
    if show_loading:
        # Swap to loading screen
        _transition_scene( LoadingScene.instantiate() )

    # Start the next scene / resource loading
    _loader.load_resource( scene )


func quit() -> void:
    get_tree().quit()


#########################################
#
# Private methods
#

func _close_curtain() -> Node:
    var curtain := ColorRect.new()
    curtain.set_anchors_preset( Control.PRESET_FULL_RECT )
    curtain.modulate = Color(0, 0, 0, 0)

    add_child(curtain)
    await get_tree().create_tween().tween_property( curtain, "modulate", Color.BLACK, 0.4 ).finished

    return curtain


func _transition_scene( scene: Node ) -> void:
    assert( scene != null, "transition to invalid scene node" )

    # Black out the active scene (by 'closing' the curtain)
    var curtain: Node = await _close_curtain()

    # Swap the scenes while we are blacked out.
    _root.get_children().all( func (child: Node): child.queue_free() )
    _root.add_child( scene )

    # Bring the new scene back into visibility
    await get_tree().create_tween().tween_property( curtain, "modulate", Color(0, 0, 0, 0), 0.4 ).finished
    curtain.queue_free()


#########################################
#
# Event handlers
#

func _report_error_terminate( err: String ) -> void:
    print_debug( "An error occurred (%s). Terminating..." % err )
    get_tree().quit( -1 )


func _swap_to_scene( scene: PackedScene, dt: float ) -> void:
    # Allow the "intro" to stay up for at least a couple seconds
    var delay: float = MINIMUM_LOADING_DELAY - dt
    if delay > 0.0:
        # print_debug( "Delaying extra %.3f seconds" % delay )
        await get_tree().create_timer( delay ).timeout

    # Instantiate the new scene and transition to it.
    assert( scene.can_instantiate(), "loaded resource is not instantiatable" )
    _transition_scene( scene.instantiate() )


func _swap_to_scene_from_intro( scene: PackedScene, dt: float ) -> void:
    # Swap to the requested scene
    # This should happen *before* replacing the "intro".
    _swap_to_scene( scene, dt )

    # The "intro" screen is meant to only show once (at load time).
    # Swap out to the generic "loading" scene for future scene changes
    _loader.connect( "resource_ready", _swap_to_scene )
