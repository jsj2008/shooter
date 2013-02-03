attribute vec4 aPosition; // 1
//attribute vec4 SourceColor; // 2

varying vec4 DestinationColor; // 3
uniform mat4 uProjection;
uniform mat4 uModelview;

void main(void) { // 4
    //DestinationColor = Position/0.1;
    DestinationColor = vec4(1,0,1,1);
    gl_Position = uProjection * uModelview * aPosition;
    //gl_Position = Position;
}
