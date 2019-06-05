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


  public PhyUGen(PApplet pa)
  {
    super();
    // create population, init model and 3d shapes
    this.view = new phyView(pa);
    this.createInitialPopulation();
    this.initModel();
    this.view.initShapes(this.mdl);
  }


  void createInitialPopulation() {
    synchronized(lock) {
      this.population = new ArrayList<Specimen>();
      // add specimens to population
      for (int i = 0; i < N_ROWS; ++i) {
        for (int j = 0; j < N_COLS; ++j) {
          Specimen s = new Specimen(GeneticUtils.specimenOrigin(i, j));
          for (int k = 0; k < 3; ++k) {
            s.genome.mutate(MUTATION_AMOUNT);
          }
          this.population.add(s);
        }
      }
    }
  }


  void initModel() {
    synchronized(lock) {
      // setup model
      this.mdl = new PhysicalModel(BASE_SAMPLERATE, BASE_FRAMERATE);
      this.mdl.setGravity(GRAVITY);
      this.mdl.setFriction(FRICTION);

      // add specimens to model
      this.addPlucktoModel(mdl);
      int i = 0;
      for(Specimen s : this.population) {
        s.addToModel(this.mdl, ""+i);
        i++;
      }      
      this.mdl.init();
    }
  }


  void spin() {
    this.view.renderShapes(this.mdl);
    Specimen selected = getSelectedSpecimen();
    if(selected != null) {
      this.view.highlightSelectedSpecimen(selected.position);
    }
  }

  
  Specimen getSelectedSpecimen() {
    Vect3D mouse = GeneticUtils.mouseCoords(mouseX, mouseY, width, height);
    Vect3D sorig;
    int index = 0;

    for (int i = 0; i < N_ROWS; ++i) {
      for (int j = 0; j < N_COLS; ++j) {
        // extract current specimen pos
        sorig = population.get(index).position;
        // check boundaries
        if(mouse.x > sorig.x && 
            mouse.x < (sorig.x+STRING_LEN) && 
            mouse.y > sorig.y && 
            mouse.y < (sorig.y+STRING_LEN)) {
          return population.get(index);
        }
        index++;
      }
    }
    return null;
  }


  void evolve() {
    this.view.resetShapes();
    for(Specimen s : this.population) {
      for (int i = 0; i < 5; ++i) {
        s.genome.mutate(MUTATION_AMOUNT);
      }
    }
    this.initModel();
    this.view.initShapes(this.mdl);
  }


  void evolveFromSpecimen(Specimen parent) {
    this.view.resetShapes();
    int n_passes = 0;
    for(Specimen s : this.population) {
      s.genome = new Genome(parent.genome);
      for (int i = 0; i < n_passes; ++i) {
        s.genome.mutate(MUTATION_AMOUNT);
      }
      n_passes += 1;
    }
    this.initModel();
    this.view.initShapes(this.mdl);
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
      Vect3D mouse = GeneticUtils.mouseCoords(mouseX, mouseY, width, height);
      
      x_avg = (1-smooth) * x_avg + (smooth) * (float)mouse.x;
      y_avg = (1-smooth) * y_avg + (smooth) * (float)mouse.y;
      
      this.mdl.setMatPosition("guideM1", new Vect3D(x_avg-1, y_avg, 0));
      this.mdl.setMatPosition("guideM2", new Vect3D(x_avg+1, y_avg, 0));
      this.mdl.setMatPosition("guideM3", new Vect3D(x_avg, y_avg-1, 0));
      this.mdl.computeStep();

      // calculate the sample value
      for(Specimen s : this.population) {
        sample += s.getSample(this.mdl);
      }

      // high pass filter
      audioOut = sample - prevSample + 0.95 * audioOut;
      prevSample = sample;

      Arrays.fill(channels, audioOut);
      currAudio = audioOut;
    }
  }
}
