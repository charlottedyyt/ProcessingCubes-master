import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.signals.*;
import processing.serial.*;

v1Window v1win;
v2Window v2win;
v3Window v3win;
Minim minim;
AudioPlayer jingle;
AudioInput input;
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

// Cubes that appear in space
int nbCubes;
Cube[] cubes;

// Lines that appear on the sides
int nbMurs = 500;
Mur[] murs;

// Set up the size of the windows
static int SCREEN_WIDTH = 960;
static int SCREEN_HEIGHT = 510;
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
int stop6 = 1; //initialize to a closing state for pin 6
int stop7 = 1; //initialize to a closing state for pin 7
int stop8 = 1;//initialize to a closing state for pin 8
int stop9 = 1;//initialize to a closing state for pin 9
int serialValue = -1;//initialize to -1 means no message received from serial

//set the size of the windows
// public void settings() {
//     size(500,500,P3D);
// }

void setup()
{
    size(500,500,P3D);
    v1win = new v1Window();
    v2win = new v2Window();
    v3win = new v3Window();
    surface.setSize(SCREEN_WIDTH, SCREEN_HEIGHT);    //set the size of the window
    surface.setLocation(0, 0);    //set the position of the window
    surface.setTitle("Live Platform 1");//Set the title of this window
    
    //Load the minim library
    minim = new Minim(this);
    
    //mic input
    input = minim.getLineIn(Minim.MONO);
    
    //Create the FFT object to analyze the song
    fft = new FFT(input.bufferSize(), input.sampleRate());
    
    //One cube per frequency band
    nbCubes = (int)(fft.specSize() * specHi);
    cubes = new Cube[nbCubes];
    
    //Asmany walls as we want
    murs = new Mur[nbMurs];
    //Create all the objects
    //Create the cube objects
    for (int i = 0; i < nbCubes; i++) {
        	cubes[i] = new Cube(); 
    }
    
    //Create the wall objects
    //Left walls
    for (int i = 0; i < nbMurs; i += 4) {
        	murs[i] = new Mur(0, height / 2, 10, height); 
    }
    //Straight walls
    for (int i = 1; i < nbMurs; i += 4) {
        	murs[i] = new Mur(width, height / 2, 10, height); 
    }
    //Low walls
    for (int i = 2; i < nbMurs; i += 4) {
        	murs[i] = new Mur(width / 2, height, width, 10); 
    }
    //High walls
    for (int i = 3; i < nbMurs; i += 4) {
        	murs[i] = new Mur(width / 2, 0, width, 10); 
    }
    // Black background
    background(0);
}
void draw()
{
    
    if (myPort.available() > 0) 
    {  // If data is available
        serialValue = myPort.read();
        if (signal6High == serialValue) {
            stop6 = 0;
        }
        else if (signal6Low == serialValue)
        {
            stop6 = 1;
        }
        if (signal7High == serialValue) {
            stop7 = 0;
        }
        else if (signal7Low == serialValue)
        {
            stop7 = 1;
        }        
        if (signal8High == serialValue) {
            stop8 = 0;
        }
        else if (signal8Low == serialValue)
        {
            stop8 = 1;
        }    
        if (signal9High == serialValue) {
            stop9 = 0;
        }
        else if (signal9Low == serialValue)
        {
            stop9 = 1;
        }
    }
    if (stop6 != 1) {
        // Advance the mic input. We draw() for each "frame" of the input...
        fft.forward(input.mix);
        // Calculation of the"scores"(power) for three categories of sound
        //First, save the old values
        oldScoreLow = scoreLow;
        oldScoreMid = scoreMid;
        oldScoreHi = scoreHi;
        //Resetthe values
        scoreLow = 0;
        scoreMid = 0;
        scoreHi = 0;
        //Calculate the new "scores"
        for (int i = 0; i < fft.specSize() * specLow; i++)
            {
            	scoreLow += fft.getBand(i);
        }
        
        for (int i = (int)(fft.specSize() * specLow); i < fft.specSize() * specMid; i++)
        {
            scoreMid += fft.getBand(i);
        }
        
        for (int i = (int)(fft.specSize() * specMid); i < fft.specSize() * specHi; i++)
        {
            scoreHi += fft.getBand(i);
        }
        //Slow down the descent.
        if (oldScoreLow > scoreLow) {
            scoreLow = oldScoreLow - scoreDecreaseRate;
        }
        
        if (oldScoreMid > scoreMid) {
            scoreMid = oldScoreMid - scoreDecreaseRate;
        }
        
        if (oldScoreHi > scoreHi) {
            scoreHi = oldScoreHi - scoreDecreaseRate;
        }
        //Volume for all frequencies at thistime, with higher sounds more prominent.
        //This allows the animation to go fasterfor higher pitched sounds, which are more noticeable
        float scoreGlobal = 0.66 * scoreLow + 0.8 * scoreMid + 1 * scoreHi;
        //Subtle background color
        background(scoreLow / 100, scoreMid / 100, scoreHi / 100);
        //Cube for each frequency band
        for (int i = 0; i < nbCubes; i++)
        {
            	// Value of the frequency band
            float bandValue = fft.getBand(i);
            	// Thecolor is represented as : red for bass,green for mid sounds, and blue for highs.
            	// Theopacity is determined by the volume of the tape andthe overall volume.
            cubes[i].display(scoreLow, scoreMid, scoreHi, bandValue,scoreGlobal);
        }
        //Line walls, here you have to keepthe valueof the previous strip and the next one to connect them together
        float previousBandValue = fft.getBand(0);
        
        //Distance between each line point,negative because on dimension z
        float dist = -25;
        
        //Multiply the height by this constant
        float heightMult = 2;
        //For each band
        for (int i = 1; i < fft.specSize(); i++)
        {
            	// Valueof the frequency band, we multiply the bands further away so that they are more visible.
            float bandValue = fft.getBand(i) * (1 + (i / 50));
            	// Select the color according to the strengths of the different types of sounds
            stroke(100 + scoreLow, 100 + scoreMid, 100 + scoreHi, 255 - i);
            strokeWeight(1 + (scoreGlobal / 100));
            	// lower left line
            line(0, height - (previousBandValue * heightMult), dist * (i - 1), 0, height - (bandValue * heightMult), dist * i);
            line((previousBandValue * heightMult), height, dist * (i - 1),(bandValue * heightMult), height, dist * i);
            line(0, height - (previousBandValue * heightMult), dist * (i - 1),(bandValue * heightMult), height, dist * i);
            
            	// topleft line
            line(0,(previousBandValue * heightMult),dist * (i - 1), 0,(bandValue * heightMult), dist * i);
            line((previousBandValue * heightMult), 0, dist * (i - 1),(bandValue * heightMult), 0, dist * i);
            line(0,(previousBandValue * heightMult),dist * (i - 1),(bandValue * heightMult), 0, dist * i);
            
            // lowerright line
            line(width, height - (previousBandValue * heightMult), dist * (i - 1), width, height - (bandValue * heightMult), dist * i);
            line(width - (previousBandValue * heightMult), height, dist * (i - 1), width - (bandValue * heightMult), height, dist * i);
            line(width, height - (previousBandValue * heightMult), dist * (i - 1), width - (bandValue * heightMult), height, dist * i);
            // upper right line
            line(width,(previousBandValue * heightMult), dist * (i - 1), width,(bandValue * heightMult), dist * i);
            line(width - (previousBandValue * heightMult), 0, dist * (i - 1), width - (bandValue * heightMult), 0, dist * i);
            line(width,(previousBandValue * heightMult), dist * (i - 1), width - (bandValue * heightMult), 0, dist * i);

            // Save the value for the next loop round
            previousBandValue = bandValue;
            
        }
        //Rectangular walls
        for (int i = 0; i < nbMurs; i++)
        {// Weassign each wall a band, and we send its strength.
            float intensity = fft.getBand(i % ((int)(fft.specSize() * specHi)));
            murs[i].display(scoreLow, scoreMid, scoreHi, intensity, scoreGlobal);
        }
    }
    int sig = serialValue-'0';
    if(sig > 0 && sig < 10)
      println(sig); //print it out in the console
}
// Classfor the cubes which float in space
class Cube {
    //Z position of "spawn" and maximum Z position
    float startingZ = -10000;
    float maxZ = 1000;
    //Position values
    float x, y,z;
    float rotX,rotY, rotZ;
    float sumRotX, sumRotY, sumRotZ;
    //Constructor
    Cube() {
        //Make the cube appear at a random location
        x = random(0, width);
        y = random(0, height);
        z = random(startingZ, maxZ);
        //Give the cube a random rotation
        rotX= random(0, 1);
        rotY= random(0, 1);
        rotZ= random(0, 1);
}
    void display(float scoreLow, float scoreMid, float scoreHi, float intensity, float scoreGlobal) {  
        //Select the color, opacity determined bythe intensity(volume of the band)
        color displayColor = color(scoreLow * 0.67, scoreMid * 0.67, scoreHi * 0.67, intensity * 5);
        fill(displayColor, 255);
        
        //Line color, they disappear with the individual intensity of the cube
        color strokeColor = color(255, 150 - (20 * intensity));
        stroke(strokeColor);
        strokeWeight(1 + (scoreGlobal / 300));
        //Create a transformation matrix to perform rotations, enlargements
        pushMatrix();
        //Shift
        translate(x, y, z);
        //Calculatethe rotation according to theintensity for the cube
        sumRotX += intensity * (rotX / 1000);
        sumRotY += intensity * (rotY / 1000);
        sumRotZ += intensity * (rotZ / 1000);
        //Apply therotation
        rotateX(sumRotX);
        rotateY(sumRotY);
        rotateZ(sumRotZ);
        //Creation of the box, variable size according to the intensity for the cube
        box(100 + (intensity / 2));
        //Apply thematrix
        popMatrix();
        //Zdisplacement
        z +=(1 + (intensity / 5) + (pow((scoreGlobal / 150), 2)));
        //Replace the box at the back when it is no longer visible
        if (z >= maxZ) {
            x = random(0, width);
            y = random(0, height);
            z = startingZ;
        }
}
}

