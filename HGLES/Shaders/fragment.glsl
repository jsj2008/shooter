precision mediump float;

// texture
uniform sampler2D uTex; // texture
uniform float uUseTexture;

// alpha
uniform float uAlpha;

// light
uniform float uUseLight;

// input
varying lowp vec4 vColor; // 1
varying vec2 vUV;

void main(void) { // 2
    if (uUseTexture > 0.0)
    {
        if (uUseLight > 0.0)
        {
            gl_FragColor = texture2D(uTex, vUV) * vColor * vec4(1.0, 1.0, 1.0, uAlpha);
        }
        else
        {
            gl_FragColor = texture2D(uTex, vUV) * vec4(1.0, 1.0, 1.0, uAlpha);
        }
    }
    else
    {
        gl_FragColor = vColor; // 3
    }
}
