attribute vec4 aPosition; // 1
//attribute vec4 SourceColor; // 2

varying vec4 DestinationColor; // 3
uniform mat4 uPMatrix;
uniform mat4 uMMatrix;

void main(void) { // 4
    DestinationColor = vec4(1,0,1,1);
    gl_Position = uPMatrix * uMMatrix * aPosition;
}
