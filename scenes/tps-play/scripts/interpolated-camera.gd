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

#
# Derived from <https://github.com/godot-extended-libraries/godot-interpolated-camera3d>
# Copyright © 2020-present Hugo Locurcio and contributors - MIT License
#

extends Camera3D


#########################################
#
# Exported properties
#

# The factor to use for asymptotical translation lerping.
# If 0, the camera will stop moving. If 1, the camera will move instantly.
@export_range(0.0, 1.0, 0.001) var translate_speed: float = 0.95

# The factor to use for asymptotical rotation lerping.
# If 0, the camera will stop rotating. If 1, the camera will rotate instantly.
@export_range(0, 1, 0.001) var rotate_speed := 0.95

# The factor to use for asymptotical FOV lerping.
# If 0, the camera will stop changing its FOV. If 1, the camera will change its FOV instantly.
# Note: Only works if the target node is a Camera3D.
@export_range(0, 1, 0.001) var fov_speed := 0.95

# The factor to use for asymptotical Z near/far plane distance lerping.
# If 0, the camera will stop changing its Z near/far plane distance. If 1, the camera will do so instantly.
# Note: Only works if the target node is a Camera3D.
@export_range(0, 1, 0.001) var near_far_speed := 0.95

# The node to target.
# Can optionally be a Camera3D to support smooth FOV and Z near/far plane distance changes.
@export var target: Node3D


#########################################
#
# Overrides (_init, _ready, others)
#

func _process( dt: float ):
    if not target is Node3D:
        return

    var lt := get_global_transform()
    var tt := target.get_global_transform()
    var final_origin := Transform3D( Basis(), lt.origin ).interpolate_with( tt, translate_speed * dt * 10 )
    var final_basis := Transform3D( lt.basis, Vector3.ZERO ).interpolate_with( tt, rotate_speed * dt * 10 )
    set_global_transform( Transform3D( final_basis.basis, final_origin.origin ) )

    if not target is Camera3D:
        return

    var cam := target as  Camera3D
    if cam.projection != projection:
        return

    var nf_factor := near_far_speed * dt * 10
    var fov_factor := fov_speed * dt * 10
    var new_near: float = lerp( near, cam.near, nf_factor )
    var new_far: float = lerp( far, cam.far, nf_factor )

    match cam.projection:
        Camera3D.PROJECTION_ORTHOGONAL:
            var new_size: float = lerp( size, cam.size, fov_factor )
            set_orthogonal( new_size, new_near, new_far )
        Camera3D.PROJECTION_PERSPECTIVE:
            var new_fov: float = lerp( fov, cam.fov, fov_factor )
            set_perspective( new_fov, new_near, new_far )