// Class to display the lines on the sides
class Mur {
    //Minimum and maximum position Z
    float startingZ= -10000;
    float maxZ = 50;
    //Position values
    float x, y, z;
    float sizeX, sizeY;
    
    //Constructor 
    Mur(float x, float y, float sizeX, float sizeY) {
        //Make the lineappear at the specified location
        this.x = x;
        this.y = y;
        //Random depth
        this.z = random(startingZ, maxZ);  
        
        
        //We determine the size because the walls on the floors have a different size than those on the sides   this.sizeX = sizeX;
        this.sizeY = sizeY;
    }
    //Display function
    void display(float scoreLow, float scoreMid, float scoreHi, float intensity, float scoreGlobal) {
        //Color determined by low, medium and high sounds
        //Opacity determined by the overall volume
        color displayColor = color(scoreLow * 0.67, scoreMid * 0.67,scoreHi * 0.67, scoreGlobal);
        //Make the lines disappear in the distance to give anillusion of fog
        fill(displayColor,((scoreGlobal - 5) / 1000) * (255 + (z / 25)));
        noStroke();
        
        //Firstband, the one that moves according to the force
        //Transformation matrix
        pushMatrix();
        
        //Shift
        translate(x, y,z);
        //Expansion
        if (intensity > 100) intensity = 100;
        scale(sizeX * (intensity / 100), sizeY * (intensity / 100), 20);
        
        //Create the "box"
        box(1);
        popMatrix();
        
        //Second band, the one that is always the same size
        displayColor = color(scoreLow * 0.5, scoreMid * 0.5, scoreHi * 0.5, scoreGlobal);
        fill(displayColor,(scoreGlobal / 5000) * (255 + (z / 25)));
        
        //Transformation matrix
        pushMatrix();
        //Shift
        translate(x, y,z);
        //Expansion
        scale(sizeX, sizeY, 10);
        
        //Create the "box"
        box(1);
        popMatrix();
        //Z displacement
        z += (pow((scoreGlobal / 150), 2));
        if (z >= maxZ) {
            z = startingZ; 
        }
    } 
}