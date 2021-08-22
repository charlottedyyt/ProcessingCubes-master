import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.signals.*;
import processing.serial.*;

v1Window v1win;
v2Window v2win;
v3Window v3win;
Minim minim;
String source = "solo.mp3";
AudioPlayer audio;
FFT fft;
int[][] colo = new int[300][3];
// Variables which define the "zones" of the spectrum
// For example, for bass, we only take the first 4% of the total spectrum
float specLow = 0.03; // 3%
float specMid = 0.125;  // 12.5%
float specHi = 0.20;   // 20%

// So 64% of the possible spectrum remains that will not be used.
// These values ​​are generally too high for the human ear anyway.

// Score values ​​for each zone
float scoreLow = 0;
float scoreMid = 0;
float scoreHi = 0;

// Previous value, to soften the reduction
float oldScoreLow = scoreLow;
float oldScoreMid = scoreMid;
float oldScoreHi = scoreHi;

// Softening value
float scoreDecreaseRate = 25;


// Set up the size of the windows
static int SCREEN_WIDTH = 960*2;
static int SCREEN_HEIGHT = 1080;
//get the port values
//AudioIn in;
// Create object from Serial class
String val;     // Data received from the serial port
Serial myPort = new Serial(this, Serial.list()[4], 9600); //set up the port info
int signal6High = '6'; //the char printout to the serial if pin 7 is HIGH
int signal6Low = '1';//the char printout to the serial if pin 7 is LOW
int signal7High = '7'; //the char printout to the serial if pin 7 is HIGH
int signal7Low = '2';//the char printout to the serial if pin 7 is LOW
int signal8High = '8';//the char printout to the serial if pin 8 is HIGH
int signal8Low = '3';//the char printout to the serial if pin 8 is LOW
int signal9High = '9';//the char printout to the serial if pin 9 is HIGH
int signal9Low = '4';//the char printout to the serial if pin 9 is LOW
int stop6 = -1; //initialize to a closing state for pin 6
int stop7 = -1; //initialize to a closing state for pin 7
int stop8 = -1;//initialize to a closing state for pin 8
int stop9 = -1;//initialize to a closing state for pin 9
int serialValue = -1;//initialize to -1 means no message received from serial

//set the size of the windows
// public void settings() {
//     size(500,500,P3D);
// }

void setup()
{
    //size(500,500,P3D);
   fullScreen(P3D);
    //v1win = new v1Window();
    //v2win = new v2Window();
    //v3win = new v3Window();
    //surface.setSize(SCREEN_WIDTH, SCREEN_HEIGHT);    //set the size of the window
    surface.setLocation(0, 0);    //set the position of the window
    surface.setTitle("Live Platform 1");//Set the title of this window
    
    //Load the minim library
    minim = new Minim(this);
    
    //mic audio
    audio = minim.loadFile(source);
    
    //Create the FFT object to analyze the song
    fft = new FFT(audio.bufferSize(), audio.sampleRate());
    

    background(0);
    audio.play(0);
    audio.loop();
}
    void draw()
    {
        background(0);
        stroke(255); 
        fft.forward(audio.mix);
        //512 values below --> this loop is called 25 times per second
        //try getting the highest value and making a shape based on that value
        //maybe change color based on the size of the value?
        float HALF_WIDTH = SCREEN_WIDTH / 2;
        if (stop7 != 1)
            for (int i = 0; i < HALF_WIDTH; i += 8)
            {      
                int c = floor(map(i, 0, HALF_WIDTH, 100, 220));
                stroke(c);
            fill(0);
            ellipse(HALF_WIDTH - i, SCREEN_HEIGHT / 2, fft.getBand(i), fft.getBand(i + 10) * 150); 
            ellipse(HALF_WIDTH + i, SCREEN_HEIGHT / 2, fft.getBand(i), fft.getBand(i + 10) * 150); 
            
        } 
    }