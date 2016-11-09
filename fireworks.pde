/*
Fireworks toy.
Click and drag to fire rockets.
press C to clear the screen.
*/
ArrayList<Body> world;

boolean dragging;
PVector click;

float phi = 1.61803398875;

boolean sel;
int next;

void setup(){
  size(800, 600, FX2D);
  surface.setResizable(true);
  world = new ArrayList();
  colorMode(HSB, 100);
}
void draw(){
  background(0);
  for( int i = world.size()-1; i >= 0; i-- ){
    world.get(i).addForce(0, 0.02);
    if( world.get(i).tick() ) world.remove( i );
  }
  if( dragging ){
    noCursor();
    strokeWeight( 4 );
    stroke( 0, 127, 255 );
    fill( 0, 127, 255 );
    line( mouseX, mouseY, click.x, click.y );
    pushMatrix();
    translate(mouseX, mouseY);
    rotate( atan2(click.y - mouseY, click.x - mouseX ) );
    beginShape();
    vertex( 0, 0 );
    vertex( 6, -3 );
    vertex( 6, 3 );
    endShape(CLOSE);
    popMatrix();
  }
  else cursor( ARROW );
}

void mousePressed(){
  dragging = true;
  click = new PVector( mouseX, mouseY );
}
void mouseReleased(){
  IntList col = new IntList();
  int N = round(random( 0.501, 5.499 ) );
  for( int i = 0; i < N; i++ ) col.append( color(random(100), 100, 100 ));
  float k = 0.08;
  int type = -1;
  if( sel ){
    type = next;
    sel = false;
  }
  else{
    type = round(random(-0.499, 6.499));
  }
  world.add( new Rocket( click.x, click.y, k*(mouseX-click.x), k*(mouseY-click.y), 6, 60, type, col ) );
  dragging = false;
}
void keyPressed(){
  if( key == 'c' || key == 'C' ) world = new ArrayList();
  else if( key == '1' || key == '2' || key == '3' || 
           key == '4' || key == '5' || key == '6' || 
           key == '7' || key == '8' || key == '9' || 
           key == '0' ){
             next = int(key)-48;
             sel = true;
           }
  if( key == 'p' || key == 'P' ) save("print "+year()+"-"+month()+"-"+day()+" "+hour()+"."+minute()+"."+second()+".jpg");
}

//##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+||||
//##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+||||
class Body{
  PVector pos, vel;
  float mass;
  Body(){}
  Body( PVector p, PVector v ){
    pos = p.get();
    vel = v.get();
    mass = 1;
  }
  Body(float x, float y, float vx, float vy){
    pos = new PVector( x, y );
    vel = new PVector( vx, vy );
    mass = 1;
  }
  void addForce( float vx, float vy ){
    PVector acc = new PVector( vx, vy );
    acc.setMag(acc.mag()*mass);
    vel.add( acc );
  }
  void addForce( PVector force ){
    PVector acc = force.setMag(force.mag()*mass).get();
    vel.add( acc ); 
  }
  void move(){
    pos.add( vel );
  }
  void display(){}
  
  boolean tick(){
    this.move();
    this.display();
    return false;
  }
}
//##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+||||
//##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+||||
class Rocket extends Body{
  float fuse;
  int pattern_ID;
  IntList colors;
  
