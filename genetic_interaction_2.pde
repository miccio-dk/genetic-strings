import ddf.minim.*;
import ddf.minim.ugens.*;
import peasy.*;


Vect3D vect3D0 = new Vect3D(0., 0., 0.);

private Object lock = new Object();
PeasyCam cam;

PhyUGen simUGen;
Minim minim;
AudioOutput out;
AudioRecorder recorder;
Gain gain;
float currAudio = 0;


void setup()
{
  size(800, 800, P3D);
  //fullScreen(P3D,2);
  cam = new PeasyCam(this, 1000);
  cam.setDistance(2500);
  cam.setActive(false);
  //ortho(-width/2,width/2,-height/2,height/2,-200,200);
  
  minim = new Minim(this);
  
  // use the getLineOut method of the Minim object to get an AudioOutput object
  out = minim.getLineOut();
  
  recorder = minim.createRecorder(out, "myrecording.wav");
  
  // start the Gain at 0 dB, which means no change in amplitude
  gain = new Gain(0);
  
  // create a physicalModel UGEN
  simUGen = new PhyUGen(this, 44100);
  // patch the Oscil to the output
  simUGen.patch(gain).patch(out);
  
  frameRate(BASE_FRAMERATE);
}


void draw()
{
  background(0,0,25);

  directionalLight(126, 126, 126, 100, 0, -1);
  ambientLight(182, 182, 182);

  simUGen.spin();

  cam.beginHUD();
  stroke(125,125,255);
  strokeWeight(2);
  fill(0,0,60, 220);
  rect(0,0, 250, 60);
  textSize(16);
  fill(255, 255, 255);
  text("Curr Audio: " + currAudio, 10, 30);
  text("FPS: " + frameRate, 10, 45);
  cam.endHUD();

}


void mouseReleased() {
  println("### refresh models!!");
  simUGen.foo();
}
