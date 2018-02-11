uniform mat4 u_perspective;

uniform vec3 u_scale;
uniform vec3 u_translation;
uniform vec3 u_rotation;

uniform vec3 u_lightA;
uniform vec3 u_lightB;
uniform vec3 u_lightC;
uniform vec3 u_lightD;

attribute vec3 a_shape;
attribute vec3 a_normal;
attribute vec4 a_color;

varying vec3 v_normal;
varying vec4 v_color;

varying vec3 v_distanceA;
varying vec3 v_distanceB;
varying vec3 v_distanceC;
varying vec3 v_distanceD;

mat4 scale(float x, float y, float z);
mat4 translate(float x, float y, float z);
mat4 rotate(float x, float y, float z);

void main()
{
    mat4 s = scale(u_scale.x, u_scale.y, u_scale.z);
    mat4 t = translate(u_translation.x, u_translation.y, u_translation.z);
    mat4 r = rotate(u_rotation.x, u_rotation.y, u_rotation.z);
    
    mat3 nt = mat3(translate(-u_translation.x, -u_translation.y, -u_translation.z));
    mat3 nr = mat3(rotate(-u_rotation.x, -u_rotation.y, -u_rotation.z));
    
    vec4 position = vec4(a_shape.xyz, 1.0) * s * r * t;
    
    v_color = a_color;
    v_normal = a_normal * mat3(r) * mat3(t);
    
    v_distanceA = u_lightA - (a_shape * mat3(s) * mat3(r) * mat3(t));
    v_distanceB = u_lightB - (a_shape * mat3(s) * mat3(r) * mat3(t));
    v_distanceC = u_lightC - (a_shape * mat3(s) * mat3(r) * mat3(t));
    v_distanceD = u_lightD - (a_shape * mat3(s) * mat3(r) * mat3(t));
    
    gl_Position = u_perspective * position;
}

mat4 scale(float x, float y, float z)
{
    return mat4(
        vec4(  x, 0.0, 0.0, 0.0),
        vec4(0.0,   y, 0.0, 0.0),
        vec4(0.0, 0.0,   z, 0.0),
        vec4(0.0, 0.0, 0.0, 1.0)
    );
}

mat4 translate(float x, float y, float z)
{
    return mat4(
        vec4(1.0, 0.0, 0.0,   x),
        vec4(0.0, 1.0, 0.0,   y),
        vec4(0.0, 0.0, 1.0,   z),
        vec4(0.0, 0.0, 0.0, 1.0)
    );
}

mat4 rotate_x(float a)
{
    float c = cos(a);
    float s = sin(a);
    
    return mat4(
        vec4(1.0, 0.0, 0.0, 0.0),
        vec4(0.0,   c,  -s, 0.0),
        vec4(0.0,   s,   c, 0.0),
        vec4(0.0, 0.0, 0.0, 1.0)
    );
}

mat4 rotate_y(float a)
{
    float c = cos(a);
    float s = sin(a);
    
    return mat4(
        vec4(  c, 0.0,   s, 0.0),
        vec4(0.0, 1.0, 0.0, 0.0),
        vec4( -s, 0.0,   c, 0.0),
        vec4(0.0, 0.0, 0.0, 1.0)
    );
}

mat4 rotate_z(float a)
{
    float c = cos(a);
    float s = sin(a);
    
    return mat4(
        vec4(  c,  -s, 0.0, 0.0),
        vec4(  s,   c, 0.0, 0.0),
        vec4(0.0, 0.0, 1.0, 0.0),
        vec4(0.0, 0.0, 0.0, 1.0)
    );
}

mat4 rotate(float x, float y, float z)
{
    return rotate_x(x) * rotate_y(y) * rotate_z(z);
}
