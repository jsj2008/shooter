precision mediump float;

// texture
uniform sampler2D uTex; // texture
uniform float uUseTexture;

// input
varying lowp vec4 vColor; // 1
varying vec2 vUV;

void main(void) { // 2
    if (uUseTexture > 0.0)
    {
        gl_FragColor = texture2D(uTex, vUV) * vColor;
    }
    else
    {
        gl_FragColor = vColor; // 3
    }
}
