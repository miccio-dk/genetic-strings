import java.util.Arrays;


float c_dist = 0.5;
float c_gnd = 0.65;
float c_k = 0.07;
float c_z = 0.01;


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

  void addToModel(PhysicalModel mdl, String name) { //<>//
    println("Specimen.addToModel");
    Vect3D newpos = new Vect3D(position);
    int n_masses = this.genome.masses.size();
    float dist = ((float)STRING_LEN / n_masses);

    for(int i = 0; i < n_masses; i++) {
      newpos.x += dist;
      
      // extract mass and add to model
      MassGene mass_gene = this.genome.masses.get(i);
      mdl.addMass2DPlane("str_"+name+i, mass_gene.mass, newpos, vect3D0);
      mdl.addContact3D("col", c_dist, c_k, c_z, "percMass", "str_"+name+i);

      // extract spring and add to model (starting from second mass)
      if (i > 0) {
        SpringGene spring_gene = this.genome.springs.get(i);
        mdl.addSpringDamper3D("sprd_"+name+i, 
            spring_gene.resting_length, 
            spring_gene.stiffness, 
            spring_gene.damping, 
            "str_"+name+(i-1), "str_"+name+i);
      }
    }

    // create string ends
    newpos.x += dist;
    mdl.addGround3D("gnd_"+name+0, position);
    mdl.addGround3D("gnd_"+name+1, newpos);
    SpringGene spring_gene = this.genome.springs.get(0);
    mdl.addSpringDamper3D("sprdg_"+name+0, spring_gene.resting_length, spring_gene.stiffness, spring_gene.damping, "gnd_"+name+0, "str_"+name+0);
    spring_gene = this.genome.springs.get(n_masses);
    mdl.addSpringDamper3D("sprdg_"+name+1, spring_gene.resting_length, spring_gene.stiffness, spring_gene.damping, "gnd_"+name+1, "str_"+name+(n_masses-1));

    mdl.addContact3D("col", c_gnd, 10, c_z, "percMass", "gnd_"+name+0);
    mdl.addContact3D("col", c_gnd, 10, c_z, "percMass", "gnd_"+name+1);

    this.listeningPoint = "str_"+name+4;
  }

  float getSample(PhysicalModel mdl) {
    //println("Specimen.getSample");
    if(mdl.matExists(this.listeningPoint)) {
      return (float)(mdl.getMatPosition(this.listeningPoint).y - this.position.y);
    }
    return 0;
  }

  void mutate() {
    println("Specimen.mutate");

  }
}
