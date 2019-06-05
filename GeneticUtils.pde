
static Vect3D vect3D0 = new Vect3D(0., 0., 0.);

static class GeneticUtils {
    static float randomizeValue(float val, float factor) {
        float min = val * (1 - factor);
        float max = val * (1 + factor);
        float rand_val = min + (float)Math.random() * (max - min);
        return rand_val;
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
}