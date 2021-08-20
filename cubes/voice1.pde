class v1Window extends PApplet {
    v1Window() {
        super();
        PApplet.runSketch(new String[] {this.getClass().getSimpleName()}, this);
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
        //512 values below --> this loop is called 25 times per second
        //try getting the highest value and making a shape based on that value
        //maybe change color based on the size of the value?
        if (myPort.available() > 0) 
        {  // If data is available
            serialValue = myPort.read();
            if(signal7High == serialValue){
                stop7 = 0;
            }
            else if(signal7Low == serialValue)
            {
                stop7 = 1;
            }
        }
        float HALF_WIDTH = SCREEN_WIDTH/2;
        if(serialValue != -1 && stop7 != 1)
            for (int i = 0; i < HALF_WIDTH; i += 8)
            {      
            int c = floor(map(i, 0, HALF_WIDTH, 100, 220));
            stroke(c);
            fill(0);
            ellipse(HALF_WIDTH - i, SCREEN_HEIGHT/2, fft.getBand(i), fft.getBand(i + 10) * 150); 
            ellipse(HALF_WIDTH + i, SCREEN_HEIGHT/2, fft.getBand(i), fft.getBand(i + 10) * 150); 
            println(serialValue-'0'); //print it out in the console
        } 
    }
}
