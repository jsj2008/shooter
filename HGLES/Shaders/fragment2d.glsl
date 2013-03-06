precision mediump float;

// texture
uniform float uUseTexture;
uniform sampler2D uTex; // texture
uniform float uTextureRepeatNum;
uniform vec4 uBlendColor;

// alphamap
uniform float uUseAlphaMap;

// alpha
uniform float uAlpha;

// light
uniform float uUseLight;

// input
varying lowp vec4 vColor; // 1
varying vec2 vUV;

void main(void) { // 2
    // alpha map
    if (uUseAlphaMap > 0.0)
    {
        vec4 alphaMapColor = texture2D(uTex, vUV);
        float alpha = alphaMapColor.r;
        gl_FragColor = vec4(vColor.r, vColor.g, vColor.b, alpha);
    }
    // no light
    else
    {
        gl_FragColor = texture2D(uTex, vUV*uTextureRepeatNum) * vec4(uBlendColor.r, uBlendColor.g, uBlendColor.b, uAlpha);
    }
}
