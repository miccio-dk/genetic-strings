import java.util.Arrays;
import ddf.minim.UGen;

import miPhysics.*;

// TODO move!
float smooth = 0.01;
float x_avg=0, y_avg=0;

public class PhyUGen extends UGen
{
  private ArrayList<Specimen> population;
  phyView view;

  float prevSample = 0;
  float audioOut = 0;
  PhysicalModel mdl;


  public PhyUGen(PApplet pa, int sampleRate)
  {
    super();
    this.view = new phyView(pa);
    this.createInitialPopulation();
    this.initModel(sampleRate);
  }


  void createInitialPopulation() {
    float margin = 2;

    int n_cols = 4;
    int n_rows = 4;
    synchronized(lock) {
      this.population = new ArrayList<Specimen>();
      float offset_x = (n_cols*STRING_LEN)/2 + ((n_cols+1)*margin)/2;
      float offset_y = (n_rows*STRING_LEN)/2 + ((n_rows+1)*margin)/2;

      for (int i = 0; i < n_rows; ++i) {
        for (int j = 0; j < n_cols; ++j) {
          this.population.add(new Specimen(
              margin + (STRING_LEN+margin)*j - offset_x, 
              margin + (STRING_LEN+margin)*i - offset_y));
        }
      }
    }
  }


  void initModel(int sampleRate) {
    synchronized(lock) {
      // setup model
      this.mdl = new PhysicalModel(sampleRate, BASE_FRAMERATE);
      this.mdl.setGravity(GRAVITY);
      this.mdl.setFriction(FRICTION);

      // add elements
      this.addPlucktoModel(mdl);
      int i = 0;
      for(Specimen specimen : this.population) {
        specimen.addToModel(this.mdl, ""+i);
        i++;
      }
      
      // init model and 3d shapes
      this.mdl.init();
      this.view.initShapes(this.mdl);
    }
  }


  void spin() {
    this.view.renderShapes(this.mdl);
  }


  void foo() {
    this.view.resetShapes();
    for (int i = 0; i < 1; ++i) {
      for(Specimen specimen : this.population) {
        specimen.genome.randomize(0.15);
      }
    }
    this.initModel((int)sampleRate());
  }


  // create plucking device
  void addPlucktoModel(PhysicalModel mdl) {
    mdl.addMass2DPlane("guideM1", 1000000000, new Vect3D(2,-4,0.), vect3D0);
    mdl.addMass2DPlane("guideM2", 1000000000, new Vect3D(4,-4,0.), vect3D0);
    mdl.addMass2DPlane("guideM3", 1000000000, new Vect3D(3,-3,0.), vect3D0); 
    mdl.addMass3D("percMass", 100, vect3D0, vect3D0);
    mdl.addSpringDamper3D("test", 0.1, 1, 1., "guideM1", "percMass");
    mdl.addSpringDamper3D("test", 0.1, 1, 1., "guideM2", "percMass");
    mdl.addSpringDamper3D("test", 0.1, 1, 1., "guideM3", "percMass");
  }
  

  protected void sampleRateChanged() {
    this.mdl.setSimRate((int)sampleRate());
  }


  @Override
  protected void uGenerate(float[] channels) {
    float sample = 0;
    synchronized(lock) {
      float x = 30*(float)mouseX / width - 15;
      float y = 30*(float)mouseY / height - 15;
      
      x_avg = (1-smooth) * x_avg + (smooth) * x;
      y_avg = (1-smooth) * y_avg + (smooth) * y;
      
      this.mdl.setMatPosition("guideM1", new Vect3D(x_avg-1, y_avg, 0));
      this.mdl.setMatPosition("guideM2", new Vect3D(x_avg+1, y_avg, 0));
      this.mdl.setMatPosition("guideM3", new Vect3D(x_avg, y_avg-1, 0));
      this.mdl.computeStep();

      // calculate the sample value
      for(Specimen specimen : this.population) {
        sample += specimen.getSample(this.mdl);
      }

      // high pass filter
      audioOut = sample - prevSample + 0.95 * audioOut;
      prevSample = sample;

      Arrays.fill(channels, audioOut);
      currAudio = audioOut;
    }
  }
}
