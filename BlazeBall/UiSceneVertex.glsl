attribute vec4 pos;
attribute vec2 texCoord;

uniform mat4 model;

varying vec2 fragTexCoord;

void main (void) {
    fragTexCoord = texCoord;
    gl_Position = model * pos;
}
