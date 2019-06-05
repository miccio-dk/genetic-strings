import java.util.Arrays;

class MassGene {
    float mass;

    public MassGene(float mass) {
        this.mass = mass;
    }

    void randomize(float factor) {
        this.mass = GeneticUtils.randomize(this.mass, factor);
    }

    // TODO copy ctor
}


class SpringGene {
    float resting_length;
    float stiffness;
    float damping;
    
    public SpringGene(float resting_length, float stiffness, float damping) {
        this.resting_length = resting_length;
        this.stiffness = stiffness;
        this.damping = damping;
    }

    void randomize(float factor) {
        this.resting_length = GeneticUtils.randomize(this.resting_length, factor);
        this.stiffness      = GeneticUtils.randomize(this.stiffness, factor);
        this.damping        = GeneticUtils.randomize(this.damping, factor);
    }

    // TODO copy ctor
}


public class Genome {
    int n_masses;
    ArrayList<MassGene> masses;
    ArrayList<SpringGene> springs;

    public Genome(int n_masses) {
        this.n_masses = n_masses;
        this.masses = new ArrayList<MassGene>();
        this.springs = new ArrayList<SpringGene>();
        this.initGenome();
    }
    
    void initGenome() {
        for(int i=0; i<this.n_masses; i++) {
            this.masses.add(new MassGene(20));
        }

        for(int i=0; i<(this.n_masses+1); i++) {
            this.springs.add(new SpringGene(0.0001, 1, 0.1));
        }
    }

    void randomize(float factor) {
        for(MassGene mass_gene : masses) {
            mass_gene.randomize(factor);
        }
        for(SpringGene spring_gene : springs) {
            spring_gene.randomize(factor);
        }
    }
} 

