precision mediump float; 

varying vec2 fragTexCoord;
varying float fragDiffuse;

uniform sampler2D texture;

void main(void) {
    vec4 color = texture2D(texture, fragTexCoord);
    gl_FragColor = vec4(color.x * fragDiffuse, color.y * fragDiffuse, color.z * fragDiffuse, color.w);
}
