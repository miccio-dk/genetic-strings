import java.util.Arrays;


float c_dist = 1;
float c_gnd = 0.65;
float c_k = 1;
float c_z = 1;


public class Specimen {
  // TODO genome
  Genome genome;
  String listeningPoint;
  Vect3D position;
  
  public Specimen(float x, float y) {
    println("Specimen.Specimen");
    genome = new Genome(N_MASSES);
    position = new Vect3D(x, y, 0);
  }


  void addToModel(PhysicalModel mdl, String name) {
    println("Specimen.addToModel");
    Vect3D newpos = new Vect3D(position);
    int n_masses = this.genome.masses.size();
    float dist = ((float)STRING_LEN / n_masses);

    for(int i = 0; i < n_masses; i++) {
      newpos.x += dist;
      newpos.y += dist;
      
      // extract mass and add to model
      MassGene mass_gene = this.genome.masses.get(i);
      mdl.addMass2DPlane(GeneticUtils.makeName("str", name, i), mass_gene.mass, newpos, vect3D0);
      mdl.addContact3D("col", c_dist, c_k, c_z, "percMass", GeneticUtils.makeName("str", name, i));

      // extract spring and add to model (starting from second mass)
      if (i > 0) {
        SpringGene spring_gene = this.genome.springs.get(i);
        mdl.addSpringDamper3D(GeneticUtils.makeName("sprd", name, i), 
            spring_gene.resting_length, 
            spring_gene.stiffness, 
            spring_gene.damping, 
            GeneticUtils.makeName("str", name, i-1), 
            GeneticUtils.makeName("str", name, i));
      }
    }

    // create string ends
    newpos.x += dist;
    newpos.y += dist;
    mdl.addGround3D(GeneticUtils.makeName("gnd", name, 0), position);
    SpringGene spring_gene = this.genome.springs.get(0);
    mdl.addSpringDamper3D(
        GeneticUtils.makeName("sprdg", name, 0), 
        spring_gene.resting_length, 
        spring_gene.stiffness, 
        spring_gene.damping, 
        GeneticUtils.makeName("gnd", name, 0), 
        GeneticUtils.makeName("str", name, 0));
    mdl.addContact3D("col", c_gnd, 10, c_z, "percMass", GeneticUtils.makeName("gnd", name, 0));

    mdl.addGround3D(GeneticUtils.makeName("gnd", name, 1), newpos);
    spring_gene = this.genome.springs.get(n_masses);
    mdl.addSpringDamper3D(
        GeneticUtils.makeName("sprdg", name, 1), 
        spring_gene.resting_length, 
        spring_gene.stiffness, 
        spring_gene.damping, 
        GeneticUtils.makeName("gnd", name, 1), 
        GeneticUtils.makeName("str", name, n_masses-1));
    mdl.addContact3D("col", c_gnd, 10, c_z, "percMass", GeneticUtils.makeName("gnd", name, 1));

    this.listeningPoint = GeneticUtils.makeName("str", name, 4);
  }


  float getSample(PhysicalModel mdl) {
    //println("Specimen.getSample");
    float sample = 0.;
    if(mdl.matExists(this.listeningPoint)) {
      sample = (float)(mdl.getMatPosition(this.listeningPoint).y - this.position.y);
      if(!Float.isFinite(sample)) {
        sample = 0.;
      }
    }
    return sample / N_STRINGS;
  }


  void mutate() {
    println("Specimen.mutate");

  }
}
