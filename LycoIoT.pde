
import java.util.ArrayList;

color ROJO = #E31B23;
color ROJO_OSCURO = #BA101A;
color VERDE = #168744;
color VERDE_OSCURO = #075435;
color VERDE_CLARO = #E6F5E9;
color ROJO_CLARO = #FCEBEC;
color BLANCO = #FFFFFF;
color FONDO = #F4F7F5;
color TEXTO = #18382C;
color GRIS = #718078;
color BORDE = #DFE8E1;
color NARANJA = #EBA12C;
color AZUL = #168ECC;
color TIERRA = #805438;

PFont fuenteNormal;
PFont fuenteNegrita;


PImage logo;

float temperatura = 25.3;
float humedadAire = 58;

float[] humedadSuelo = {65, 48, 72, 41};

boolean riegoActivo = false;
boolean automatico = true;

int pagina = 0;
int plantaSeleccionada = 0;

final int MUESTRAS = 40;
float[][] historial = new float[4][MUESTRAS];

int ultimaLectura = 0;


float MENU = 270;
float CONTENIDO = 295;

void setup() {
  size(1500, 950);
  surface.setTitle("LycoIoT - Invernadero Inteligente");
  smooth(4);

  fuenteNormal = createFont("SansSerif", 16);
  fuenteNegrita = createFont("SansSerif.bold", 16);

  logo = loadImage("logo.png");

  for (int p = 0; p < 4; p++) {
    for (int i = 0; i < MUESTRAS; i++) {
      historial[p][i] =
        constrain(humedadSuelo[p] + random(-7, 7), 0, 100);
    }
  }
}

void draw() {
  background(FONDO);

  if (millis() - ultimaLectura > 2500) {
    simularLecturas();
    ultimaLectura = millis();
  }

  dibujarMenu();
  dibujarEncabezado();

  if (pagina == 0) {
    dibujarInicio();
  } else if (pagina == 1) {
    dibujarMonitoreo();
  } else if (pagina == 2) {
    dibujarPlantas();
  } else if (pagina == 3) {
    dibujarHistorial();
  } else {
    dibujarConfiguracion();
  }
}

void texto(String s, float x, float y,
           int tam, color c, boolean negrita) {
  fill(c);
  textFont(negrita ? fuenteNegrita : fuenteNormal);
  textSize(tam);
  textAlign(LEFT, BASELINE);
  text(s, x, y);
}

void centro(String s, float x, float y,
            int tam, color c, boolean negrita) {
  fill(c);
  textFont(negrita ? fuenteNegrita : fuenteNormal);
  textSize(tam);
  textAlign(CENTER, CENTER);
  text(s, x, y);
  textAlign(LEFT, BASELINE);
}

