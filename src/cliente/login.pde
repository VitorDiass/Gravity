import java.util.*;
import controlP5.*;
import java.net.*;
import java.io.*;
import java.util.concurrent.locks.*;
//carregar imagens background
PImage image_main_screen,image_login,image_game_screen;


//caixas de texto e botoes
ControlP5 cp5;
//screens
final int main_screen = 0;
final int login_screen = 1;
final int game_screen = 2;
final int last_screen = 3;
int state = main_screen;

final int button_width = 150;
final int button_height = 50;
final int textfield_width = 150;
final int textfield_height = 50;

boolean connect_fail = false;
boolean login_fail = false, create_account_fail = false;
float x, y, px, py, h, w;
Cliente c1 = null;
Message m = null;
Estado estado = null;
BufferedReader in = null;
String user, pass;

void setup(){
    cp5 = new ControlP5(this);

    size(1200,1000);
    image_main_screen = loadImage("main_screen.jpg");
    image_login = loadImage("login_screen.jpg");
   
    PFont pfont = createFont("Arial",20,true);
    PFont pfont_small = createFont("Arial",15,true);
    
    cp5.addButton("Connect") //Botao da pagina inicial, main_screen
                 .setValue(0).setColorBackground(color(200)).setFont(pfont)
                 .setPosition((width/2)-(button_width/2),(height/2)-(button_height/2))
                 .setSize(button_width,button_height)
                 .onPress(new CallbackListener() { //Eventhandler do botao da pagina inicial main_screen
                    public void controlEvent(CallbackEvent theEvent) {
                      c1 = new Cliente();
                      //Caso o servidor nao esteja ligado, o connect vai dar exceçao e nao muda o estado
                      try{
                        c1.connect();
                        in = new BufferedReader(new InputStreamReader(c1.getPingSocket().getInputStream()));
                        estado = new Estado();
                        state = login_screen;
                      }catch(Exception e){
                        connect_fail = true;
                        state = main_screen;
                        
                      }
                      cp5.getController("Connect").hide();
                    }
                  });
                  
     cp5.addTextfield("Username")
       .setPosition((width/2)-100,(height/2)-100)
       .setSize(textfield_width,textfield_height)
       .setFont(pfont)
       .setFocus(true)
       .setColor(color(255,255,255)).hide()
       ;
       
    cp5.addTextfield("Password")
       .setPosition((width/2)-100,(height/2)-10)
       .setSize(textfield_width,textfield_height)
       .setFont(pfont)
       .setFocus(true)
       .setColor(color(255,255,255)).hide()
       .setPasswordMode(true)
       ;  
                  
    cp5.addButton("Login") //Botao da pagina inicial, main_screen
                 .setValue(0).setColorBackground(color(200)).setFont(pfont)
                 .setPosition((width/2)+70,(height/2)-100)
                 .setSize(button_width+20,button_height).hide()
                 .onPress(new CallbackListener() { //Eventhandler do botao da pagina inicial main_screen
                    public void controlEvent(CallbackEvent theEvent) {
                      user = cp5.get(Textfield.class,"Username").getText();
                      pass = cp5.get(Textfield.class,"Password").getText();
                      c1.login(user,pass);
                      
                      try{
                        String s = in.readLine();
                        println(s);
                        if(s.equals("ok_login")){
                          m = new Message(in,estado);
                          m.start();
                          cp5.hide();
                          state = game_screen;
                        }else{
                          login_fail=true;
                        }
                      }catch(Exception e){e.printStackTrace();}
                      
                    }
                  });
       
    cp5.addButton("New account") //Botao da pagina inicial, main_screen
                 .setValue(0).setColorBackground(color(200)).setFont(pfont)
                 .setPosition((width/2)+70,(height/2)-10)
                 .setSize(button_width+20,button_height).hide()
                 .onPress(new CallbackListener() { //Eventhandler do botao da pagina inicial main_screen
                    public void controlEvent(CallbackEvent theEvent) {
                      user = cp5.get(Textfield.class,"Username").getText();
                      pass = cp5.get(Textfield.class,"Password").getText();
                      c1.create_account(user,pass);
                      try{
                        String s = in.readLine();
                        println(s);
                        if(s.equals("ok_create_account")){
                          m = new Message(in,estado);
                          m.start();
                          cp5.hide();
                          state = game_screen;
                        }else{
                          create_account_fail = true;
                        }
                      }catch(Exception e){e.printStackTrace();}
                    }
                  });
                  
                   
    cp5.addButton("Disconnect") //botao disconnect da pagina
                 .setValue(0).setColorBackground(color(200)).setFont(pfont_small)
                 .setPosition(width-(button_width),height-(button_height))
                 .setSize(button_width/2+35,button_height/2).hide()
                 .onPress(new CallbackListener(){
                       public void controlEvent(CallbackEvent theEvent){
                           try{
                             c1.disconnect();
                             state=main_screen;
                           }catch(Exception e){}
                       }
                 });
                 
    cp5.addButton("Close Account") //Botao da pagina inicial, main_screen
                 .setValue(0).setColorBackground(color(200)).setFont(pfont)
                 .setPosition((width/2)+70,(height/2)+70)
                 .setSize(button_width+20,button_height).hide()
                 .onPress(new CallbackListener() { //Eventhandler do botao da pagina inicial main_screen
                    public void controlEvent(CallbackEvent theEvent) {
                      c1.close_account(cp5.get(Textfield.class,"Username").getText(),cp5.get(Textfield.class,"Password").getText());
                      
                    }
                  });
     
      //frame.setResizable(true);
                  
    
}

