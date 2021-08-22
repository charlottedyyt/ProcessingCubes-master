//Controlled by yellow lines
class v2Window extends PApplet {
    v2Window() {
        super();
        PApplet.runSketch(new String[] {this.getClass().getSimpleName()} , this);
    }  
    void settings() {
        size(SCREEN_WIDTH, SCREEN_HEIGHT);
    }
    void setup()
    {
        surface.setSize(SCREEN_WIDTH, SCREEN_HEIGHT);    //set the size of the window
        surface.setLocation(0, SCREEN_HEIGHT);    //set the position of the window
        surface.setTitle("Live Platform 3");//Set the title of this window
        noCursor();
        colorMode(RGB);    
        fft = new FFT(audio.bufferSize(), audio.sampleRate());
    }
    void draw()
    {
        int HALF_WIDTH = floor(SCREEN_WIDTH / 2);
        if (stop8 != 1) {
            
            background(0);
            //fill(0);
            for (int i = HALF_WIDTH; i < SCREEN_WIDTH; i += 10) {
                int c = floor(map(i, 0, HALF_WIDTH, 0, 100));
                fill(0,0,0,0);
                stroke(255,255,255,c); 
                circle(HALF_WIDTH, SCREEN_HEIGHT / 2, fft.getBand(i - HALF_WIDTH) * 100);
            }
            for (int i = 0; i < HALF_WIDTH; i += 10)
            {      
                fill(0,0,0,0);
                int c = floor(map(i, 0, HALF_WIDTH, 0, 100));
                stroke(255,255,255,c); 
                //stroke(255, 255, 255, 100 + fft.getBand(i));
                circle(HALF_WIDTH, SCREEN_HEIGHT / 2, fft.getBand(HALF_WIDTH - i) * 100);
            }
        } 
    }
}
