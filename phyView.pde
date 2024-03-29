import shapes3d.utils.*;
import shapes3d.animation.*;
import shapes3d.*;


public class phyView {
    ArrayList<Ellipsoid> shapes;
    PApplet pa;
    PeasyCam cam;

    float margin;
    float thickness;
    float fontSize;
    float plotHeight;
    float legendWidth;
    float[] plotRange;

    public phyView(PApplet pa, PeasyCam cam) {
        shapes = new ArrayList<Ellipsoid>();
        this.pa = pa;
        this.cam = cam;
        margin = 5;
        thickness = 4;
        fontSize = 12;
        plotHeight = 140;
        legendWidth = 100;
        plotRange = new float[] {-3, 1};

    }


    void initShapes(PhysicalModel mdl) {
        println("number of elements: "+mdl.getNumberOfMats());
        for ( int i = 0; i < mdl.getNumberOfMats(); i++) {
            float size = (float)mdl.getMatMassAt(i) / 2;
            switch (mdl.getMatTypeAt(i)) {
            case Mass3D:
                addColoredShape(
                    mdl.getMatPosAt(i).toPVector(), 
                    color(120, 120, 0), 
                    40);
                break;
            case Mass2DPlane:
                addColoredShape(
                    mdl.getMatPosAt(i).toPVector(), 
                    color(120, 0, 120), 
                    size);
                break;
            case Ground3D:
                addColoredShape(
                    mdl.getMatPosAt(i).toPVector(), 
                    color(30, 100, 100), 
                    25);
                break; 
            case UNDEFINED:
                break;
            }
        }
    }


    void renderShapes(PhysicalModel mdl) {
        PVector v;
        synchronized(lock) { 
            for(int i = 0; i < mdl.getNumberOfMats(); i++) {
                v = mdl.getMatPosAt(i).toPVector().mult(100.);
                this.shapes.get(i).moveTo(v.x, v.y, v.z);
            }

            for(int i = 0; i < mdl.getNumberOfLinks(); i++) {
                float weight = (float)(1 - mdl.getLinkElongationAt(i) / mdl.getLinkDistanceAt(i) - 0.0008) * 3000;
                if(weight > 10) {
                    weight = 1;
                }
                
                switch (mdl.getLinkTypeAt(i)) {
                case Spring3D:
                    stroke(0, 255, 0);
                    strokeWeight(weight);
                    drawLine(mdl.getLinkPos1At(i), mdl.getLinkPos2At(i));
                    break;
                case Damper3D:
                    stroke(125, 125, 125);
                    strokeWeight(weight);
                    drawLine(mdl.getLinkPos1At(i), mdl.getLinkPos2At(i));
                    break; 
                case SpringDamper3D:
                    stroke(0, 0, 255);
                    strokeWeight(weight);
                    drawLine(mdl.getLinkPos1At(i), mdl.getLinkPos2At(i));
                    break;
                case Contact3D:
                    break; 
                case UNDEFINED:
                    break;
                }
            }
        }
        for (Ellipsoid shape : shapes) {
            shape.draw();
        }
    }


    void highlightSelectedSpecimen(Specimen s) {
        Vect3D pos = s.position;
        fill(255, 255, 255, 50);
        stroke(0);
        strokeWeight(2);
        rect((float)pos.x*100, (float)pos.y*100, STRING_LEN*100, STRING_LEN*100);
    }


    void showHUD() {
        cam.beginHUD();
        float y;

        // 1: general infos
        y = margin;
        drawHudRect(-margin, y, 140, (margin+fontSize)*2);
        text(String.format("Curr Audio: %.2f", Math.abs(currAudio*100)), margin, y+margin+fontSize);
        text(String.format("FPS: %.2f", frameRate), margin, y+margin+fontSize*2);

        // TODO add constants values and settings (n_masses, mutation)
        // 3: 

        // 2: current speciment deets
        /*
        Specimen s = simUGen.getSelectedSpecimen();
        if(s != null) {
            y = 80;
            rect(-margin, y, 170, 560);
            String descr = s.genome.getDescription();
            text(descr, margin, y+margin+line);
        }
        */
        cam.endHUD();
    }


