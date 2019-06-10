class MassGene {
    static final float STD_MASS = 50;
    static final float MIN_MASS = 10;
    static final float MAX_MASS = 200;
    float mass;

    public MassGene() {
        this.mass = STD_MASS;
    }

    public MassGene(float mass) {
        this.mass = mass;
    }

    public MassGene(MassGene x) {
        this.mass = x.mass;
    }

    void randomize(float factor) {
        this.mass = GeneticUtils.randomizeValueGaussian(this.mass, factor);
        this.mass = constrain(this.mass, MIN_MASS, MAX_MASS);
    }
}