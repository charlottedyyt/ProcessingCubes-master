class v1Window extends PApplet {
  v1Window() {
    super();
    PApplet.runSketch(new String[] {this.getClass().getSimpleName()}, this);
  }
void setup()
{
    size(800, 500);
    //fullScreen();
    noCursor();
    colorMode(HSB);
    minim = new Minim(this); 
    input = minim.getLineIn(Minim.MONO);  
    fft = new FFT(input.bufferSize(), input.sampleRate());
}
void draw()
{
    background(22,30,30);
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
    if(serialValue != -1 && stop7 != 1)
        for (int i = width / 2; i < fft.specSize(); i += 8)
        {      
        int c = floor(map(i, width / 2, fft.specSize(), 100, 220));
        stroke(c);
        fill(0);
        ellipse(i, 40, fft.getBand(i), fft.getBand(i) * 388); 
        ellipse(width - i, 40, fft.getBand(i), fft.getBand(i) * 400); 
        println(serialValue); //print it out in the console
    } 

}
}
