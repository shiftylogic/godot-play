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
# Signals
#


#########################################
#
# Enums & Constants
#

const MINIMUM_INTRO_DELAY: float = 2.0      # seconds
const MINIMUM_LOADING_DELAY: float = 1.0    # seconds

const LoadingScene := preload( "./loading/loading.tscn" )


#########################################
#
# Exported properties
#


#########################################
#
# Private variables
#

@onready var _loader = preload( "./loader.gd" ).new()

var _active: Node



#########################################
#
# Overrides (_init, _ready, others)
#

func _ready():
    add_child( _loader )
    _loader.connect( "resource_error", _report_error_terminate )
    _loader.connect( "resource_ready", _swap_to_scene_from_intro, CONNECT_ONE_SHOT )

    # On game startup, the "intro" screen is running while we prepare the
    # main menu scene. We will then swap out the "intro" with a generic
    # loading screen for future scene changes.
    _active = $Main/Intro
    _loader.load_resource( "res://scenes/main-menu/main-menu.tscn" )

    # DELETE ME
    await get_tree().create_timer( 7.0 ).timeout
    change_scene( "res://scenes/hud/hud.tscn" )


#########################################
#
# Public methods
#

func change_scene( scene: String ) -> void:
    # Remove any existing scene that is rendering
    if _active != null:
        _active.queue_free()

    # Swap to loading screen
    _active = LoadingScene.instantiate()
    $Main.add_child( _active )

    # Start the next scene / resource loading
    _loader.load_resource( scene )


#########################################
#
# Event handlers
#

func _report_error_terminate( err: String ) -> void:
    print_debug( "An error occurred (%s). Terminating..." % err )
    get_tree().quit( -1 )


func _swap_to_scene( scene: PackedScene, dt: float, min_delay: float ) -> void:
    # Allow the "intro" to stay up for at least a couple seconds
    var delay: float = min_delay - dt
    if delay > 0.0:
        print_debug( "Delaying extra %.3f seconds" % delay )
        await get_tree().create_timer( delay ).timeout

    # Remove the "active" scene (which should be the loading UI
    _active.queue_free()

    # Instantiate the new scene and display it.
    _active = scene.instantiate()
    $Main.add_child( _active )


func _swap_to_scene_from_intro( scene: PackedScene, dt: float ) -> void:
    # Swap to the requested scene
    # This should happen *before* replacing the "intro".
    _swap_to_scene( scene, dt, MINIMUM_INTRO_DELAY )

    # The "intro" screen is meant to only show once (at load time).
    # Swap out to the generic "loading" scene for future scene changes
    # _loader = preload( "res://scenes/game/loading/loading.tscn" ).instantiate()
    _loader.connect( "resource_ready", _swap_to_scene.bind( MINIMUM_LOADING_DELAY ) )