  Rocket(float x, float y, float vx, float vy, float m, float f, int pid, IntList c){
    super( x, y, vx, vy );
    mass = m;
    fuse = f;
    pattern_ID = pid;
    colors = c;
  }
  void display(){
    pushMatrix();
    translate( pos.x, pos.y );
    scale( 0.3 );
    rotate( vel.heading() );
    
    noStroke();
    fill( colors.get(0) );
    
    beginShape();
    vertex(-20, -10);
    vertex(-30, -20);
    vertex(-50, -20);
    vertex(-40, -10);
    vertex(-40, 10);
    vertex(-50, 20);
    vertex(-30, 20);
    vertex(-20, 10);
    vertex(20, 10);
    vertex(20, 20);
    vertex(50, 0);
    vertex(20, -20);
    vertex(20, -10);
    endShape(CLOSE);
    
    popMatrix();
  }
  boolean tick(){
    if( fuse <= 0 ){
      generate_particles( pos, pattern_ID, colors );
      return true;
    }
    else{
      fuse--;
      this.move();
      this.display();
      return false;
    }
  }
}
//##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+||||
//##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+||||
class Particle extends Body{
  color c;
  Particle( PVector p, PVector v, color c ){
    super( p, v );
    this.c = c;
    mass = random(0.85, 1.15);
  }
  Particle( PVector p, PVector v, float m, color c ){
    super( p, v );
    this.c = c;
    mass = m;
  }
  Particle(float x, float y, float vx, float vy, color c ){
    super( x, y, vx, vy );
    this.c = c;
    mass = random(0.85, 1.15);
  }
  void display(){
    stroke( c );
    if( random(60) <= 2 )  strokeWeight(6);
    else strokeWeight(3);
    point( pos.x, pos.y );
  }  
  boolean tick(){
    this.move();
    this.display();
    if( pos.x < width && pos.x > 0 && pos.y < height ) return false;
    else return true;
  }
}
//##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+||||
//##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+||||
class fallingStar extends Body{
  color c;
  fallingStar( PVector p, PVector v, color c ){
    super( p, v );
    this.c = c;
    mass = 1.5;
  }
  fallingStar(float x, float y, float vx, float vy, color c ){
    super( x, y, vx, vy );
    this.c = c;
    mass = 1.5;
  }
  void display(){
    stroke( c );
    strokeWeight(8);
    point( pos.x, pos.y );
  }  
  boolean tick(){
    this.move();
    this.display();
    int N = constrain(round(random( -8, 2.499 ) ), 0, 2);
    for( int i = 0; i < N; i++ ){
      float a = random( -PI, PI );
      float v = random( 0.02, 0.8 );
      world.add( new Particle( pos, new PVector( v*cos(a), v*sin(a) ), c ) );
    }
    if( pos.x < width && pos.x > 0 && pos.y < height ) return false;
    else return true;
  }
}
//##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+||||
//##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+||||
class Spinner extends Body{
  color c;
  float a;
  float k;
  float cooldown;
  Spinner( PVector p, PVector v, color c ){
    super( p, v );
    this.c = c;
    k = (random(10) > 5 )? 1 : -1;
    mass = 3;
  }
  Spinner(float x, float y, float vx, float vy, color c ){
    super( x, y, vx, vy );
    this.c = c;
    k = (random(10) > 5 )? 1 : -1;
    mass = 3;
  }
  void display(){
    stroke( c );
    strokeWeight(8);
    point( pos.x, pos.y );
  }  
  boolean tick(){
    this.move();
    this.display();
    
    if( cooldown <= 0 ){
      float v = 3;
      world.add( new Particle( pos, new PVector( v*cos(a) + vel.x, v*sin(a) + vel.y ), 1, c ) );
      float q = random(0, 1);
      cooldown = q * 2;
      a += k * q * (PI/4f);
    }
    else cooldown--;

    if( pos.x < width && pos.x > 0 && pos.y < height ) return false;
    else return true;
  }
}
//##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+||||
//##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+||||
class ellipseBomb extends Body{
  color c;
  float fuse;
  ellipseBomb( PVector p, PVector v, color c ){
    super( p, v );
    this.c = c;
    mass = 4;
    fuse = random(20, 45);
  }
  ellipseBomb(float x, float y, float vx, float vy, color c ){
    super( x, y, vx, vy );
    this.c = c;
    mass = 4;
    fuse = random(20, 45);
  }
  void display(){
    stroke( c );
    strokeWeight(8);
    point( pos.x, pos.y );
  }  
  boolean tick(){
    this.move();
    this.display();
    
    if( fuse <= 0 ){
      elliptical_wave(pos, 60, 2, random(TWO_PI), 2, c );
      burst(pos, 18, c, 3, 10);
      return true;
    }
    else fuse--;

    return false;
  }
}
//##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+||||
//##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+||||
class Splitter extends Body{ // terrible idea.
  color c;
  float fuse;
  Splitter( PVector p, PVector v, color c ){
    super( p, v );
    this.c = c;
    mass = 0;
    fuse = 40;
  }
  Splitter(float x, float y, float vx, float vy, color c ){
    super( x, y, vx, vy );
    this.c = c;
    mass = 0;
    fuse = 40;
  }
  void display(){
    stroke( c );
    strokeWeight(5);
    point( pos.x, pos.y );
  }  
  boolean tick(){
    this.move();
    this.display();
    
    if( fuse <= 0 ){
      //world.add( new Splitter( pos, vel.rotate( PI/3f ).get(), c ) );
      //world.add( new Splitter( pos, vel.rotate( -PI/3f ).get(), c ) );
      float a = vel.heading() + PI/12f;
      world.add( new Splitter( pos, new PVector( 2*cos(a), 2*sin(a) ), c ) );
      a = vel.heading() - PI/12f;
      world.add( new Splitter( pos, new PVector( 2*cos(a), 2*sin(a) ), c ) );
      //burst(pos, 6, c, 3, 10);
      return true;
    }
    else fuse--;

    return false;
  }
}

