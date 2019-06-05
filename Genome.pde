import java.util.Arrays;

class MassGene {
    float mass;

    public MassGene(float mass) {
        this.mass = mass;
    }

    public MassGene(MassGene x) {
        this.mass = x.mass;
    }

    void randomize(float factor) {
        this.mass = GeneticUtils.randomizeValue(this.mass, factor);
    }
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

    public SpringGene(SpringGene x) {
        this.resting_length = x.resting_length;
        this.stiffness      = x.stiffness;
        this.damping        = x.damping;
    }

    void randomize(float factor) {
        this.resting_length = GeneticUtils.randomizeValue(this.resting_length, factor);
        this.stiffness      = GeneticUtils.randomizeValue(this.stiffness, factor);
        this.damping        = GeneticUtils.randomizeValue(this.damping, factor);
    }
}


public class Genome {
    int n_masses;
    ArrayList<MassGene> masses;
    ArrayList<SpringGene> springs;


    public Genome(int n_masses) {
        this.n_masses = n_masses;
        this.masses = new ArrayList<MassGene>();
        this.springs = new ArrayList<SpringGene>();
        this.initGenomeStandard();
    }


    public Genome(Genome g) {
        this.n_masses = g.n_masses;
        this.masses = new ArrayList<MassGene>(g.masses.size());
        for(MassGene mass : g.masses) {
            this.masses.add(new MassGene(mass));
        }
        this.springs = new ArrayList<SpringGene>(g.springs.size());
        for(SpringGene spring : g.springs) {
            this.springs.add(new SpringGene(spring));
        }
    }


    void init() {

    }
    

    void initGenomeStandard() {
        for(int i=0; i<this.n_masses; i++) {
            this.masses.add(new MassGene(40));
        }
        for(int i=0; i<(this.n_masses+1); i++) {
            this.springs.add(new SpringGene(0.001, 1, 0.1));
        }
    }


    void mutate(float factor) {
        for(MassGene mass_gene : masses) {
            mass_gene.randomize(factor);
        }
        for(SpringGene spring_gene : springs) {
            spring_gene.randomize(factor);
        }
    }
} 

