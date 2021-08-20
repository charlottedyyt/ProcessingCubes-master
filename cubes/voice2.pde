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
        //fullScreen();
        noCursor();
        colorMode(HSB);
        minim = new Minim(this); 
        input = minim.getLineIn(Minim.MONO);  
        fft = new FFT(input.bufferSize(), input.sampleRate());
    }
    void draw()
    {
        if (myPort.available() > 0) 
        {  // If data is available
            serialValue = myPort.read();
            if (signal8High == serialValue) {
                stop8 = 0;
            }
            else if (signal8Low == serialValue)
            {
                stop8 = 1;
            }
        }
        
        int HALF_WIDTH = floor(SCREEN_WIDTH/2);
        if (serialValue != -1 && stop8 != 1) {
            background(0);
            fill(0);
            for (int i = HALF_WIDTH; i > SCREEN_WIDTH; i --){
                stroke(255, 255, 255, 100 + fft.getBand(i));
                circle((i-HALF_WIDTH) * width / 1024 * 3, SCREEN_HEIGHT / 2, fft.getBand((i-HALF_WIDTH))*100);
            }
            for (int i = 0; i < HALF_WIDTH; i ++)
            {      
                stroke(255, 255, 255, 100 + fft.getBand(i));
                circle(i * width / 1024 * 3, SCREEN_HEIGHT / 2, fft.getBand(i));
            }
        } 
    }
}

