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

extends StaticBody3D


#########################################
#
# Signals
#


#########################################
#
# Enums & Constants
#

const _NORMAL_MAT := preload( "res://scenes/play/normal.tres" )
const _HIGHLIGHT_MAT := preload( "res://scenes/play/highlight.tres" )


#########################################
#
# Exported properties
#


#########################################
#
# Private variables
#

@onready var _model: Node3D = $"Model/mergedBlocks(Clone)"


#########################################
#
# Overrides (_init, _ready, others)
#

func _ready():
    _model.material_override = _NORMAL_MAT
    pass


#########################################
#
# Public methods
#


#########################################
#
# Private methods
#


#########################################
#
# Event handlers
#

func _on_mouse_enter():
    _model.material_override = _HIGHLIGHT_MAT

func _on_mouse_exit():
    _model.material_override = _NORMAL_MAT
