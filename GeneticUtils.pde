static class GeneticUtils {
    static float randomize(float val, float factor) {
        float min = val * (1 - factor);
        float max = val * (1 + factor);
        float rand_val = min + (float)Math.random() * (max - min);
        return rand_val;
    }

    static String makeName(String prefix, String specimen, int index) {
        return prefix + "_" + specimen + "_" + index;
    }
}