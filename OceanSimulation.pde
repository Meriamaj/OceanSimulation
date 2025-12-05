OceanMesh ocean;
ArrayList<Wave> waves;
SimpleCamera cam;

float time = 0.0;

void setup() {
  size(1280, 720, P3D);
  smooth(8);
  perspective(PI/3.0, width/(float)height, 1, 5000);
 // perspective(PI/3.0, width/(float)height, 1, 5000);
  cam = new SimpleCamera();
  initWaves();
  ocean = new OceanMesh(140, 110, 900, 900);
}


void draw() {

  background(135, 206, 255); //light blue
  noLights();

  cam.update();
  cam.apply();

  time += 0.016;  // presque 60 fps

  ocean.update(waves, time, cam);
  ocean.display();

  drawOverlay();
}

// HUD / TEXTE
void drawOverlay() {
  hint(DISABLE_DEPTH_TEST);
  camera();          
  noLights();

  fill(0, 0, 0, 170);
  noStroke();
  rect(15, 15, 280, 100, 12);

  fill(100, 200, 255);
  textAlign(LEFT, TOP);
  textSize(16);
  text("Real-Time Ocean (Gerstner)", 28, 22);

  fill(255);
  textSize(13);
  text("FPS     : " + nf(frameRate, 2, 1),      28, 46);
  text("Height  : " + nf(cam.getHeight(), 1, 1) + " m", 28, 64);
  text("Waves   : " + waves.size(),            28, 82);

  hint(ENABLE_DEPTH_TEST);
}

// gestion vagues 3 bandes  grosse / moyenne / fine
void initWaves() {
  waves = new ArrayList<Wave>();
  
  for (int i = 0; i < 6; i++) {
    waves.add(createWave(2.5, 4.5, 140, 260));
  }

  // Vagues moyennes
  for (int i = 0; i < 6; i++) {
    waves.add(createWave(0.9, 2.0, 50, 120));
  }

  // Micro-vagues
  for (int i = 0; i < 6; i++) {
    waves.add(createWave(0.15, 0.5, 8, 25));
  }
}

Wave createWave(float A_min, float A_max, float L_min, float L_max) {
  float A = random(A_min, A_max);
  float lambda = random(L_min, L_max);
  // dispersion deep water w = sqrt(g * k)
  float freq = sqrt(9.81 * TWO_PI / lambda);

  float ang = random(TWO_PI);
  PVector dir = new PVector(cos(ang), sin(ang));

  return new Wave(A, lambda, freq, dir);
}

// Smoothstep (style GLSL)
float smoothstep(float edge0, float edge1, float x) {
  x = constrain((x - edge0) / (edge1 - edge0), 0, 1);
  return x * x * (3 - 2 * x);
}
