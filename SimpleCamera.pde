// camera class
class SimpleCamera {
  float yaw = -0.5;    
  float pitch = 0.15; 
  float distance = 1500; 

  float rotSpeed = 0.012; 
  float zoomSpeed = 60;    

  SimpleCamera() {}

  void update() {
    if (mousePressed) {
      float dx = mouseX - pmouseX;
      float dy = mouseY - pmouseY;
      yaw += dx * rotSpeed;
      pitch -= dy * rotSpeed;
      // full freedom
      pitch = constrain(pitch, 0.001, PI - 0.001);
    }
    if (keyPressed) {
      if (key == 'w' || key == 'W') distance -= zoomSpeed;
      if (key == 's' || key == 'S') distance += zoomSpeed;
    }
    distance = max(20, distance); 
  }

  PVector getPosition() {
    float x = distance * sin(pitch) * sin(yaw);
    float y = distance * cos(pitch); 
    float z = distance * sin(pitch) * cos(yaw);
    return new PVector(x, y, z);
  }

  float getHeight() {
    return getPosition().y;
  }

  void apply() {
    PVector p = getPosition();
    camera(
      p.x, p.y, p.z, 
      0, 0, 0, 
      0, 1, 0 
    );
  }
}
