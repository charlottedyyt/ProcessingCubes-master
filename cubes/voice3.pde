class v3Window extends PApplet {
    v3Window() {
        super();
        PApplet.runSketch(new String[] {this.getClass().getSimpleName()} , this);
    }  
    void settings() {
        size(SCREEN_WIDTH, SCREEN_HEIGHT);
    }
    void setup()
    {
        surface.setSize(SCREEN_WIDTH, SCREEN_HEIGHT);    //set the size of the window
        surface.setLocation(SCREEN_WIDTH, SCREEN_HEIGHT);    //set the position of the window
        surface.setTitle("Live Platform 1");//Set the title of this window
        noCursor();
        colorMode(HSB);    
        fft = new FFT(audio.bufferSize(), audio.sampleRate());
    }
    void draw()
    {
        background(0);
        stroke(255); 
        fft.forward(audio.mix);
        float HALF_WIDTH = SCREEN_WIDTH / 2;
        if (stop9 != 1) {
            for (int i = 150; i < HALF_WIDTH; i += 4)
            {     
                int c = floor(map(i, 0, HALF_WIDTH, 100, 220));
                stroke(c); 
                float x1 = (HALF_WIDTH - i);
                float y = SCREEN_HEIGHT / 2;
                float w = (HALF_WIDTH * 0.5) / HALF_WIDTH;
                float h = fft.getBand(i) * 200;
                ellipse(x1, y, w, h);
            } 
            for (int i = 150; i < HALF_WIDTH + 300; i += 4)
            {      
                int c = floor(map(i, HALF_WIDTH + 300, fft.specSize(), 20, 0));
                stroke(c,180,125);
            //      fill(0);
                float x2 = (HALF_WIDTH + i - 300);
                float y = SCREEN_HEIGHT / 2;
                float w = (HALF_WIDTH * 0.5) / HALF_WIDTH;
                float h = fft.getBand(i) * 250;
                ellipse(x2, y, w, h);
            } 
        }
    }
}
