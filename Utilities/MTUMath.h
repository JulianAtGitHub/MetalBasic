/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Header for vector, matrix, and quaternion math utility functions useful for 3D graphics
 rendering with Metal
*/

#ifndef _MTU_MATH_H_
#define _MTU_MATH_H_

#include <simd/simd.h>

#ifdef __cplusplus
extern "C" {
#endif

#define MATH_FUNC_OVERLOAD __attribute__((__overloadable__))

/// A single-precision quaternion type
typedef vector_float4 quaternion_float;

/// Returns the number of degrees in the specified number of radians
float MATH_FUNC_OVERLOAD degrees_from_radians(float radians);

/// Returns the number of radians in the specified number of degrees
float MATH_FUNC_OVERLOAD radians_from_degrees(float degrees);

/// Returns a vector that is linearly interpolated between the two provided vectors
vector_float3 MATH_FUNC_OVERLOAD vector_lerp(vector_float3 v0, vector_float3 v1, float t);

/// Returns a vector that is linearly interpolated between the two provided vectors
vector_float4 MATH_FUNC_OVERLOAD vector_lerp(vector_float4 v0, vector_float4 v1, float t);

/// Converts a unit-norm quaternion into its corresponding rotation matrix
matrix_float3x3 MATH_FUNC_OVERLOAD matrix3x3_from_quaternion(quaternion_float q);

/// Constructs a rotation matrix from the provided angle and axis
matrix_float3x3 MATH_FUNC_OVERLOAD matrix3x3_rotation(float radians, vector_float3 axis);

/// Constructs a rotation matrix from the provided angle and the axis (x, y, z)
matrix_float3x3 MATH_FUNC_OVERLOAD matrix3x3_rotation(float radians, float x, float y, float z);

/// Constructs a scaling matrix with the specified scaling factors
matrix_float3x3 MATH_FUNC_OVERLOAD matrix3x3_scale(float x, float y, float z);

/// Constructs a scaling matrix, using the provided vector as an array of scaling factors
matrix_float3x3 MATH_FUNC_OVERLOAD matrix3x3_scale(vector_float3 s);

/// Extracts the upper-left 3x3 submatrix of the provided 4x4 matrix
matrix_float3x3 MATH_FUNC_OVERLOAD matrix3x3_upper_left(matrix_float4x4 m);

/// Returns the inverse of the transpose of the provided matrix
matrix_float3x3 MATH_FUNC_OVERLOAD matrix_inverse_transpose(matrix_float3x3 m);

/// Constructs a (homogeneous) rotation matrix from the provided angle and axis
matrix_float4x4 MATH_FUNC_OVERLOAD matrix4x4_from_quaternion(quaternion_float q);

/// Constructs a rotation matrix from the provided angle and axis
matrix_float4x4 MATH_FUNC_OVERLOAD matrix4x4_rotation(float radians, vector_float3 axis);

/// Constructs a rotation matrix from the provided angle and the axis (x, y, z)
matrix_float4x4 MATH_FUNC_OVERLOAD matrix4x4_rotation(float radians, float x, float y, float z);

/// Constructs a scaling matrix with the specified scaling factors
matrix_float4x4 MATH_FUNC_OVERLOAD matrix4x4_scale(float sx, float sy, float sz);

/// Constructs a scaling matrix, using the provided vector as an array of scaling factors
matrix_float4x4 MATH_FUNC_OVERLOAD matrix4x4_scale(vector_float3 s);

/// Constructs a translation matrix that translates by the vector (tx, ty, tz)
matrix_float4x4 MATH_FUNC_OVERLOAD matrix4x4_translation(float tx, float ty, float tz);

/// Constructs a translation matrix that translates by the vector (t.x, t.y, t.z)
matrix_float4x4 MATH_FUNC_OVERLOAD matrix4x4_translation(vector_float3 t);

/// Constructs a view matrix for a right-handed coordinate system 
/// that is positioned at eye and looks at target, with up vector pointing up
matrix_float4x4 MATH_FUNC_OVERLOAD matrix_look_at_right_hand(vector_float3 eye, vector_float3 target, vector_float3 up);

/// Constructs a view matrix for a left-handed coordinate system 
/// that is positioned at eye and looks at target, with up vector pointing up
matrix_float4x4 MATH_FUNC_OVERLOAD matrix_look_at_left_hand(vector_float3 eye, vector_float3 target, vector_float3 up);

/// Constructs a symmetric orthographic projection matrix for a right-handed coordinate system 
/// that maps (left, top) to (-1, 1), (right, bottom) to (1, -1), and (nearZ, farZ) to (0, 1)
matrix_float4x4 MATH_FUNC_OVERLOAD matrix_ortho_right_hand(float left, float right, float bottom, float top, float nearZ, float farZ);

/// Constructs a symmetric orthographic projection matrix for a left-handed coordinate system 
/// that maps (left, top) to (-1, 1), (right, bottom) to (1, -1), and (nearZ, farZ) to (0, 1)
matrix_float4x4 MATH_FUNC_OVERLOAD matrix_ortho_left_hand(float left, float right, float bottom, float top, float nearZ, float farZ);

/// Constructs a symmetric perspective projection matrix for a right-handed coordinate system
/// with a vertical viewing angle of fovyRadians, the specified aspect ratio, and the provided near
/// and far Z distances
matrix_float4x4  MATH_FUNC_OVERLOAD matrix_perspective_right_hand(float fovyRadians, float aspect, float nearZ, float farZ);

/// Constructs a symmetric perspective projection matrix for a left-handed coordinate system
/// with a vertical viewing angle of fovyRadians, the specified aspect ratio, and the provided near
/// and far Z distances
matrix_float4x4 MATH_FUNC_OVERLOAD matrix_perspective_left_hand(float fovyRadians, float aspect, float nearZ, float farZ);

/// Returns the inverse of the transpose of the provided matrix
matrix_float4x4 MATH_FUNC_OVERLOAD matrix_inverse_transpose(matrix_float4x4 m);

/// Constructs a quaternion of the form w + xi + yj + zk
quaternion_float MATH_FUNC_OVERLOAD quaternion(float x, float y, float z, float w);

/// Constructs a quaternion of the form w + v.x*i + v.y*j + v.z*k
quaternion_float MATH_FUNC_OVERLOAD quaternion(vector_float3 v, float w);

/// Constructs a unit-norm quaternion that represents rotation by the specified angle about the specified axis
quaternion_float MATH_FUNC_OVERLOAD quaternion(float radians, vector_float3 axis);

/// Constructs a unit-norm quaternion from the provided matrix.
/// The result is undefined if the matrix does not represent a pure rotation.
quaternion_float MATH_FUNC_OVERLOAD quaternion(matrix_float3x3 m);

/// Constructs a unit-norm quaternion from the provided matrix.
/// The result is undefined if the matrix does not represent a pure rotation.
quaternion_float MATH_FUNC_OVERLOAD quaternion(matrix_float4x4 m);

/// Returns the length of the specified quaternion
float quaternion_length(quaternion_float q);

/// Returns the rotation axis of the specified unit-norm quaternion
vector_float3 quaternion_axis(quaternion_float q);

/// Returns the rotation angle of the specified unit-norm quaternion
float quaternion_angle(quaternion_float q);

/// Returns a unit-norm quaternion
quaternion_float quaternion_normalize(quaternion_float q);

/// Returns the inverse quaternion of the provided quaternion
quaternion_float quaternion_inverse(quaternion_float q);

/// Returns the conjugate quaternion of the provided quaternion
quaternion_float quaternion_conjugate(quaternion_float q);

/// Returns the product of two quaternions
quaternion_float quaternion_multiply(quaternion_float q0, quaternion_float q1);

/// Returns the quaternion that results from spherically interpolating between the two provided quaternions
quaternion_float quaternion_slerp(quaternion_float q0, quaternion_float q1, float t);

/// Returns the vector that results from rotating the provided vector by the provided unit-norm quaternion
vector_float3 quaternion_rotate_vector(quaternion_float q, vector_float3 v);

#ifdef __cplusplus
}
#endif

#endif // _MTU_MATH_H_

