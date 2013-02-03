varying lowp vec4 DestinationColor; // 1

void main(void) { // 2
    gl_FragColor = DestinationColor; // 3
    //gl_FragColor = vec4(1,0,0,1); // 3
}
