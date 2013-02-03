attribute vec4 Position; // 1
//attribute vec4 SourceColor; // 2

varying vec4 DestinationColor; // 3
uniform mat4 Projection;
uniform mat4 Modelview;

void main(void) { // 4
    //DestinationColor = Position/0.1;
    DestinationColor = vec4(1,0,1,1);
    gl_Position = Projection * Modelview * Position;
    //gl_Position = Position;
}