void draw() {
  background(0);
  //frameRate(5);
  switch (state){
    case main_screen:
      show_main_screen();
      break;
    case login_screen:
      show_login();
      break;
    case game_screen:
      show_game_screen();
      break;
   /* case last_screen:
      show_last_screen();
      break;*/
  } 
}
/*
void show_last_screen(){
  String[] pontuacao = estado.topPontuacaoString();
  int espaco = 20;
  text("Top:",100,700);
  for(int i = 0;i<pontuacao.length;i++,espaco+=20){
    text(pontuacao[i],100,700+espaco);
  }  
}*/

void show_main_screen(){
    float centerX = width/2;
    float centerY  = height/2;
    float w = 150;
    float h = 50;
    
    cp5.getController("Connect").show();
    cp5.getController("Login").hide();
    cp5.getController("New account").hide();
    cp5.getController("Close Account").hide();
    cp5.getController("Username").hide();
    cp5.getController("Password").hide();
    cp5.getController("Disconnect").hide();
   
    
    image(image_main_screen,0,0,width,height);
    if(connect_fail) text("Falha na Conexão",100,100);
}

void show_login(){
  
  float centerX = width/2;
  float centerY  = height/2;
  
  
  
  image(image_login,0,0,width,height);
 
  
  cp5.getController("Login").show();
  cp5.getController("New account").show();
  cp5.getController("Close Account").show();
  cp5.getController("Username").show();
  cp5.getController("Password").show();
  cp5.getController("Disconnect").show();
  
  if(create_account_fail) {text("Conta já existe",100,100);create_account_fail = false;}
  if(login_fail) {text("Conta não existe",100,100);login_fail = false;}
}