//##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+||||
//##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+##+||||
class BlackHole extends Body{
  float size;
  BlackHole( PVector p){
    super( p, new PVector(0, 0) );
    mass = 0;
    size = random( 60, 100 );
  }
  void display(){
    stroke( 100 );
    strokeWeight(1);
    fill(0);
    ellipse( pos.x, pos.y, size/3f, size/3f );
  }  
  boolean tick(){
    this.move();
    this.display();
    
    float s = size/6f;
    for( int i = world.size()-1; i >= 0; i-- ){
      float D = pos.dist( world.get(i).pos );
      if( D > s ){
        PVector g = new PVector( 1, 0 );
        g.rotate( atan2(pos.y - world.get(i).pos.y, pos.x - world.get(i).pos.x ) );
        g.setMag( size * world.get(i).mass / sq(D) );
        world.get(i).addForce( g );
      }
      else if ( D > 0.1 ){
        size += 1.2*world.get(i).mass;
        world.get(i).pos.x = width*2;
      }
      
    }
    
    if( size <= 0 ){
      return true;
    }
    else size -= constrain( random( -1, 0.8 ), 0, 1 );

    return false;
  }
}
//88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
//88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
void generate_particles( PVector pos, int pattern_ID, IntList colors ){
  switch( pattern_ID ){
    case 0:
      burst(pos, round(random(200, 300)), colors, 0.2, 6);
      break;
    case 1:
      {
        int N = round(random( 12, 24 ) );
        for( int i = 0; i < N; i++ ){
          float a = random( -PI, PI );
          float v = random( 2.5, 3.5 );
          world.add( new fallingStar( pos, new PVector( v*cos(a), v*sin(a) ), colors.get(round(random( -0.499, colors.size()-0.501 ))) ) );
        }
      }
      break;
    case 2:
      {
        int N = round(random( 12, 24 ) );
        float v = random( 2, 4.5 );
        for( int i = 0; i < N; i++ ){
          float a = TWO_PI*(i/float(N));
          world.add( new fallingStar( pos, new PVector( v*cos(a), v*sin(a) ), colors.get(round(random( -0.499, colors.size()-0.501 ))) ) );
        }
      }
      break;
    case 3:
      {
        int N = round(random( 4, 8 ) );
        for( int i = 0; i < N; i++ ){
          float a = random( -PI, PI );
          float v = random( 1, 4 );
          world.add( new Spinner( pos, new PVector( v*cos(a), v*sin(a) ), colors.get(round(random( -0.499, colors.size()-0.501 ))) ) );
        }
        burst(pos, 24, colors, 3, 10);
      }
      break;
    case 4:
      elliptical_wave(pos, 100, 1, 0, 2, colors);
      elliptical_wave(pos, 100, 1, -PI/3f, 2, colors);
      elliptical_wave(pos, 100, 1, PI/3f, 2, colors);
      burst(pos, 24, colors, 3, 10);
      break;
    case 5:
      {
        int N = int(round(random( 12, 24 ) )*12);
        float a = 0;
        float rate = PI / phi*round(random( 0.501, 12.499 ));
        for( int i = 0; i < N; i++ ){
          a += rate;
          float v = map( i, 0, N, 0.5*phi, 2*phi );
          world.add( new Particle( pos, new PVector( v*cos(a), v*sin(a) ), colors.get(round(random( -0.499, colors.size()-0.501 ))) ) );
        }
      }
      break;
    case 6:
      {
        int N = round(random( 6, 12 ) );
        for( int i = 0; i < N; i++ ){
          float a = random( -PI, PI );
          float v = random( 4, 8 );
          world.add( new ellipseBomb( pos, new PVector( v*cos(a), v*sin(a) ), colors.get(round(random( -0.499, colors.size()-0.501 ))) ) );
        }
      }
      break;
    case 7:
      world.add( new BlackHole( pos ) );
      /*
    case 7:
      {
        int N = round(random( 9.501, 20.499 ) );
        float v = random( 1, 4 );
        for( int i = 0; i < N; i++ ){
          float a = TWO_PI*(i/float(N));
          world.add( new Splitter( pos, new PVector( v*cos(a), v*sin(a) ), colors.get(round(random( -0.499, colors.size()-0.501 ))) ) );
        }
      }
      break;
      */
    case 65:
      {
        float[] x = { -4.08, 4.08, 2.448, 0.81600004, -0.81600004, -2.4479997, -9.84, -4.64, -5.0733333, -5.5066667, -5.94, -6.3733335, -6.806666, -7.24, -7.673333, -8.106667, -8.54, -8.973333, -9.406667, -10.32, -8.533333, -6.746666, -2.24, -4.48, -3.9199998, -3.36, -2.8, -2.24, 2.32, 0.96, -0.79999995, 4.3199997, 3.04, 3.36, 3.6799998, 4.0, 9.84, 5.44, 7.64, 9.84, 4.48, 9.12, 8.698181, 8.276363, 7.854545, 7.432727, 7.0109086, 6.5890903, 6.167273, 5.745454, 5.3236365, 4.901818, 0.0, -2.1599998, -1.62, -1.0799999, -0.53999996, 2.32, 0.48, 1.0933334, 1.7066667, -0.88, 1.04 };
        float[] y = { -9.5199995, -9.5199995, -9.5199995, -9.5199995, -9.5199995, -9.5199995, 10.48, -8.16, -6.606666, -5.053333, -3.5, -1.9466662, -0.39333373, 1.16, 2.7133324, 4.2666674, 5.8199997, 7.3733325, 8.926667, 11.679999, 11.626666, 11.573334, 4.0, 11.36, 9.5199995, 7.68, 5.8399997, 4.0, 3.52, 3.36, 3.36, 11.5199995, 3.76, 5.7, 7.64, 9.58, 11.599999, 11.36, 11.48, 11.599999, -8.639999, 9.84, 8.16, 6.48, 4.7999997, 3.12, 1.4399999, -0.24, -1.92, -3.6, -5.2799997, -6.96, -6.24, 0.32, -1.3199999, -2.96, -4.6, 0.39999998, -4.72, -3.013333, -1.3066665, 0.32, 0.32 };
        for( int i = 0; i < x.length; i++ ){
          world.add( new Particle( pos, new PVector( x[i], y[i] ), colors.get(round(random( -0.499, colors.size()-0.501 ))) ) );
        }
      }
      break;
    case 72:
      {
        float[] x = { -3.6399999, -3.6399999, -3.6399999, -3.6399999, -3.6399999, -3.6399999, -3.6399999, -3.6399999, -3.6399999, -3.6399999, -3.6399999, -3.6399999, -3.6399999, -3.6399999, 3.6, -3.6399999, -2.8355553, -2.031111, -1.2266666, -0.4222223, 0.3822223, 1.1866668, 1.9911114, 2.7955554, 3.9599998, 3.9599998, 3.9599998, 3.9599998, 3.9599998, 3.9599998, 3.9599998, 3.9599998, 3.9599998, 3.9599998, 3.9599998, 3.9599998, 3.9599998, 3.9599998, 3.9599998 };
        float[] y = { 5.6, -5.3599997, -4.516923, -3.673846, -2.830769, -1.9876922, -1.1446152, -0.30153838, 0.54153866, 1.3846154, 2.2276921, 3.0707695, 3.9138463, 4.756923, 0.04, -0.08, -0.06666666, -0.053333327, -0.04, -0.026666664, -0.01333333, 0.0, 0.013333339, 0.02666667, 5.92, -5.7999997, -4.962857, -4.125714, -3.2885714, -2.4514284, -1.6142856, -0.77714294, 0.06, 0.89714295, 1.7342858, 2.5714288, 3.408571, 4.245714, 5.082856 };
        for( int i = 0; i < x.length; i++ ){
          world.add( new Particle( pos, new PVector( x[i], y[i] ), colors.get(round(random( -0.499, colors.size()-0.501 ))) ) );
        }
      }
      break;
    case 2017:
      {
        float[] x = { -8.0, -11.639999, -10.73, -9.82, -8.91, -7.8399997, -7.96, -7.9199996, -7.8799996, -11.639999, -7.8399997, -8.79, -9.74, -10.69, -11.559999, -11.639999, -11.613334, -11.586666, -7.7999997, -11.04, -10.23, -9.42, -8.61, -6.72, -6.8399997, -6.826667, -6.813333, -6.7999997, -6.786667, -6.773333, -6.7599998, -6.746667, -6.733333, -2.3999999, -6.72, -5.8559995, -4.992, -4.128, -3.264, -2.52, -2.76, -2.7333333, -2.7066665, -2.6799998, -2.6533334, -2.6266665, -2.6, -2.5733333, -2.5466666, -2.9199998, -6.64, -5.71, -4.7799997, -3.85, -0.44, -0.39999998, -0.40444443, -0.40888888, -0.4133333, -0.41777778, -0.4222222, -0.42666668, -0.4311111, -0.43555558, -1.5999999, -0.44, -0.8266667, -1.2133334, 11.24, 0.76, 1.5661539, 2.3723078, 3.1784616, 3.9846153, 4.790769, 5.596923, 6.403077, 7.209231, 8.015385, 8.821539, 9.627692, 10.433846, 3.56, 11.2, 10.750588, 10.301176, 9.851765, 9.402352, 8.952941, 8.503529, 8.054117, 7.604706, 7.155294, 6.7058825, 6.25647, 5.807059, 5.357647, 4.9082355, 4.458823, 4.0094113, 11.0, 3.4399998, 4.2799997, 5.12, 5.96, 6.7999997, 7.64, 8.48, 9.32, 10.16 };
        float[] y = { -4.96, -4.8399997, -4.87, -4.9, -4.93, -1.56, -4.3199997, -3.3999999, -2.48, -0.76, -0.79999995, -0.78999996, -0.78, -0.77, 2.6799998, -0.12, 0.81333333, 1.7466667, 2.6, 2.6799998, 2.6599998, 2.6399999, 2.62, 2.44, -5.12, -4.2799997, -3.4399998, -2.6, -1.76, -0.91999966, -0.08, 0.76, 1.5999999, 2.56, 2.52, 2.5279999, 2.536, 2.544, 2.5519998, 2.28, -5.64, -4.7599998, -3.8799999, -3.0, -2.12, -1.2399997, -0.35999998, 0.52, 1.4, -5.64, -5.16, -5.2799997, -5.4, -5.52, -5.7599998, 1.8399999, 0.9955556, 0.15111114, -0.69333345, -1.5377777, -2.3822222, -3.2266667, -4.071111, -4.9155555, -3.0, -5.7599998, -4.8399997, -3.9199998, -6.04, -5.96, -5.9661536, -5.9723077, -5.9784613, -5.9846153, -5.990769, -5.996923, -6.0030766, -6.0092306, -6.015384, -6.0215387, -6.0276923, -6.0338464, 5.48, -6.04, -5.362353, -4.6847057, -4.0070586, -3.3294115, -2.6517644, -1.9741174, -1.2964706, -0.61882323, 0.05882385, 0.73647094, 1.414118, 2.0917652, 2.7694116, 3.4470587, 4.124706, 4.8023534, -1.8399999, -1.76, -1.7688888, -1.7777777, -1.7866666, -1.7955556, -1.8044444, -1.8133333, -1.8222222, -1.8311111 };
        for( int i = 0; i < x.length; i++ ){
          world.add( new Particle( pos, new PVector( x[i], y[i] ), colors.get(round(random( -0.499, colors.size()-0.501 ))) ) );
        }
      }
      break;
      default:
        world.add( new Particle( pos, new PVector( 0, 0), color( 255 ) ) );
        break;
  }
}

