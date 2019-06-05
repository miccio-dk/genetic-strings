import shapes3d.utils.*;
import shapes3d.animation.*;
import shapes3d.*;


public class phyView {
    ArrayList<Ellipsoid> shapes;
    PApplet sketchRef;

    public phyView(PApplet pa) {
        println("phyView.phyView");
        shapes = new ArrayList<Ellipsoid>();
        sketchRef = pa;
    }


    void initShapes(PhysicalModel mdl) {
        println("phyView.initShapes");
        println("number of elements: "+mdl.getNumberOfMats());
        for ( int i = 0; i < mdl.getNumberOfMats(); i++) {
            float size = (float)mdl.getMatMassAt(i);
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
        //println("phyView.renderShapes");
        PVector v;
        synchronized(lock) { 
            for ( int i = 0; i < mdl.getNumberOfMats(); i++) {
                v = mdl.getMatPosAt(i).toPVector().mult(100.);
                this.shapes.get(i).moveTo(v.x, v.y, v.z);
            }

            for ( int i = 0; i < mdl.getNumberOfLinks(); i++) {
                float weight = (float)(1 - mdl.getLinkElongationAt(i) / mdl.getLinkDistanceAt(i) - 0.0007) * 3000;
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


    void resetShapes() {
        for (Ellipsoid shape : shapes) {
            shape.finishedWith();
        }
        shapes.clear();
    }


    void addColoredShape(PVector pos, color col, float size) {
        //println("phyView.addColoredShape");
        Ellipsoid tmp = new Ellipsoid(this.sketchRef, 20, 20);
        tmp.setRadius(size);
        tmp.moveTo(pos.x, pos.y, pos.z);
        tmp.strokeWeight(0);
        tmp.fill(col);
        tmp.tag = "";
        tmp.drawMode(Shape3D.TEXTURE);
        this.shapes.add(tmp);
    }

    void drawLine(Vect3D pos1, Vect3D pos2) {
        //println("phyView.drawLine");
        line(100*(float)pos1.x, 100*(float)pos1.y, 100*(float)pos1.z, 100*(float)pos2.x, 100*(float)pos2.y, 100*(float)pos2.z);
    }


}