void tarjeta(float x, float y, float w, float h) {
  noStroke();
  fill(#E7ECE8);
  rect(x + 2, y + 4, w, h, 17);

  fill(BLANCO);
  stroke(BORDE);
  strokeWeight(1);
  rect(x, y, w, h, 17);
  noStroke();
}

void boton(float x, float y, float w, float h,
           String etiqueta, color c) {
  fill(c);
  noStroke();
  rect(x, y, w, h, 11);
  centro(etiqueta, x + w/2, y + h/2,
         14, BLANCO, true);
}

boolean clic(float x, float y, float w, float h) {
  return mouseX >= x && mouseX <= x+w &&
         mouseY >= y && mouseY <= y+h;
}

color colorEstado(float valor) {
  if (valor < 45) return ROJO;
  if (valor < 55) return NARANJA;
  return VERDE;
}

String estado(float valor) {
  if (valor < 45) return "Riego necesario";
  if (valor < 55) return "Revisar humedad";
  return "En rango";
}

void dibujarMenu() {
  noStroke();
  fill(BLANCO);
  rect(0, 0, MENU, height);

  // Decoracion superior
  fill(ROJO);
  triangle(0, 0, 100, 0, 0, 100);

  fill(VERDE);
  triangle(100, 0, 160, 0, 0, 145);

  // Logo
  if (logo != null) {
    imageMode(CENTER);

    float escala = min(225.0/logo.width,
                       225.0/logo.height);

    float ancho = logo.width*escala;
    float alto = logo.height*escala;

    image(logo, 135, 180, ancho, alto);
    imageMode(CORNER);
  } else {
    dibujarTomate(135, 155, 1.7);
    centro("LycoIoT", 135, 235,
           32, VERDE_OSCURO, true);
    centro("Conectando datos,", 135, 265,
           12, GRIS, false);
    centro("optimizando cultivos", 135, 281,
           12, GRIS, false);
  }

  // Opciones del menu
  String[] opciones = {
    "Inicio", "Monitoreo", "Plantas",
    "Historial", "Configuracion"
  };

  String[] iconos = {
    "⌂", "◉", "♣", "▥", "⚙"
  };

  for (int i = 0; i < 5; i++) {
    float y = 355 + i*83;

    if (pagina == i) {
      fill(ROJO);
      rect(16, y, 238, 65, 13);
    }

    color colorTexto = pagina == i ?
      BLANCO : VERDE_OSCURO;

    centro(iconos[i], 52, y+32,
           28, colorTexto, true);

    texto(opciones[i], 87, y+41,
          19, colorTexto, pagina == i);
  }

  fill(VERDE);
  triangle(0, height-135, 0, height,
           150, height);

  fill(ROJO);
  triangle(0, height-60, 0, height,
           MENU, height);

  centro("LycoIoT • Prototipo",
         135, height-24, 12, BLANCO, true);
}

void dibujarEncabezado() {
  float x = CONTENIDO;
  float w = width-CONTENIDO-25;

  fill(ROJO);
  noStroke();
  rect(x, 22, w, 112, 18);

  texto("Invernadero Inteligente de Jitomate",
        x+28, 72, 30, BLANCO, true);

  texto("Monitoreo ambiental, humedad del suelo y control de riego",
        x+28, 106, 16, BLANCO, false);

  fill(VERDE_OSCURO);
  rect(width-202, 46, 150, 63, 14);

  fill(NARANJA);
  ellipse(width-181, 77, 12, 12);

  texto("ESP32", width-166, 73,
        17, BLANCO, true);

  texto("Modo demo", width-166, 94,
        12, BLANCO, false);
}

void dibujarInicio() {
  dibujarAmbiente(295, 151, 555, 177);
  dibujarResumen(868, 151, 607, 177);

  dibujarInvernadero(295, 347, 555, 374);
  dibujarGrafica(868, 347, 607, 374);

  dibujarRiego(295, 740, 555, 187);
  dibujarAlertas(868, 740, 607, 187);
}

void dibujarAmbiente(float x, float y,
                     float w, float h) {
  tarjeta(x, y, w, h);

  texto("Condiciones ambientales",
        x+20, y+35, 20, VERDE_OSCURO, true);

  fill(ROJO_CLARO);
  rect(x+18, y+53, 250, 108, 15);

  fill(VERDE_CLARO);
  rect(x+285, y+53, 250, 108, 15);

  texto("TEMPERATURA",
        x+34, y+82, 14, ROJO, true);

  texto(nf(temperatura, 0, 1)+" °C",
        x+34, y+125, 35, ROJO, true);

  texto("Sensor DHT11",
        x+34, y+148, 12, GRIS, false);

  texto("HUMEDAD DEL AIRE",
        x+300, y+82, 14, VERDE, true);

  texto(nf(humedadAire, 0, 1)+" %",
        x+300, y+125, 35, VERDE_OSCURO, true);

  texto("Sensor DHT11",
        x+300, y+148, 12, GRIS, false);
}

void dibujarResumen(float x, float y,
                    float w, float h) {
  tarjeta(x, y, w, h);

  texto("Monitoreo por planta",
        x+20, y+35, 20, ROJO, true);

  float ancho = (w-55)/4;

  for (int i = 0; i < 4; i++) {
    float px = x+12+i*(ancho+10);
    float py = y+53;

    fill(plantaSeleccionada == i ?
         VERDE_CLARO : BLANCO);

    stroke(BORDE);
    rect(px, py, ancho, 108, 12);
    noStroke();

    centro("Planta "+(i+1),
           px+ancho/2, py+18,
           14, TEXTO, true);

    medidor(px+ancho/2, py+66,
            28, humedadSuelo[i]);

    centro(estado(humedadSuelo[i]),
           px+ancho/2, py+99,
           10, colorEstado(humedadSuelo[i]), true);
  }
}

void medidor(float x, float y,
             float radio, float valor) {
  noFill();
  strokeWeight(8);
  stroke(#E4EAE5);

  arc(x, y, radio*2, radio*2,
      -HALF_PI, TWO_PI-HALF_PI);

  stroke(colorEstado(valor));

  arc(x, y, radio*2, radio*2,
      -HALF_PI,
      -HALF_PI+TWO_PI*valor/100.0);

  noStroke();
  centro(round(valor)+"%", x, y,
         16, TEXTO, true);
}

void dibujarInvernadero(float x, float y,
                        float w, float h) {
  tarjeta(x, y, w, h);

  texto("Vista superior del invernadero",
        x+20, y+35, 20, VERDE_OSCURO, true);

  float gx = x+25;
  float gy = y+57;
  float gw = w-50;
  float gh = h-84;

  // Terreno
  fill(#D9E7D4);
  stroke(VERDE);
  strokeWeight(3);
  rect(gx, gy, gw, gh, 13);
  noStroke();

  // Area del invernadero
  fill(#C6A07A);
  rect(gx+13, gy+12, gw-26, gh-24, 9);

  // Pasillo central
  fill(#E9D9BD);
  rect(gx+18, gy+gh/2-12,
       gw-36, 24);

  // Cuatro camas de cultivo
  float espacio = (gw-45)/4;

  for (int i = 0; i < 4; i++) {
    float cx = gx+24+espacio*(i+0.5);
    float cy = gy+gh/2;

    fill(TIERRA);
    stroke(#603C29);
    rect(cx-41, gy+34,
         82, gh-68, 8);
    noStroke();

    // Linea de riego
    stroke(AZUL);
    strokeWeight(5);
    line(cx+31, gy+30,
         cx+31, gy+gh-30);
    noStroke();

    // Planta
    dibujarPlanta(cx-5, cy-8, 1.0);

    // Numero de planta
    fill(VERDE_OSCURO);
    stroke(BLANCO);
    strokeWeight(2);
    ellipse(cx, gy+gh-55, 33, 33);
    noStroke();

    centro(""+(i+1),
           cx, gy+gh-55,
           15, BLANCO, true);

    // Sensor
    fill(colorEstado(humedadSuelo[i]));
    stroke(BLANCO);
    strokeWeight(2);
    ellipse(cx-28, gy+47, 13, 13);
    noStroke();
  }

  // Tuberia principal
  stroke(AZUL);
  strokeWeight(5);
  line(gx+30, gy+27,
       gx+gw-30, gy+27);
  noStroke();

  // Deposito
  fill(#087DA9);
  stroke(BLANCO);
  strokeWeight(3);
  ellipse(gx+gw-30, gy+27, 45, 45);
  noStroke();

  fill(#7CD6F5);
  ellipse(gx+gw-30, gy+27, 27, 27);

  texto("N ↑", gx+9, gy+gh-8,
        13, VERDE_OSCURO, true);
}


void dibujarPlanta(float x, float y,
                   float escala) {
  pushMatrix();
  translate(x, y);
  scale(escala);

  for (int i = 0; i < 9; i++) {
    pushMatrix();
    rotate(TWO_PI*i/9.0);

    fill(i%2 == 0 ? VERDE : #35A04E);
    noStroke();
    ellipse(0, -24, 21, 39);

    popMatrix();
  }

  fill(VERDE_OSCURO);
  ellipse(0, 0, 23, 23);

  fill(ROJO);
  ellipse(-16, 11, 15, 15);
  ellipse(15, -8, 16, 16);
  ellipse(10, 19, 13, 13);

  fill(#6CCB58);
  ellipse(0, 0, 9, 9);

  popMatrix();
}

void dibujarTomate(float x, float y,
                   float escala) {
  pushMatrix();
  translate(x, y);
  scale(escala);

  fill(ROJO);
  noStroke();
  ellipse(0, 5, 53, 48);

  fill(VERDE);
  triangle(-19, -13, -4, -5, -7, -25);
  triangle(-8, -12, 8, -4, 4, -29);
  triangle(5, -10, 22, -13, 11, -23);

  popMatrix();
}

void dibujarGrafica(float x, float y,
                    float w, float h) {
  tarjeta(x, y, w, h);

  texto("Humedad del suelo (%)",
        x+20, y+35, 20, ROJO, true);

  float gx = x+60;
  float gy = y+65;
  float gw = w-90;
  float gh = h-130;

  stroke(#E2EAE4);
  strokeWeight(1);

  for (int i = 0; i <= 5; i++) {
    float yy = gy+gh*i/5.0;
    line(gx, yy, gx+gw, yy);

    noStroke();
    texto(""+(100-i*20),
          gx-38, yy+5, 12, GRIS, false);
    stroke(#E2EAE4);
  }

  for (int i = 0; i <= 8; i++) {
    float xx = gx+gw*i/8.0;
    line(xx, gy, xx, gy+gh);
  }

  color[] colores = {
    VERDE, NARANJA, AZUL, ROJO
  };

  for (int p = 0; p < 4; p++) {
    stroke(colores[p]);
    strokeWeight(2.7);
    noFill();

    beginShape();

    for (int i = 0; i < MUESTRAS; i++) {
      float px = gx+i*gw/(MUESTRAS-1.0);
      float py = gy+gh-
        historial[p][i]*gh/100.0;

      vertex(px, py);
    }

    endShape();
  }

  noStroke();

  for (int p = 0; p < 4; p++) {
    float lx = x+55+p*135;

    fill(colores[p]);
    ellipse(lx, y+h-38, 12, 12);

    texto("Planta "+(p+1),
          lx+13, y+h-33,
          13, TEXTO, false);
  }

  texto("Datos de demostracion",
        x+20, y+h-12, 11, GRIS, false);
}

void dibujarRiego(float x, float y,
                  float w, float h) {
  tarjeta(x, y, w, h);

  texto("Sistema de riego",
        x+20, y+35, 20, ROJO, true);

  fill(riegoActivo ? VERDE_CLARO : ROJO_CLARO);
  ellipse(x+70, y+101, 78, 78);

  centro(riegoActivo ? "ON" : "OFF",
         x+70, y+101, 22,
         riegoActivo ? VERDE : ROJO, true);

  texto("Riego", x+130, y+90,
        17, TEXTO, true);

  texto(riegoActivo ? "ACTIVO" : "APAGADO",
        x+130, y+124, 25,
        riegoActivo ? VERDE : ROJO, true);

  boton(x+300, y+60, 235, 45,
        riegoActivo ? "DETENER RIEGO" : "ACTIVAR RIEGO",
        riegoActivo ? ROJO : VERDE);

  boton(x+300, y+115, 235, 40,
        automatico ? "MODO AUTOMATICO" : "MODO MANUAL",
        VERDE_OSCURO);

  texto("Simulacion: sin conexion a bomba real.",
        x+20, y+174, 11, GRIS, false);
}

void dibujarAlertas(float x, float y,
                    float w, float h) {
  tarjeta(x, y, w, h);

  texto("Alertas y notificaciones",
        x+20, y+35, 20, ROJO, true);

  int n = 0;

  for (int i = 0; i < 4; i++) {
    if (humedadSuelo[i] < 55) {
      float yy = y+65+n*38;

      fill(colorEstado(humedadSuelo[i]));
      ellipse(x+32, yy, 13, 13);

      texto("Planta "+(i+1)+
            ": humedad del suelo "+round(humedadSuelo[i])+"%",
            x+50, yy+5, 14, TEXTO, false);

      n++;
    }
  }

  if (n == 0) {
    texto("Todas las plantas se encuentran en rango.",
          x+25, y+85, 14, VERDE, true);
  }

  texto("Lecturas y alertas simuladas.",
        x+20, y+h-17, 11, GRIS, false);
}

void dibujarMonitoreo() {
  dibujarAmbiente(295, 151, 555, 177);
  dibujarResumen(868, 151, 607, 177);
  dibujarGrafica(295, 347, 1180, 430);
  dibujarAlertas(295, 797, 1180, 130);
}

void dibujarPlantas() {
  dibujarInvernadero(295, 151, 740, 550);

  tarjeta(1053, 151, 422, 550);

  texto("Detalle por planta",
        1073, 188, 22, ROJO, true);

  for (int i = 0; i < 4; i++) {
    float yy = 220+i*112;

    fill(i == plantaSeleccionada ?
         VERDE_CLARO : FONDO);

    stroke(BORDE);
    rect(1073, yy, 380, 92, 12);
    noStroke();

    texto("Planta "+(i+1),
          1090, yy+28, 17, TEXTO, true);

    texto(round(humedadSuelo[i])+"%",
          1090, yy+65, 25,
          colorEstado(humedadSuelo[i]), true);

    texto(estado(humedadSuelo[i]),
          1210, yy+58, 13,
          colorEstado(humedadSuelo[i]), true);
  }

  dibujarRiego(295, 720, 740, 207);
  dibujarAlertas(1053, 720, 422, 207);
}

void dibujarHistorial() {
  dibujarGrafica(295, 151, 1180, 620);

  tarjeta(295, 790, 1180, 137);

  texto("Historial de lecturas",
        320, 827, 22, VERDE_OSCURO, true);

  texto("Se muestran las ultimas 40 muestras simuladas.",
        320, 862, 16, TEXTO, false);

  texto("Posteriormente se pueden almacenar en CSV.",
        320, 895, 14, GRIS, false);
}

void dibujarConfiguracion() {
  tarjeta(295, 151, 1180, 600);

  texto("Configuracion del sistema",
        320, 195, 25, ROJO, true);

  texto("Proyecto: LycoIoT",
        320, 250, 19, TEXTO, true);

  texto("Cultivo: Jitomate",
        320, 295, 18, TEXTO, false);

  texto("Cantidad de plantas: 4",
        320, 335, 18, TEXTO, false);

  texto("Sensor ambiental: DHT11",
        320, 375, 18, TEXTO, false);

  texto("Sensores de humedad del suelo: 4",
        320, 415, 18, TEXTO, false);

  texto("Microcontrolador previsto: ESP32",
        320, 455, 18, TEXTO, false);

  texto("Interfaz grafica: Processing",
        320, 495, 18, TEXTO, false);

  texto("Umbrales de demostracion:",
        320, 560, 19, VERDE_OSCURO, true);

  texto("Menor a 45%: alerta roja. De 45% a 54%: advertencia.",
        320, 600, 16, TEXTO, false);

  texto("Calibrar sensores y umbrales antes del uso real.",
        320, 645, 15, GRIS, false);
}


void simularLecturas() {
  temperatura = constrain(
    temperatura+random(-0.3, 0.3), 18, 35);

  humedadAire = constrain(
    humedadAire+random(-1, 1), 30, 90);

  for (int p = 0; p < 4; p++) {
    float cambio = riegoActivo ?
      random(0.2, 1.0) :
      random(-0.6, 0.3);

    humedadSuelo[p] = constrain(
      humedadSuelo[p]+cambio, 0, 100);

    for (int i = 0; i < MUESTRAS-1; i++) {
      historial[p][i] = historial[p][i+1];
    }

    historial[p][MUESTRAS-1] = humedadSuelo[p];
  }

  if (automatico) {
    boolean necesitaAgua = false;

    for (int i = 0; i < 4; i++) {
      if (humedadSuelo[i] < 45) {
        necesitaAgua = true;
      }
    }

    riegoActivo = necesitaAgua;
  }
}

void mousePressed() {

  // Navegacion
  for (int i = 0; i < 5; i++) {
    float y = 355+i*83;

    if (clic(16, y, 238, 65)) {
      pagina = i;
      return;
    }
  }

  // Seleccion de plantas en resumen
  if (pagina == 0 || pagina == 1) {
    float x = 868;
    float y = 151;
    float w = 607;
    float ancho = (w-55)/4;

    for (int i = 0; i < 4; i++) {
      float px = x+12+i*(ancho+10);

      if (clic(px, y+53, ancho, 108)) {
        plantaSeleccionada = i;
        return;
      }
    }
  }

  // Seleccion en detalle
  if (pagina == 2) {
    for (int i = 0; i < 4; i++) {
      if (clic(1073, 220+i*112, 380, 92)) {
        plantaSeleccionada = i;
        return;
      }
    }
  }

  // Botones de riego
  if (pagina == 0 || pagina == 2) {
    float ry = pagina == 0 ? 740 : 720;

    if (clic(595, ry+60, 235, 45)) {
      automatico = false;
      riegoActivo = !riegoActivo;
      return;
    }

    if (clic(595, ry+115, 235, 40)) {
      automatico = !automatico;

      if (automatico) {
        riegoActivo = false;
      }

      return;
    }
  }
}

void keyPressed() {
  if (key >= '1' && key <= '4') {
    plantaSeleccionada = key-'1';
  }

  if (keyCode == UP) {
    humedadSuelo[plantaSeleccionada] =
      min(100, humedadSuelo[plantaSeleccionada]+5);
  }

  if (keyCode == DOWN) {
    humedadSuelo[plantaSeleccionada] =
      max(0, humedadSuelo[plantaSeleccionada]-5);
  }
}
