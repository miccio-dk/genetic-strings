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

  int prevNote = 0;
  float prevSample = 0;
  float audioOut = 0;
  PhysicalModel mdl;


  public PhyUGen(PApplet pa, PeasyCam cam) {
    super();
    // create population, init model and 3d shapes
    this.view = new phyView(pa, cam);
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
          Specimen s = new Specimen(GeneticUtils.specimenOrigin(i, j), N_MASSES, LISTENING_POINT);
          for (int k = 0; k < 1; ++k) {
            s.genome.mutate();
          }
          this.population.add(s); //<>// //<>//
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
      this.addPluckToModel(mdl);
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
      this.view.highlightSelectedSpecimen(selected);
      this.view.plotSpecimenInfos(selected);
    }
    this.view.showHUD();
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
          // store position index
          prevNote = i*N_COLS+j;
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
        s.genome.mutate();
      }
    }
    this.initModel();
    this.view.initShapes(this.mdl);
  }


  void evolveFromSpecimen(Specimen parent) {
    // clear shape cache
    this.view.resetShapes();
    int spec_index = 0;
    int mass_index = 0;

    // for each specimen...
    for(Specimen s : this.population) {
      mass_index = 0;
      // replace genome with parent's
      s.genome = new Genome(parent.genome);
      // mutate new genome
      s.genome.mutate();

      // tune:
      // get average mass and list of stiffness vals
      float mass_avg = GeneticUtils.arrayAverage(s.genome.getMassValues());
      float[] spring_stiff = s.genome.getStiffnessValues();
      // for each mass in the specimen...
      for(MassGene m : s.genome.masses) {
        // extract stiffness of one of the springs connected
        float k = spring_stiff[mass_index+1];
        // extract desired oscillation speed
        float omega = 2.0 * (float)Math.PI * GeneticUtils.indexToFreq(spec_index);
        // normalize 
        m.mass /= mass_avg;
        // apply omega = sqrt(k/m)
        m.mass *= k;
        m.mass /= pow(omega, 2);
        // TODO ???
        m.mass *= 0.5e8;
        // next mass
        mass_index++;
      }
      println("NOTE " + spec_index + " - NEW MASS: " + s.genome.masses.get(4).mass);
      spec_index++;
    }

    // init stuff
    this.initModel();
    this.view.initShapes(this.mdl);
  }


  // create plucking device
  void addPluckToModel(PhysicalModel mdl) {
    Vect3D mouse = GeneticUtils.mouseCoords(mouseX, mouseY, width, height);

    mdl.addMass2DPlane("guideM1", 1000000000, new Vect3D(mouse.x-1, mouse.y, 0), GeneticUtils.vect3D0);
    mdl.addMass2DPlane("guideM2", 1000000000, new Vect3D(mouse.x+1, mouse.y, 0), GeneticUtils.vect3D0);
    mdl.addMass2DPlane("guideM3", 1000000000, new Vect3D(mouse.x, mouse.y-1, 0), GeneticUtils.vect3D0); 
    mdl.addMass3D("percMass", 100, mouse, GeneticUtils.vect3D0);
    mdl.addSpringDamper3D("test", 0.001, 2, 0.1, "guideM1", "percMass");
    mdl.addSpringDamper3D("test", 0.001, 2, 0.1, "guideM2", "percMass");
    mdl.addSpringDamper3D("test", 0.001, 2, 0.1, "guideM3", "percMass");

  }


  void movePluck() {
    Vect3D mouse = GeneticUtils.mouseCoords(mouseX, mouseY, width, height);
      
    x_avg = (1-smooth) * x_avg + (smooth) * (float)mouse.x;
    y_avg = (1-smooth) * y_avg + (smooth) * (float)mouse.y;
    
    this.mdl.setMatPosition("guideM1", new Vect3D(x_avg-1, y_avg, 0));
    this.mdl.setMatPosition("guideM2", new Vect3D(x_avg+1, y_avg, 0));
    this.mdl.setMatPosition("guideM3", new Vect3D(x_avg, y_avg-1, 0));
  }
  

  protected void sampleRateChanged() {
    this.mdl.setSimRate((int)sampleRate());
  }


  @Override
  protected void uGenerate(float[] channels) {
    float sample = 0;
    synchronized(lock) {
      this.movePluck();
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
