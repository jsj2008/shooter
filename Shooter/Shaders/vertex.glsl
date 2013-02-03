attribute vec4 aPosition;
attribute vec3 aNormal;

varying vec4 DestinationColor; // fragment color

uniform vec4 uLightAmbient; // environment light color
uniform vec4 uLightDiffuse; // diffuse light color
uniform vec4 uLightSpecular; // specular light color
uniform vec3 uLightPos; // light position

uniform mat4 uPMatrix; // projection
uniform mat4 uMMatrix; // modelview
uniform mat4 uNormalMatrix; // gyakutenti

void main(void) { // 4

    // environment
    vec4 ambient = uLightAmbient*vec4(1.8,0.1,0.1,1.0); // fixme

    // diffuse
    vec3 P = vec3(uMMatrix*aPosition);
    vec3 L = normalize(uLightPos - P); // fixme
    vec3 N = normalize(mat3(uNormalMatrix)*aNormal);
    vec4 diffuseP = vec4(max(dot(L,N), 0.0));
    vec4 diffuse = diffuseP*uLightDiffuse*vec4(0.8,0.5,0.1,1.0); // fixme

    // specular
    vec3 S = normalize(L+vec3(0.0, 0.0, 1.0));
    float specularP = pow(max(dot(N,S), 0.0), 5.5); // fixme
    vec4 specular = specularP*uLightSpecular*1.5; // fixme
    
    DestinationColor = ambient+diffuse+specular;
    //DestinationColor = diffuse+specular;
    //DestinationColor = vec4(vec3(aNormal.x, aPosition.y, aNormal.z)*10.0, 1.0);
    //DestinationColor = vec4(aNormal, 1.0);

    gl_Position = uPMatrix * uMMatrix * aPosition;
}
