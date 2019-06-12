import java.util.Arrays;


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
    

    void initGenomeStandard() {
        for(int i=0; i<this.n_masses; i++) {
            this.masses.add(new MassGene());
        }
        for(int i=0; i<(this.n_masses+1); i++) {
            this.springs.add(new SpringGene());
        }
    }


    void mutate(float factor) {
        for(MassGene mass_gene : masses) {
            //mass_gene.randomize(factor);
        }
        for(SpringGene spring_gene : springs) {
            spring_gene.randomize(factor);
        }
    }

    String getDescription() {
        String str = "";
        for(int i=0; i<(this.n_masses+1); i++) {
            SpringGene spring = this.springs.get(i);
            str += String.format(
                    "L0: %.2f, K: %.2f, Z: %.2f \n", 
                    spring.resting_length, 
                    spring.stiffness,
                    spring.damping);
            if(i < this.n_masses) {
                MassGene mass = this.masses.get(i);
                str += String.format("M: %.2f \n", mass.mass);
            }
        }
        return str;
    }

    float[] getMassValues() {
        float[] m = new float[n_masses];
        int i = 0;
        for(MassGene mass_gene : masses) {
            m[i] = mass_gene.mass;
            i++;
        }
        return m;
    }

    float[] getRestingLenValues() {
        float[] rl = new float[n_masses+1];
        int i = 0;
        for(SpringGene spring_gene : springs) {
            rl[i] = spring_gene.resting_length;
            i++;
        }
        return rl;
    }

    float[] getStiffnessValues() {
        float[] st = new float[n_masses+1];
        int i = 0;
        for(SpringGene spring_gene : springs) {
            st[i] = spring_gene.stiffness;
            i++;
        }
        return st;
    }

    float[] getDampingValues() {
        float[] da = new float[n_masses+1];
        int i = 0;
        for(SpringGene spring_gene : springs) {
            da[i] = spring_gene.damping;
            i++;
        }
        return da;
    }

} 
