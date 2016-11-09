ArrayList<PVector> list;
float cx, cy;
float k = 0.04, e = 20;
boolean dragging;
PVector click;

void setup(){
  size(600, 600);
  cx = width/2f;
  cy = height/2f;
  list = new ArrayList();
}
void draw(){
  background(0);
  translate( cx, cy );
  stroke( 255 );
  line( 0, -cy, 0, cy );
  line( -cx, 0, cx, 0 );
  for( int i = 0; i < list.size(); i++ ){
    ellipse( list.get(i).x, list.get(i).y, 4, 4 );
  }
  if( dragging ){
    line( mouseX-cx, mouseY-cy, click.x, click.y );
  }
}

void keyPressed(){
  if( key == 'c' || key == 'C' ) list = new ArrayList();
  if( key == 'p' || key == 'P' ){
    String x = "";
    String y = "";
    for( int i = 0; i < list.size()-1; i++ ){
      x += str( list.get(i).x * k ) + ", ";
      y += str( list.get(i).y * k ) + ", ";
    }
    x += str( list.get(list.size()-1).x * k );
    y += str( list.get(list.size()-1).y * k );
    println("\tfloat[] x = { "+ x +" };\n\tfloat[] y = { "+ y +" };\n\tfor( int i = 0; i < x.length; i++ ){\n\t\tworld.add( new Particle( pos, new PVector( x[i], y[i] ), colors.get(round(random( -0.499, colors.size()-0.501 ))) ) );\n\t}");
  }
}

void mousePressed(){
  dragging = true;
  click = new PVector( mouseX - cx, mouseY - cy );
}

void mouseReleased(){
  PVector Mouse = new PVector( mouseX - cx, mouseY - cy );
  if( mouseButton == LEFT ){
    list.add( Mouse.get() );
    float D = Mouse.dist( click );
    if( D > e ){
      int N = floor( D / e );
      for(  int i = 0; i < N; i++ ){
        float iN = i / float(N);
        list.add( new PVector( lerp(click.x, Mouse.x, iN), lerp(click.y, Mouse.y, iN) ) );
      }
    }
    dragging = false;
  }
  else{
    for( int i = 0; i < list.size(); i++ ){
      if( Mouse.dist( list.get(i) ) < 6 ){
        list.remove(i);
        break;
      }
    }
  }
}