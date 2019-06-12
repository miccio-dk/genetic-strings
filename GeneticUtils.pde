import java.util.List;
import miPhysics.Vect3D;


static class GeneticUtils {
    static Vect3D vect3D0 = new Vect3D(0., 0., 0.);
    static PApplet sketchRef;

    GeneticUtils(PApplet pa) {
        this.sketchRef = pa;
    }

    static float randomizeValue(float val, float factor) {
        float min = 1.0 / (1 + factor);
        float max = 1 + factor;
        float rand_val = sketchRef.random(min, max);
        // println("\t"+val+", "+factor+" ("+min+" , "+max+") ->"+rand_val);
        return val * rand_val;
    }

    static float randomizeValueLog(float val, float factor) {
        return exp(randomizeValue(log(val+1), factor)) - 1;
    }

    static float randomizeValueGaussian(float val, float std) {
        float sample = sketchRef.randomGaussian();
        return val + sample*std;
    }

    static float randomizeValueLogUniform(float val, float factor) {
        float[] range = new float[] {1.0/factor, 1.0*factor};
        float x = (float)Math.pow(10, (Math.random() * (Math.log10(range[1]) - Math.log10(range[0]))));
        x *= range[0];
        return val * x;
    }

    static String makeName(String prefix, String specimen, int index) {
        return prefix + "_" + specimen + "_" + index;
    }

    static Vect3D specimenOrigin(int i_row, int i_col) {
        // calculate offsets
        float offset_x = (N_COLS*STRING_LEN + N_COLS*MARGIN + MARGIN) / 2;
        float offset_y = (N_ROWS*STRING_LEN + N_ROWS*MARGIN + MARGIN) / 2;

        return new Vect3D(
            MARGIN + (STRING_LEN+MARGIN)*i_col - offset_x, 
            MARGIN + (STRING_LEN+MARGIN)*i_row - offset_y,
            0);
    }

    static Vect3D mouseCoords(int x, int y, int w, int h) {
        return new Vect3D(
            30 * (float)x / w - 15,
            30 * (float)y / h - 15,
            0);
    }

    static float[] findMinMax(float[] a) {
        float min = a[0];
        float max = a[0];
        for(float x : a){
            if(x < min) min = x;
            if(x > max) max = x;
        }
        return new float[] {min, max};
    }

    static float arrayAverage(float[] a){
        int sum = 0;
        float average;

        for(float x : a) {
            sum += x;
        }
        return (float)sum / a.length;
    }

    static float normalize(float x, float[] minmax) {
        return (x - minmax[0]) / (minmax[1] - minmax[0]);
    }

    static float[] getMassMinMax() {
        return new float[] {MassGene.MIN_MASS, MassGene.MAX_MASS};
    }

    static float[] getRestingLenMinMax() {
        return new float[] {SpringGene.MIN_RESTLEN, SpringGene.MAX_RESTLEN};
    }

    static float[] getStiffnessMinMax() {
        return new float[] {SpringGene.MIN_STIFF, SpringGene.MAX_STIFF};
    }

    static float[] getDampingMinMax() {
        return new float[] {SpringGene.MIN_DAMP, SpringGene.MAX_DAMP};
    }

    static float indexToFreq(int i) {
        return NOTES[i % NOTES.length] * (int)(i / NOTES.length + 1);
    }
}
