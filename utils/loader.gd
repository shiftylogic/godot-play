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

signal resource_error( err )
signal resource_started()
signal resource_progress( progress )
signal resource_ready( resource )


#########################################
#
# Constants
#

const ERROR_INVALID_STATE = "state of loader is invalid"
const ERROR_RESOURCE_NOT_EXIST = "requested resource does not exist"
const ERROR_RESOURCE_REQUEST_FAILED = "requested resource failed to queue"
const ERROR_RESOURCE_LOAD_FAILED = "requested resource failed to load"


#########################################
#
# Private variables
#

var _resource: String = ""
var _start: int


#########################################
#
# Overrides (_init, _ready, others)
#

func _process( _delta: float ) -> void:
    if _resource.is_empty():
        return

    var progress: Array[float] = []
    match ResourceLoader.load_threaded_get_status( _resource, progress ):
        ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
            print_debug( "Load status (invalid resource) [\"%s\"]" % _resource )
            resource_error.emit( ERROR_INVALID_STATE )
            _resource = ""
        ResourceLoader.THREAD_LOAD_IN_PROGRESS:
            # print_debug( "Load status (progress) [\"%s\"]" % _resource )
            resource_progress.emit( progress[0] )
        ResourceLoader.THREAD_LOAD_FAILED:
            print_debug( "Load status (resource load failed) [\"{}\"]" % _resource )
            resource_error.emit( ERROR_RESOURCE_LOAD_FAILED )
            _resource = ""
        ResourceLoader.THREAD_LOAD_LOADED:
            # print_debug( "Load status (complete) [\"%s\"]" % _resource )
            var resource = ResourceLoader.load_threaded_get( _resource )
            var dt: float = ( Time.get_ticks_msec() - _start ) / 1000.0
            resource_ready.emit( resource, dt )
            _resource = ""


#########################################
#
# Public methods
#

func load_resource( resource: String ) -> void:
    if not ResourceLoader.exists( resource ):
        print_debug( "Requested resource (\"%s\") does not exist." % resource )
        resource_error.emit( ERROR_RESOURCE_NOT_EXIST )
        return

    _start = Time.get_ticks_msec()
    var err = ResourceLoader.load_threaded_request( resource )
    if err != OK:
        print_debug( "Requested resource (\"%s\") failed to queue." % resource )
        resource_error.emit( ERROR_RESOURCE_REQUEST_FAILED )
        return

    _resource = resource
    resource_started.emit()
