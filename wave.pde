//  Vague Gerstner

class Wave {

  float amplitude;
  float wavelength;
  float frequency;
  PVector direction;
  float phase;

  Wave(float A, float lambda, float freq, PVector dir) {
    amplitude  = A;
    wavelength = lambda;
    frequency  = freq;
    direction  = dir.copy();
    direction.normalize();
    phase      = random(TWO_PI);
  }

  float heightAt(float x, float z, float t) {
    float k = TWO_PI / wavelength;
    float theta = k * (direction.x * x + direction.y * z) - frequency * t + phase;
    return amplitude * cos(theta);
  }
}
