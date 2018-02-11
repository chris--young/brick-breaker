precision mediump float;

uniform float v_brightnessA;
uniform float v_brightnessB;
uniform float v_brightnessC;
uniform float v_brightnessD;

varying vec3 v_distanceA;
varying vec3 v_distanceB;
varying vec3 v_distanceC;
varying vec3 v_distanceD;

varying vec3 v_normal;
varying vec4 v_color;

void main()
{
    vec3 normal = normalize(v_normal);

    vec3 distanceA = normalize(v_distanceA);
    float brightnessA = max(dot(v_normal, distanceA) * v_brightnessA, 0.0);
    vec4 diffuseA = vec4(v_color.rgb * brightnessA, v_color.a);
    
    vec3 distanceB = normalize(v_distanceB);
    float brightnessB = max(dot(v_normal, distanceB) * v_brightnessB, 0.0);
    vec4 diffuseB = vec4(v_color.rgb * brightnessB, v_color.a);
    
    vec3 distanceC = normalize(v_distanceC);
    float brightnessC = max(dot(v_normal, distanceC) * v_brightnessC, 0.0);
    vec4 diffuseC = vec4(v_color.rgb * brightnessC, v_color.a);
    
    vec3 distanceD = normalize(v_distanceD);
    float brightnessD = max(dot(v_normal, distanceD) * v_brightnessD, 0.0);
    vec4 diffuseD = vec4(v_color.rgb * brightnessD, v_color.a);
    
    gl_FragColor = diffuseA + diffuseB + diffuseC + diffuseD;
}
