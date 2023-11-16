import processing.sound.*;
import netP5.*;
import oscP5.*;
import gab.opencv.*;
import processing.video.*;
import processing.serial.*;
import java.awt.Rectangle;

// Declaracion de los objetos
Capture video;
OpenCV opencv;
Serial miPuerto;
Serial miPuerto2;

OscP5 osc;
NetAddress locacionRemota;

//Sonido
SoundFile sonidoLira [];
//0=feliz
//1=triste
//2=inframundo
int estadoDeLaLira;
//Valores de la lira
int valorResistencia;
int segundosLira;
int tiempoRealLira;
int tiempoLira;
int contador;

//Valores openCV
PImage src, colorFilteredImage;
ArrayList<Contour> contours;
int rangeLow = 110; //SETEO LOS RANGOS DE COLOR EN ESTE CASO EL AZUL ESTA ENTRE ESOS RANGOS
int rangeHigh = 115;
int estamirando;

//Valores de control de tiempo
int segundos;
int horas;
int tiempoReal;
int tiempo;
int minutos;
boolean miroAlFrente=false;
boolean usoLaCorona=false;
boolean puedeUsarLaCorona=false;
int prenderLuz=0;
//Estado
String estado = "inicio";

//Mensajes OSC
OscMessage reproducirVideo;
OscMessage pararVideo;
OscMessage controlarVelocidad;
OscMessage retrocederVideo;
float mensajeRecibido;

void setup() {

  size(640, 480, P2D);
  //----------------------Sonido-----------------------------
  sonidoLira= new SoundFile[3];
  for (int i=0; i<sonidoLira.length; i++) {

    sonidoLira[i]= new SoundFile(this, "sonidoLira"+i+".wav");
  }
  //----------------------OSC-----------------------------
  osc = new OscP5(this, 7001);
  locacionRemota =  new NetAddress("127.0.0.1", 7000); // NetAdress(IP LOCAL, PUERTO QUE EN EL QUE ESTA RECIBIENDO MENSAJES RESOLUME)

  //--------------------openCV----------------------------
  video = new Capture(this, "pipeline:autovideosrc");
  video.start();
  opencv = new OpenCV(this, video.width, video.height);
  contours = new ArrayList<Contour>();

  //-------------------Arduino----------------------------

  String portName = Serial.list()[0];
  miPuerto = new Serial(this, portName, 9600);
  String portName2 = Serial.list()[1];
  miPuerto2 = new Serial(this, portName2, 9600);

  //-------------------Tiempo-----------------------------
  tiempo=millis();
}

