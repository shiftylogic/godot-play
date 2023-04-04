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
class_name ChessSquare


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


#########################################
#
# Exported properties
#

@export var NormalMaterial: Material
@export var HighlightMaterial: Material


#########################################
#
# Private variables
#

@onready var _model: MeshInstance3D = $Model


#########################################
#
# Overrides (_init, _ready, others)
#

func _ready():
    _model.material_override = NormalMaterial
    _model.scale = Vector3(0, 1, 0)

    var t := create_tween()
    t.tween_property(
        _model,
        "scale",
        Vector3.ONE,
        0.25
    )


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


