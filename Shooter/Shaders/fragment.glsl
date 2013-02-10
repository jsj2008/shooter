precision mediump float;

// texture
uniform sampler2D uTex; // texture

// input
varying lowp vec4 DestinationColor; // 1
varying vec2 vUV;

void main(void) { // 2
    //gl_FragColor = DestinationColor; // 3
    gl_FragColor = texture2D(uTex, vUV) * DestinationColor;
}
