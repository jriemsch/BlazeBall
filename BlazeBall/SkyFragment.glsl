precision lowp float; 

varying vec2 fragTexCoord;

uniform sampler2D texture;

void main(void) {
    gl_FragColor = texture2D(texture, fragTexCoord);
}
