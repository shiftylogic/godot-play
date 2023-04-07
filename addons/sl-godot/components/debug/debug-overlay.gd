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

extends VBoxContainer
class_name DebugOverlay


#########################################
#
# Constants
#

const _DebugGraph := preload( "./debug-graph.gd" )



#########################################
#
# Overrides (_init, _ready, others)
#

func _ready() -> void:
    _add_graph( "FPS", Performance.TIME_FPS )
    _add_graph( "Frame Time", Performance.TIME_PROCESS, "s" )
    _add_graph( "Buffer Memory", Performance.RENDER_BUFFER_MEM_USED, "B" )
    _add_graph( "Texture Memory", Performance.RENDER_TEXTURE_MEM_USED, "B" )
    _add_graph( "Video Memory", Performance.RENDER_VIDEO_MEM_USED, "B" )
    _add_graph( "Static Memory", Performance.MEMORY_STATIC, "B" )
    _add_graph( "Draw Calls", Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME )
    _add_graph( "Objects", Performance.OBJECT_COUNT )
    _add_graph( "Nodes", Performance.OBJECT_NODE_COUNT )



#########################################
#
# Private methods
#

func _add_graph( title: String, monitor: Performance.Monitor, units: String= "" ) -> void:
    add_child( _DebugGraph.new( title, monitor, units ) )
