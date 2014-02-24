import javax.swing.*; 

import controlP5.*;
ControlP5 cp5;

PImage img;
int imgX, imgY;
String save_path, file_name;
boolean file_picked = false;

int paper_size = 1; // Can be 1, 2, 3

int EstartX = 20, EstartY = 70;
int Ep3sizeX = 264, Ep3sizeY = 178;
int Ep2sizeX = 200, Ep2sizeY = 96;
int Ep1sizeX = 128, Ep1sizeY = 96;

int mX = 1;

final static String ICON  = "App Logo.png";

boolean running = false;
 PFont font = createFont("arial",10);

public void Browser(int theValue) {
  if (running == true){  
    file_picked = true;
  }
}

void setup() {  
  size(340, 260);
  changeAppIcon(loadImage(ICON));
  draw_paper(paper_size);
 
  
  cp5 = new ControlP5(this);
  
  cp5.addButton("Browser")
   .setValue(0)
   .setPosition(230,30)
   .setColorBackground(color(98))
   .setSize(75,25)
   //.setSwitch(true)
   ;
   
  cp5.addTextfield("File Path")
   .setPosition(20,30)
   .setSize(200,25)
   .setFont(font)
   .setColor(color(0,0,0))
   .setColorCaptionLabel(255)
   .setColorBackground(color(255)) 
   .setAutoClear(false)
   .setLock(true)
   .setMouseOver(false)
   ;
   
   running = true;
   textFont(font);
   fill(0);
   text("> Choose a file to convert", 20,20);
}

void draw() {
  if (file_picked == true){
    file_name = pick_file();
    println("File Picked");
    img = loadImage(file_name);
    imgX = img.width;
    imgY = img.height;
    //size (imgX,imgY);
   
    convert_image();
    println("Set to " + paper_size);
    draw_paper(paper_size);
    image(img, EstartX, EstartY, imgX*mX, imgY*mX); 
    file_picked = false;
    clear_box();
    textFont(font);
    fill(color(0,0,255));
    text("> Image converted and saved to directory", 20,20);
  }
}

void convert_image(){
byte[] XBM = new byte[imgX*imgY/8];  

int bit_counter = 0;
for (int j = 0; j < imgY; j++){
      for (int i = 0; i < imgX; i++){
        if (img.pixels[j*imgX+i]== 0xFFFFFFFF ){
            //white
            XBM[bit_counter/8] = byte(XBM[bit_counter/8] | 0 << bit_counter%8);
        }else{
            //black
            XBM[bit_counter/8] = byte(XBM[bit_counter/8] | 1 << bit_counter%8);
        }
        bit_counter++;
      }
  }  
  
  String img_header, img_size, img_name;
  int file_size, num_rows;
  
  if (imgX == 128){
    img_header = "_1_44_";
    img_size = "_1_44_bits";
    img_name = "_1_44.xbm";
    file_size = 131 ;
    num_rows = 127;
    paper_size = 1;
  }else if(imgX == 200){
    img_header = "_2_0_";
    img_size = "_2_0_bits";
    img_name = "_2_0.xbm";
    file_size= 203;
    num_rows = 199;
    paper_size = 2;
  }else{
    img_header = "_2_7_";
    img_size = "_2_7_bits"; 
    img_name = "_2_7.xbm";
    file_size= 487;
    num_rows = 483;
    paper_size = 3;
  }
  
  String[] lines = new String[file_size]; // 131, 203, 487
  lines[0] = "#define jaycon"+img_header+"width " + imgX;
  lines[1] = "#define jaycon"+img_header+"height " +imgY;
  lines[2] = "static unsigned char jaycon"+ img_size +"[] = {"; // _1_44_bits, _2_0_bits, _2_7_bits
  
  int byte_counter = 0;
  for (int row = 0; row < (num_rows+1); row ++){
    for (int col = 0; col < 12; col++){
      if (row == (num_rows) && col == 11) // 127, 199, 484
        lines[row+3] += "0x" + hex(XBM[byte_counter]) + " };"; // Puts Lines End
      else if (col == 0)
        lines[row+3] = "   0x" + hex(XBM[byte_counter]) + ", "; // First Entry in the row
      else if (col == 11)
        lines[row+3] += "0x" + hex(XBM[byte_counter]) + ",";  // Last Entry in the row
      else
        lines[row+3] += "0x" + hex(XBM[byte_counter]) + ", "; // All Others
      
      byte_counter++;
    }
  }
  
  //saveStrings("jaycon"+img_name, lines);
  String[] list = split(file_name, '.');
  
  println(list[0] + img_name);
  saveStrings(list[0] + img_name, lines);
  
  println("Done");
}

String pick_file(){
  try { 
  UIManager.setLookAndFeel(UIManager.getSystemLookAndFeelClassName()); 
  } catch (Exception e) { 
  e.printStackTrace();  
 
  } 
    // create a file chooser 
  final JFileChooser fc = new JFileChooser(); 
   
  // in response to a button click: 
  int returnVal = fc.showOpenDialog(this); 
  
  if (returnVal == JFileChooser.APPROVE_OPTION) { 
    File file = fc.getSelectedFile(); 
    if (file.getName().endsWith("png")) { 
      save_path = file.getParentFile().toString();
      cp5.get(Textfield.class,"File Path").setText(file.getPath());
      return file.getPath();
    }
  }
  return null;
}

void draw_paper(int Esize){
  background(#888888); // Border Color
  fill(#EEEEEE); // Window Color
  rect(5, 5, 330, 250);
  
  stroke(0);
  if (Esize == 1){
    //epaper
    fill(#222222);
    rect(EstartX,EstartY,264*mX,176*mX);
    rect(EstartX,EstartY,200*mX,96*mX);
    stroke(255);
    fill(#FFFFFF);
    rect(EstartX,EstartY,128*mX,96*mX);
  }else if (Esize == 2){  
    //epaper
    fill(#222222);
    rect(EstartX,EstartY,264*mX,176*mX);
    stroke(255);
    fill(#FFFFFF);
    rect(EstartX,EstartY,200*mX,96*mX);
  }else{ 
    //epaper
    stroke(255);
    fill(#FFFFFF);
    rect(EstartX,EstartY,264*mX,176*mX);
  }
}

void clear_box(){
  fill(#EEEEEE); // Window Color
  stroke(#EEEEEE);
  rect(5, 5, 330, 30);
}

void changeAppIcon(PImage img) {
  final PGraphics pg = createGraphics(16, 16, JAVA2D);

  pg.beginDraw();
  pg.image(img, 0, 0, 16, 16);
  pg.endDraw();

  frame.setIconImage(pg.image);
}
