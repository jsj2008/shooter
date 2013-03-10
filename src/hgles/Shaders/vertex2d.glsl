precision mediump float;

attribute vec4 aPosition;
attribute vec3 aNormal;
attribute vec2 aUV;

// light
uniform float uUseLight;
uniform vec4 uLightAmbient;
uniform vec4 uLightDiffuse;
uniform vec4 uLightSpecular;
uniform vec3 uLightPos;

// material
uniform vec4 uMaterialAmbient;
uniform vec4 uMaterialDiffuse;
uniform vec4 uMaterialSpecular;
uniform float uMaterialShininess;

//uniform mat4 uPMatrix; // projection
uniform mat4 uMMatrix; // modelview
uniform mat4 uMvpMatrix; // model*view*projection matrix
uniform mat4 uNormalMatrix; // gyakutenti

// texture matrix
uniform mat4 uTexMatrix;
uniform float uUseTexture;

// color
uniform vec4 uColor;

// output
varying vec4 vColor;
varying vec2 vUV;

void main(void) {

    gl_Position = uMvpMatrix * aPosition;
    //gl_Position = aPosition * uMvpMatrix;
    // UV
    if (uUseTexture > 0.0)
    {
        vUV = vec2(uTexMatrix*vec4(aUV, 0.0, 1.0));
    }
    vColor = uColor;

}