void show_game_screen(){
  //c-canto s-superior e-esquerdo
  float x_CSE = 40;
  float y_CIE = height-60;
  float x_CSD = width;
  float y_CID = height-60;
  //frameRate(60);
  color j0 = color(230,60,0);
  color j1 = color(60,180,20);
  color j2 = color(20,60,240);
  color j3 = color(150,150,150);
  color planet = color(102,51,0);
  
  
  background(192,192,192);
  
  String[] nomes = estado.getNome();
  double[][] elem = estado.atributosJogador();
  float[][] planetas = estado.getPlanetas();
  int space=20;
  for(int i = 0;i<planetas.length;i++){
    fill(planet);
    px = planetas[i][1]; py = planetas[i][2]; h = planetas[i][0]; w = planetas[i][0];
    ellipse(px,py,h,w);
    
  }
    PFont pfont_small = createFont("Arial",12,true);
    PFont pfont = createFont("Arial",20,true);
 
   textFont(pfont_small);
   text("Press Shift to logout",width/2-30,height-5);
  
  for(int i = 0;i<elem.length;i++){
    x = (float)elem[i][0];y = (float)elem[i][1];
    
    pushMatrix();
    translate(x,y);
    rotate(radians((float)elem[i][4]));
    line(0,0,35,0);
    if(i==0){
    fill(j0);
    ellipse(0,0,(float)elem[0][2],(float)elem[0][3]);
    }
    if(i==1){
    fill(j1);
    ellipse(0,0,(float)elem[1][2],(float)elem[1][3]);
    }
    if(i==2){
    fill(j2);
    ellipse(0,0,(float)elem[2][2],(float)elem[2][3]);
    }
    if(i==3){
    fill(j3);
    ellipse(0,0,(float)elem[3][2],(float)elem[3][3]);
    }
    popMatrix();
    
    //fill(255,0,0);
    
    
   color c = color(0,0,0);
   
    if(!(nomes[i] == null)){
         String strNome = "Nome:";
         String strFrente = "Frente:";
         String strEsq = "Esq:";
         String strDir = "Dir:";
        if(i==0){
           textFont(pfont_small);
           text(strNome,x_CSE-textWidth(strNome),space);
           text(strFrente,x_CSE-textWidth(strNome),space+20);
           text(strEsq,x_CSE-textWidth(strNome),space+40);
           text(strDir,x_CSE-textWidth(strNome),space+60);
           textFont(pfont);
           
           text(nomes[0],x_CSE,space);
           space+=20;
           //if(elem[0][5]>=60) c= color(0,255,0);
           //if(elem[0][5]<60 && elem[0][5]>=45)c=color(100,100,0);
           //fill(c);
           text(Double.toString(elem[0][5]),x_CSE,space);
            space+=20;     
           text(Double.toString(elem[0][6]),x_CSE,space);
            space+=20;
           text(Double.toString(elem[0][7]),x_CSE,space);
      }   
          space=20;
          if(i==1){
           textFont(pfont_small);
           text(strNome,x_CSD-textWidth(strNome)-textWidth(nomes[1])-60,space);
           text(strFrente,x_CSD-textWidth(strNome)-60,space+20);
           text(strEsq,x_CSD-textWidth(strNome)-60,space+40);
           text(strDir,x_CSD-textWidth(strNome)-60,space+60);
           textFont(pfont);
           
           text(nomes[1],x_CSD-textWidth(nomes[1]),space); 
           space+=20;
           text(Double.toString(elem[1][5]),x_CSD-60,space);
            space+=20;     
           text(Double.toString(elem[1][6]),x_CSD-60,space);
            space+=20;
           text(Double.toString(elem[1][7]),x_CSD-60,space);
    }
      if(i==2) {
           textFont(pfont_small);
           text(strNome,x_CSE-textWidth(strNome),y_CIE);
           text(strFrente,x_CSE-textWidth(strNome),y_CIE+20);
           text(strEsq,x_CSE-textWidth(strNome),y_CIE+40);
           text(strDir,x_CSE-textWidth(strNome),y_CIE+60);
           textFont(pfont);
           
           text(nomes[2],x_CSE,y_CIE);
           //space+=20;
           text(Double.toString(elem[2][5]),x_CSE,y_CIE+20);
            //space+=20;     
           text(Double.toString(elem[2][6]),x_CSE,y_CIE+40);
            //space+=20;
           text(Double.toString(elem[2][7]),x_CSE,y_CIE+60);
          }
      if(i==3){
           textFont(pfont_small);
           text(strNome,x_CSD-textWidth(strNome)-textWidth(nomes[3])-60,y_CID);
           text(strFrente,x_CSD-textWidth(strNome)-60,y_CID+20);
           text(strEsq,x_CSD-textWidth(strNome)-60,y_CID+40);
           text(strDir,x_CSD-textWidth(strNome)-60,y_CID+60);
           textFont(pfont);
           
           text(nomes[3],x_CSD-textWidth(nomes[3]),y_CID);
           //space+=20;
           text(Double.toString(elem[3][5]),x_CSD-60,y_CID+20);
            //space+=20;     
           text(Double.toString(elem[3][6]),x_CSD-60,y_CID+40);
            //space+=20;
           text(Double.toString(elem[3][7]),x_CSD-60,y_CID+60);
         
        }
  
      }
  }
        String [] pontosServidor = estado.topServidorString();
        int espaco = 20;
        text("TopServidor:",5,height/2-180);
        for(int i = 0;i<pontosServidor.length && i<5;i++,espaco+=20){
        text(pontosServidor[i],5,height/2-180+espaco);
        //espaco +=20;
        }
        String[] pontuacao = estado.topPontuacaoString();
        int espaco1 = 20;
        text("Pontuacao:",width-textWidth("Pontuacao:")-60,height/2-180);
        for(int i = 0;i<pontuacao.length;i++,espaco1 +=20){
        text(pontuacao[i],width-textWidth(pontuacao[i]),height/2-180+espaco1);
        //espaco1 +=20;
        } 
}

void keyPressed(){
  if(state == game_screen){
    if(keyCode == UP){
      c1.sendMessage("\\walk");
    }
    if(keyCode == LEFT){
      c1.sendMessage("\\left");
    }
    if(keyCode == RIGHT){
      c1.sendMessage("\\right");
    }
    
    if(keyCode == 16){ //shift
      state=login_screen;
      c1.sendMessage("\\logout " + user + " " + pass); 
     
    }
  }
}

  