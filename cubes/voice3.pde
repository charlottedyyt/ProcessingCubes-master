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
        //fullScreen();
        noCursor();
        colorMode(HSB);
        minim = new Minim(this); 
        input = minim.getLineIn(Minim.MONO);  
        fft = new FFT(input.bufferSize(), input.sampleRate());
    }
    void draw()
    {
        background(0);
        stroke(255); 
        fft.forward(input.mix);
        if (myPort.available() > 0) 
        {  // If data is available
            serialValue = myPort.read();
            if (signal9High == serialValue) {
                stop9 = 0;
            }
            else if (signal9Low == serialValue)
            {
                stop9 = 1;
            }
        }
        float HALF_WIDTH = SCREEN_WIDTH / 2;
        if (serialValue != -1 && stop9 != 1)
            noStroke();
        for (int i = 150; i < HALF_WIDTH; i += 4)
            {      
            float x1 = (HALF_WIDTH - i);
            float y = SCREEN_HEIGHT / 2;
            float w = (HALF_WIDTH * 0.5) / HALF_WIDTH;
            float h = fft.getBand(i) * 200;
            ellipse(x1, y, w, h);
        } 
        for (int i = 150; i < HALF_WIDTH + 300; i += 4)
            {      
            int c = floor(map(i, HALF_WIDTH + 300, fft.specSize(), 25, 0));
            stroke(c,125,125);
     //         fill(0);
            float x2 = (HALF_WIDTH + i - 300);
            float y = SCREEN_HEIGHT / 2;
            float w = (HALF_WIDTH * 0.5) / HALF_WIDTH;
            float h = fft.getBand(i) * 250;
            ellipse(x2, y, w, h);
        } 
    }
}

