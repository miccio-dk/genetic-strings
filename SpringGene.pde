class SpringGene {
    static final float MAX_LEN = (6.0f / (15)) * 1.414f;    // STRING_LEN / (n_masses+1)
    static final float STD_RESTLEN = MAX_LEN / 10;
    static final float MIN_RESTLEN = MAX_LEN / 100;
    static final float MAX_RESTLEN = MAX_LEN;
    float resting_length;
    static final float STD_STIFF = 1;
    static final float MIN_STIFF = 0.1f;
    static final float MAX_STIFF = 10;
    float stiffness;
    static final float STD_DAMP = 0.1f;
    static final float MIN_DAMP = 0.01f;
    static final float MAX_DAMP = 5;
    float damping;
    
    public SpringGene() {
        this.resting_length = STD_RESTLEN;
        this.stiffness = STD_STIFF;
        this.damping = STD_DAMP;
    }

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

    void randomize(float factorLen, float factorStiff, float factorDamp) {
//        println("\tresting_length: "+resting_length+
//                "\tstiffness: "+stiffness+
//                "\tdamping: "+damping);
        this.resting_length = GeneticUtils.randomizeValueGaussian(this.resting_length, factorLen);
        this.stiffness      = GeneticUtils.randomizeValueLogUniform(this.stiffness, factorStiff);
        this.damping        = GeneticUtils.randomizeValueLogUniform(this.damping, factorDamp);
        this.resting_length = constrain(this.resting_length, MIN_RESTLEN, MAX_RESTLEN);
        this.stiffness      = constrain(this.stiffness, MIN_STIFF, MAX_STIFF);
        this.damping        = constrain(this.damping, MIN_DAMP, MAX_DAMP);
//        println("\tresting_length: "+resting_length+
//                "\tstiffness: "+stiffness+
//                "\tdamping: "+damping);
    }
}