    void plotSpecimenInfos(Specimen s) {
        cam.beginHUD();

        float[] minmax;
        float y1, y2, x;

        String[] stats = new String[] {"mass", "resting len", "stiffness", "damping"};
        color[] stats_colors = new color[] {color(80, 80, 80), color(255, 0, 0), color(255, 255, 0), color(0, 0, 255)};

        drawHudRect(margin, height - plotHeight - margin*2, width-margin*2, plotHeight+margin*3);
        drawPlotEdges();

        // mass
        float[] masses = s.genome.getMassValues();
        for(int i=0; i<masses.length; i++) {
            masses[i] /= 10;
        }
        minmax = GeneticUtils.getMassMinMax();
        drawPlot(masses, minmax, stats_colors[0], true);
        // spring resting len
        float[] restl = s.genome.getRestingLenValues();
        minmax = GeneticUtils.getRestingLenMinMax();
        drawPlot(restl, minmax, stats_colors[1], false);
        // spring stiffness
        float[] stiff = s.genome.getStiffnessValues();
        minmax = GeneticUtils.getStiffnessMinMax();
        drawPlot(stiff, minmax, stats_colors[2], false);
        // spring damping
        float[] damp = s.genome.getDampingValues();
        minmax = GeneticUtils.getDampingMinMax();
        drawPlot(damp, minmax, stats_colors[3], false);

        // legend
        float w = plotHeight/5;
        float x_legend = margin*2;
        fill(255);
        strokeWeight(0);
        text("Specimen #" + simUGen.prevNote + "  (~" + GeneticUtils.indexToFreq(simUGen.prevNote) + " Hz)", x_legend, height-margin-(5*w)+w-thickness, 0);
        for(int i=0; i<4; i++) {
            float y = height - margin - (5*w) + (i+1)*w;
            fill(stats_colors[i]);
            rect(x_legend, y, w, w);
            text(stats[i], x_legend+w+5, y+w-thickness, 0);
        }
        cam.endHUD();
    }

    void drawHudRect(float x, float y, float w, float h) {
        // graphics setup
        fill(255, 255, 255, 100);
        stroke(255, 255, 255, 200);
        strokeWeight(2);
        textSize(fontSize);
        rect(x, y, w, h);
    }

    void drawPlot(float[] data, float[] minmax, color c, boolean offset) {
        float step = (width - margin*3 - legendWidth) / (data.length - (offset ? 0 : 1));
        stroke(c);
        strokeWeight(1.5);
        float x, y1, y2;
        for(int i=0; i<(data.length-1); i++) {
            x = (offset ? step/2 : 0) + legendWidth + margin + i*step;
            y1 = height - margin - GeneticUtils.normalize((float)Math.log10(data[i]), plotRange) * (plotHeight - margin*2);
            y2 = height - margin - GeneticUtils.normalize((float)Math.log10(data[i+1]), plotRange) * (plotHeight - margin*2);
            line(x, y1, x+step, y2);
        }
    }

    void drawPlotEdges() {
        fill(255, 255, 255, 100);
        stroke(255, 255, 255, 100);
        strokeWeight(1.5);
        rect(legendWidth + margin, 
                height - plotHeight - margin, 
                (width - margin*3 - legendWidth), 
                plotHeight);
        stroke(255, 255, 255, 100);
        int nTicks = (int)(plotRange[1] - plotRange[0]);
        for(int i=0; i<nTicks; i++) {
            strokeWeight(1);
            float y1 = GeneticUtils.normalize((float)Math.log10(pow(10, i+plotRange[0])), plotRange) * (plotHeight - margin*2);
            
            line(legendWidth + margin, 
                height - margin - y1, 
                width - margin*2, 
                height - margin - y1);

            strokeWeight(0.5);
            for(int j=0; j<10; j++) {
                float sub = pow(10, i+plotRange[0]) * j;
                float y2 = GeneticUtils.normalize((float)Math.log10(sub), plotRange) * (plotHeight - margin*2);
                println(""+sub);
                line(legendWidth + margin, 
                    height - margin - y2, 
                    width - margin*2, 
                    height - margin - y2);
                }
        }
    }



    void resetShapes() {
        for (Ellipsoid shape : shapes) {
            shape.finishedWith();
        }
        shapes.clear();
    }


    void addColoredShape(PVector pos, color col, float size) {
        Ellipsoid tmp = new Ellipsoid(this.pa, 20, 20);
        tmp.setRadius(size);
        tmp.moveTo(pos.x, pos.y, pos.z);
        tmp.strokeWeight(0);
        tmp.fill(col);
        tmp.tag = "";
        tmp.drawMode(Shape3D.TEXTURE);
        this.shapes.add(tmp);
    }

    void drawLine(Vect3D pos1, Vect3D pos2) {
        line(100*(float)pos1.x, 100*(float)pos1.y, 100*(float)pos1.z, 100*(float)pos2.x, 100*(float)pos2.y, 100*(float)pos2.z);
    }


}