//88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
void burst( PVector pos, int N, IntList colors, float min, float max ){
  for( int i = 0; i < N; i++ ){
    float a = random( -PI, PI );
    float v = random( min, max );
    world.add( new Particle( pos, new PVector( v*cos(a), v*sin(a) ), colors.get(round(random( -0.499, colors.size()-0.501 ))) ) );
  }
}
void burst( PVector pos, int N, color c, float min, float max ){
  for( int i = 0; i < N; i++ ){
    float a = random( -PI, PI );
    float v = random( min, max );
    world.add( new Particle( pos, new PVector( v*cos(a), v*sin(a) ), c ) );
  }
}
void elliptical_wave( PVector pos, int N, float v, float theta, float b, IntList colors ){
  for( int i = 0; i < N; i++ ){
    float a = TWO_PI*( i / float(N) );
    float c = cos(theta);
    float s = sin(theta);    
    float vx = v * ( cos(a)*c - b*sin(a)*s );// + random(-0.015, 0.015);     
    float vy = v * ( cos(a)*s + b*sin(a)*c );// + random(-0.015, 0.015);
    world.add( new Particle( pos, new PVector( vx, vy ), colors.get(round(random( -0.499, colors.size()-0.501 ))) ) );
    //float v = sq(sin( map( i, 0, N, 0, TWO_PI) ) ) + vel;//-QUARTER_PI, 3.5*PI 
  }
}
void elliptical_wave( PVector pos, int N, float v, float theta, float b, color co ){
  for( int i = 0; i < N; i++ ){
    float a = TWO_PI*( i / float(N) );
    float c = cos(theta);
    float s = sin(theta);    
    float vx = v * ( cos(a)*c - b*sin(a)*s );
    float vy = v * ( cos(a)*s + b*sin(a)*c );
    world.add( new Particle( pos, new PVector( vx, vy ), co ) );
    //float v = sq(sin( map( i, 0, N, 0, TWO_PI) ) ) + vel;//-QUARTER_PI, 3.5*PI 
  }
}