//  OceanMesh grille uniforme + filtrage perceptuel

class OceanMesh {

  int cols, rows;
  float width, depth;

  PVector[][] verts;
  PVector[][] normals;

  OceanMesh(int cols, int rows, float width, float depth) {
    this.cols = cols;
    this.rows = rows;
    this.width = width;
    this.depth = depth;

    verts   = new PVector[cols][rows];
    normals = new PVector[cols][rows];

    initGrid();
  }

  // Grille régulière centrée sur l'origine
  void initGrid() {
    float dx = width  / (cols - 1);
    float dz = depth  / (rows - 1);

    for (int j = 0; j < rows; j++) {
      for (int i = 0; i < cols; i++) {
        float x = -width/2  + i * dx;
        float z = -depth/2  + j * dz;
        verts[i][j]   = new PVector(x, 0, z);
        normals[i][j] = new PVector(0, 1, 0);
      }
    }
  }

  // Update : Gerstner + filtrage perceptuel
  void update(ArrayList<Wave> waves, float t, SimpleCamera cam) {

    PVector camPos = cam.getPosition();
    float camH = abs(camPos.y);

    // seuil de coupure en fonction de la hauteur de la caméra
    float minLambda = map(camH, 10, 300, 8, 90);
    minLambda = constrain(minLambda, 8, 90);
    float maxLambda = minLambda * 1.6;

    //Hauteurs
    for (int j = 0; j < rows; j++) {
      for (int i = 0; i < cols; i++) {
        PVector v = verts[i][j];
        float h = 0;

        for (Wave w : waves) {
          float fade = smoothstep(minLambda, maxLambda, w.wavelength);
          if (fade <= 0.001) continue;
          h += fade * w.heightAt(v.x, v.z, t);
        }
        v.y = h;
      }
    }
    //Normales analytiques
    computeNormals(waves, t, minLambda, maxLambda);
  }

  void computeNormals(ArrayList<Wave> waves, float t, float minLambda, float maxLambda) {

    for (int j = 0; j < rows; j++) {
      for (int i = 0; i < cols; i++) {

        PVector v = verts[i][j];

        float dYdX = 0;
        float dYdZ = 0;

        for (Wave w : waves) {
          float fade = smoothstep(minLambda, maxLambda, w.wavelength);
          if (fade <= 0.001) continue;

          float k = TWO_PI / w.wavelength;
          float theta = k * (w.direction.x * v.x + w.direction.y * v.z)
                        - w.frequency * t + w.phase;

          float s = sin(theta);

          dYdX += fade * w.amplitude * k * s * w.direction.x;
          dYdZ += fade * w.amplitude * k * s * w.direction.y;
        }

        PVector n = new PVector(-dYdX, 1.0, -dYdZ);
        n.normalize();
        normals[i][j].set(n);
      }
    }
  }

  // Affichage
  void display() {
    noStroke();

    for (int j = 0; j < rows - 1; j++) {
      beginShape(TRIANGLE_STRIP);
      for (int i = 0; i < cols; i++) {

        // rangée j
        PVector v1 = verts[i][j];
        PVector n1 = normals[i][j];
        fill( oceanColor(v1, n1) );
        normal(n1.x, n1.y, n1.z);
        vertex(v1.x, v1.y, v1.z);

        // rangée j+1
        PVector v2 = verts[i][j+1];
        PVector n2 = normals[i][j+1];
        fill( oceanColor(v2, n2) );
        normal(n2.x, n2.y, n2.z);
        vertex(v2.x, v2.y, v2.z);
      }
      endShape();
    }
  }

  // Shading= base + Fresnel + spec
  color oceanColor(PVector v, PVector n) {

    // couleur base selon hauteur + profondeur
    float hT = map(v.y, -20, 20, 0, 1);
    hT = constrain(hT, 0, 1);

    color deep    = color(  5,  25,  80);
    color shallow = color( 40, 130, 210);
    color base = lerpColor(deep, shallow, hT);
    float zT = map(v.z, -depth/2, depth/2, 0, 1);
    zT = constrain(zT, 0, 1);
    color horizon = color( 10,  30,  70);
    base = lerpColor(base, horizon, zT * 0.25);

    PVector camPos = cam.getPosition();
    PVector V = PVector.sub(camPos, v);
    V.normalize();

    PVector L = new PVector(-0.25, -0.8, -0.35);
    L.normalize();

    // Blinn Phong : H = (L+V)/||L+V||
    PVector H = PVector.add(L, V);
    H.normalize();

    float NdotH = max(0, n.dot(H));
    float spec = pow(NdotH, 180.0);  

    float NdotV = max(0, n.dot(V));
    float fresnel = pow(1.0 - NdotV, 5.0);

    //reflexion soleil
    color c = base;
    c = lerpColor(c, color(255, 255, 255), spec * 1.0);
    c = lerpColor(c, color(200, 230, 255), fresnel * 0.7);

    return c;
  }
}
