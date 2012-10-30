attribute vec4 pos;
attribute vec3 normal;
attribute vec2 texCoord;

uniform mat4 proj;
uniform mat4 view;
uniform mat4 model;
uniform vec3 lightPos;

varying vec2 fragTexCoord;
varying float fragDiffuse;

void main (void) {
    fragTexCoord = texCoord;
    mat4 modelView = view * model;
    vec4 transformed = modelView * pos;

    vec3 normal = mat3(modelView) * normal;
    vec3 lightDir = normalize(lightPos - vec3(transformed));
    fragDiffuse = min(1.0, max(dot(normal, lightDir), 0.1));

    gl_Position = proj * transformed;
}
