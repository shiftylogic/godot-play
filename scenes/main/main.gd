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

extends Control


#########################################
#
# Signals
#


#########################################
#
# Preloaded assets (scenes, resources, etc)
#

const _Loader := preload( "res://scenes/transition/transition.tscn" )


#########################################
#
# Enums & Constants
#

enum _Screens {
    MAIN = 0,
    SETTINGS = 1,
    GAME_SETTINGS = 2,
    VIDEO_SETTINGS = 3,
    AUDIO_SETTINGS = 4,
}


#########################################
#
# Exported properties
#


#########################################
#
# Private variables
#

@onready var _changer: SceneChanger  = $SceneChanger
@onready var _screens: TabContainer = $SafeArea/MainScreens


#########################################
#
# Overrides (_init, _ready, others)
#

func _ready() -> void:
    _ensure_focus.call_deferred( _Screens.MAIN )


func _input( ev: InputEvent ):
    if ev.is_action_pressed( "ui_cancel" ):
        _switch_to_screen( _Screens.MAIN )


#########################################
#
# Private methods
#

func _ensure_focus( screen: _Screens ) -> void:
    match screen:
        _Screens.MAIN: ($SafeArea/MainScreens/MainMenu/Options/New as Control).grab_focus()
        _Screens.SETTINGS: ($SafeArea/MainScreens/Settings/Options/Game as Control).grab_focus()
        _: print( "[WARN] Focus on screen index %d not specified" % screen )


func _switch_to_screen( screen: _Screens ) -> void:
    var index: int = screen
    assert( index >= 0 and index < _screens.get_child_count(), "screen index out of range" )

    _screens.current_tab = index
    _ensure_focus( screen )


#########################################
#
# Event handlers
#

func _on_new_game():
    _changer.goto( "res://scenes/hud/hud.tscn", _Loader.instantiate() )


func _on_load_game():
    _changer.goto( "res://scenes/play/play.tscn", _Loader.instantiate() )
    pass


func _on_settings():
    _switch_to_screen( _Screens.SETTINGS )


func _on_exit():
    get_tree().quit()


func _on_settings_game():
    _switch_to_screen( _Screens.GAME_SETTINGS )


func _on_settings_video():
    _switch_to_screen( _Screens.VIDEO_SETTINGS )


func _on_settings_audio():
    _switch_to_screen( _Screens.AUDIO_SETTINGS )


func _on_settings_back():
    _switch_to_screen( _Screens.MAIN )


func _on_settings_sub_back():
    _switch_to_screen( _Screens.SETTINGS )
