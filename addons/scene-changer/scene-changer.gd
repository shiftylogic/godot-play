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

extends ColorRect
class_name SceneChanger


#########################################
#
# Exported properties
#

@export_category( "Transition Settings" )
@export var loading_scene: PackedScene
@export_range( 0.0, 10.0, 0.1 ) var minimum_loading_seconds: float = 2.0

@export_category( "Fade Settings" )
@export_range( 0.0, 2.0, 0.1 ) var fade_delay: float = 0.4


#########################################
#
# Private variables
#

var _loader: Node = null
var _scene: String = ""
var _start: int = 0


#########################################
#
# Overrides (_init, _ready, others)
#

func _init() -> void:
    color = Color.BLACK
    z_index = RenderingServer.CANVAS_ITEM_Z_MAX
    set_anchors_preset( Control.PRESET_FULL_RECT )


func _ready() -> void:
    set_process( false )

    # On entering the scene, we try to smoothly transition the scene
    # into view.
    await _fade_in()


func _process( _delta: float ) -> void:
    var progress: Array[float] = []
    match ResourceLoader.load_threaded_get_status( _scene, progress ):
        ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
            Global.report_error_terminate( "SceneChanger", "invalid resource [%s]" % _scene )
        ResourceLoader.THREAD_LOAD_IN_PROGRESS:
            print( "Load status (progress) [\"%s\"]: %3.2f" % [_scene, progress[0] * 100.0] )
            # TODO: Send progress update to "loading" screen
        ResourceLoader.THREAD_LOAD_FAILED:
            Global.report_error_terminate( "SceneChanger", "resource load failure [%s]" % _scene )
        ResourceLoader.THREAD_LOAD_LOADED:
            var resource = ResourceLoader.load_threaded_get( _scene )
            var dt: float = ( Time.get_ticks_msec() - _start ) / 1000.0
            _swap_to_scene( resource, dt )


#########################################
#
# Public methods
#

func goto( scene: String, loader: Node = null ) -> void:
    # Fade the current scene to blackout to prepare for transition
    await _fade_out()

    # TODO: Show loading screen (provide updates somewhere).
    if loader:
        _loader = loader
        add_child( _loader )

    # Start loading the requested scene
    _start = Time.get_ticks_msec()
    var err = ResourceLoader.load_threaded_request( scene )
    if err != OK:
        Global.report_error_terminate( "SceneChanger", "Requested scene (\"%s\") failed to queue." % scene )

    _scene = scene
    set_process( true )


#########################################
#
# Private methods
#

func _fade_in() -> void:
    await get_tree().create_tween().tween_property( self, "modulate", Color( 0, 0, 0, 0 ), fade_delay ).finished


func _fade_out() -> void:
    await get_tree().create_tween().tween_property( self, "modulate", Color.WHITE, fade_delay ).finished


func _swap_to_scene( scene: PackedScene, dt: float ) -> void:
    print( "Scene '%s' loaded in %.3f seconds" % [scene.resource_path, dt] )

    # Resource is already loaded, no need to continue processing this node.
    set_process( false )

    # Delay the transition for at least the minimum required
    var delay: float = minimum_loading_seconds - dt
    if delay > 0.0:
        # print_debug( "Delaying extra %.3f seconds" % delay )
        await get_tree().create_timer( delay ).timeout

    get_tree().change_scene_to_packed( scene )
