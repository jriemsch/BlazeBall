attribute vec4 pos;
attribute vec2 texCoord;

varying vec2 fragTexCoord;

void main (void) {
    fragTexCoord = texCoord;
    gl_Position = vec4(pos.y * 2.0, -pos.x * 2.0, pos.z, pos.w);
}
