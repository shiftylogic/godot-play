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
# Enums & Constants
#

const GRAPH_BG_COLOR := Color(0.0, 0.0, 0.0, 0.5)
const GRAPH_COLOR := Color.BLUE
const GRAPH_FONT := preload("res://addons/sl-debug/fira_sans_regular.ttf")
const GRAPH_HEIGHT := 75
const VISIBLE_SAMPLES := 100



#########################################
#
# Private variables
#

var _monitor: Performance.Monitor
var _title: String
var _units: String

var _index := 0
var _min_value := 0.0
var _max_value := 1.0
var _value: float
var _values: Array[float]



#########################################
#
# Overrides (_init, _ready, others)
#

func _init(title: String, monitor: Performance.Monitor, units: String):
    _monitor = monitor
    _title = title
    _units = units

    _values.resize(VISIBLE_SAMPLES)
    _values.fill(0.0)

    custom_minimum_size.y = GRAPH_HEIGHT


func _process(_delta: float) -> void:
    queue_redraw()


func _draw() -> void:
    _sample_monitor()
    _render()



#########################################
#
# Private methods
#

func _render() -> void:
    var text := _title + " - " + _scaled_value(_value)
    var pos := get_canvas_transform().origin
    var rect := Rect2()

    # Render background
    rect.position = pos
    rect.size = size
    draw_rect(rect, GRAPH_BG_COLOR)

    # Render current value as text
    pos.y += 16.0
    draw_string(GRAPH_FONT, pos, text)

    # Render the graph
    var h := size.y
    var ostart := h / 10.0
    var ostop := h - ostart
    var offset := size.x / VISIBLE_SAMPLES

    var p1 := Vector2.ZERO
    var p2 := Vector2.ZERO
    var x := 0.0

    for i in range(_index, VISIBLE_SAMPLES):
        var v = remap(_values[i], _min_value, _max_value, ostart, ostop)
        p2 = Vector2(x, h - v) + pos
        draw_line(p1, p2, GRAPH_COLOR)
        p1 = p2
        x += offset
    for i in range(0, _index):
        var v = remap(_values[i], _min_value, _max_value, ostart, ostop)
        p2 = Vector2(x, h - v) + pos
        draw_line(p1, p2, GRAPH_COLOR)
        p1 = p2
        x += offset


func _sample_monitor() -> void:
    _value = Performance.get_monitor(_monitor)
    _values[_index] = _value
    _index = (_index + 1) % VISIBLE_SAMPLES

    _min_value = minf(_value, _min_value)
    _max_value = maxf(_value, _max_value)


func _scaled_value(v: float) -> String:
    if v > 1000.0:
        const scales = ["K", "M", "G", "T"]
        var i = -1
        while v > 1000.0 and i < 3:
            v /= 1000.0
            i += 1
        return str(snapped(v, 0.001)) + scales[i] + _units

    if v > 0.0 and v < 1.0:
        const scales = ["m", "u", "n"]
        var i = -1
        while v < 1.0 and i < 2:
            v *= 1000.0
            i += 1
        return str(snapped(v, 0.001)) + scales[i] + _units

    return str(v) + _units