void draw() {
  tiempoReal= millis()-tiempo;
  segundos=tiempoReal/1000;
  tiempoRealLira= millis()-tiempoLira;
  segundosLira=tiempoRealLira/1000;


  //  if (estado=="inicio") {


  //    if (keyPressed && key==' ') {
  //      //OscMessage reproducirVideo = new OscMessage("/composition/selectedclip/transport/position/behaviour/playdirection");
  //      //reproducirVideo.add(2);
  //      //osc.send(reproducirVideo, locacionRemota);
  //    }

  //    if (keyPressed && key=='q') {
  //      //OscMessage pararVideo = new OscMessage("/composition/selectedclip/transport/position/behaviour/playdirection");
  //      //pararVideo.add(1);

  //      //osc.send(pararVideo, locacionRemota);
  //    }
  //    if (keyPressed && key=='d') {
  //      OscMessage retrocederVideo = new OscMessage("/composition/selectedclip/transport/position/behaviour/playdirection");
  //      retrocederVideo.add(0);

  //      osc.send(retrocederVideo, locacionRemota);
  //    }
  //  }

  if (mensajeRecibido>0.247 && mensajeRecibido<0.3544 || mensajeRecibido>0.466 && mensajeRecibido<0.62 ) {
    prenderLuz=0;
    miPuerto2.write(prenderLuz);
  }
  if (mensajeRecibido<0.247|| mensajeRecibido>0.3544 && mensajeRecibido<0.466 ||mensajeRecibido>0.62 && mensajeRecibido<0.8) {
    prenderLuz=1;
    miPuerto2.write(prenderLuz);
  }

  //-----Estados Lira
  
   
   if(mensajeRecibido>0.060  && mensajeRecibido<0.19 && valorResistencia>0){
   if(!sonidoLira[0].isPlaying()){
   sonidoLira[0].play();
   }
   
   }
   
   
   
   if(mensajeRecibido> 0.370 && mensajeRecibido<0.77 && valorResistencia>0){
   if(!sonidoLira[1].isPlaying()){
   sonidoLira[1].play();
   sonidoLira[0].stop();
   }
   
   }
   
   if(mensajeRecibido>0.77  && mensajeRecibido<0.86 && valorResistencia>0){
   if(!sonidoLira[2].isPlaying()){
   sonidoLira[2].play();
   sonidoLira[0].stop();
      sonidoLira[1].stop();

   }
   
   }
   

   
   
   
   
   
   
  if (puedeUsarLaCorona==false) {
    if (valorResistencia == 0) {

      tiempoRealLira = millis()-tiempoLira;

      if (segundosLira>3) {
/* 
if(mensajeRecibido>  && mensajeRecibido< || mensajeRecibido>  && mensajeRecibido< || mensajeRecibido>  && mensajeRecibido<){

}





*/
        tiempoLira=millis();
        OscMessage pararVideo = new OscMessage("/composition/selectedclip/transport/position/behaviour/playdirection");
        pararVideo.add(1);

        osc.send(pararVideo, locacionRemota);
      }
    } else if (valorResistencia>0) {
      tiempoLira=millis();
      segundosLira = 0;
      OscMessage reproducirVideo = new OscMessage("/composition/selectedclip/transport/position/behaviour/playdirection"); //ESTA ES LA DECLARACION DE UN MENSAJE OSC, LO QUE ESTA ENTRE COMILLAS LO SACAS DE RESOLUME
      reproducirVideo.add(2);//EL .add AGREGA UNA VARIABLE AL MENSAJE DE ARRIBA, EN ESTE CASO "2" RESOLUME LO INTERPRETA COMO REPRODUCIR VIDEO
      osc.send(reproducirVideo, locacionRemota); //ENVIO EL MENSAJE A RESOLUME
    }
  } else if (miroAlFrente==true) {
    OscMessage reproducirVideo = new OscMessage("/composition/selectedclip/transport/position/behaviour/playdirection");
    reproducirVideo.add(2);
    osc.send(reproducirVideo, locacionRemota);
    tiempoLira=millis();
  }

  if (mensajeRecibido>0.57 && miroAlFrente==false) {
    tiempoLira=millis();
    usoLaCorona=true;
    puedeUsarLaCorona=true;
    segundosLira=0;
    OscMessage pararVideo = new OscMessage("/composition/selectedclip/transport/position/behaviour/playdirection");
    pararVideo.add(1);
    osc.send(pararVideo, locacionRemota);
  }
  // println(horas +":", minutos+":", segundos);
  //println(avanza, estado);

  if ( miPuerto.available() > 0) {  // If data is available,
    valorResistencia = miPuerto.read();         // read it and store it in val
  }

  println(valorResistencia, segundosLira, mensajeRecibido, usoLaCorona);

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
    rect(r.x, r.y, r.width, r.height );
    if (r.width<100 && r.height<100 && usoLaCorona==true) { //SI EL RECT DEL CONTORNO ES MENOR A ESE VALOR(AJUSTARLO DEPENDIENDO LAS NECESIDADES) EL USUARIO NO ESTA MIRANDO
      OscMessage reproducirVideo = new OscMessage("/composition/selectedclip/transport/position/behaviour/playdirection");
      reproducirVideo.add(2);
      osc.send(reproducirVideo, locacionRemota);
      miroAlFrente=true;
      usoLaCorona=false;

      //osc.send(mirando, locacionRemota);
    }
  }
}
void oscEvent(OscMessage theOscMessage) {
  /* print the address pattern and the typetag of the received OscMessage */
  if (theOscMessage.addrPattern().equals("/composition/selectedclip/transport/position")) {
    mensajeRecibido = theOscMessage.get(0).floatValue();
  }
  //println(mensajeRecibido, estado);
  // /composition/selectedclip/transport/position/behaviour/playdirection
}
