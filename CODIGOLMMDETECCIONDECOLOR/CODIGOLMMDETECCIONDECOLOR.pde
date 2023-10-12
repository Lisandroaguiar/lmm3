import spout.*;
import gab.opencv.*;
import processing.video.*;
import java.awt.Rectangle;
Spout spout;
Capture video;
OpenCV opencv;
PImage src, colorFilteredImage;
ArrayList<Contour> contours;
int rangeLow = 110; //SETEO LOS RANGOS DE COLOR EN ESTE CASO EL AZUL ESTA ENTRE ESOS RANGOS
int rangeHigh = 115;

void setup() {
  video = new Capture(this, "pipeline:autovideosrc");
  video.start();
  spout= new Spout(this);
  opencv = new OpenCV(this, video.width, video.height);
  contours = new ArrayList<Contour>();

  size(640, 480, P2D);
}

void draw() {

  if (video.available()) { //Si hay camara disponible la lee
    video.read();
  }

  opencv.loadImage(video); // OpenCV carga la camara

  opencv.useColor();
  src = opencv.getSnapshot();
  opencv.useColor(HSB); //LE DIGO A OPENCV QUE CAPTURE COLOR EN HSB ES MAS FACIL POR LOS RANGOS

  opencv.setGray(opencv.getH().clone()); //NO SE QUE HACE PERO SI LO BORRO SE ROMPE

  opencv.inRange(rangeLow, rangeHigh); //FILTRA EL COLOR EN BASE A LOS RANGOS DADOS

  contours = opencv.findContours(true, true); //NO SE QUE HACE PERO SI LO PONGO EN FALSE SE MUERE

  image(video, 0, 0); //MUESTRO LA IMAGEN

  if (contours.size() > 0) { //SE FIJA SI HAY ALGUN COLOR
    Contour biggestContour = contours.get(0); //SI HAY LOS BUSCA
    Rectangle r = biggestContour.getBoundingBox(); //SE QUEDA CON EL MAS GRANDE
    noFill(); //COSAS DE INTERFAZ
    strokeWeight(2);
    stroke(255, 0, 0);
    rect(r.x, r.y, r.width, r.height);
    if (r.width<140 && r.height<140) { //SI EL RECT DEL CONTORNO ES MENOR A ESE VALOR(AJUSTARLO DEPENDIENDO LAS NECESIDADES) EL USUARIO NO ESTA MIRANDO
      println("MIRO PAL COSTAO");
    } else { //SI ES MAYOR ESTA MIRANDO AL FRENTE
      println("Mirando al frente");
    }
    spout.sendTexture(); //MANDO TODO POR SPOUT
  }
}
