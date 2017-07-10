import java.net.Socket;
import java.io.*;
import java.util.concurrent.locks.*;

/**
 * Created by paulo on 22-05-2017.
 */
public class Message extends Thread{
    private BufferedReader in;
    private Estado estado;

    Message(BufferedReader in,Estado estado){
        this.in = in;
        this.estado = estado;
    }

    public void run(){
        try {
            
            while(true){
              String s = in.readLine();
              //System.out.println(s);
              String[] sp = s.split(" "); //dividir strings por espaços
              //System.out.println("Entrou");
              if(sp[0].equals("online")){
                estado.addPlayer(new Jogador(sp[1],Integer.parseInt(sp[2])),new AvatarJogador(Double.parseDouble(sp[3]),Double.parseDouble(sp[4]),
                                                                                        Double.parseDouble(sp[5]),Double.parseDouble(sp[6]),
                                                                                        Double.parseDouble(sp[7]),Double.parseDouble(sp[8]),
                                                                                        Double.parseDouble(sp[9]),
                                                                                        Double.parseDouble(sp[10]),
                                                                                        Double.parseDouble(sp[11]),Double.parseDouble(sp[12])));
              }
              if(sp[0].equals("online_upd_pos")){
                estado.updatePosicao(sp[1],Double.parseDouble(sp[2]),Double.parseDouble(sp[3]), Double.parseDouble(sp[4]));
              }
              
              if(sp[0].equals("online_upd_left")){
                estado.updateDirecao(sp[1],Double.parseDouble(sp[2]),Double.parseDouble(sp[3]), 2);
              }
              
              if(sp[0].equals("online_upd_right")){
                estado.updateDirecao(sp[1],Double.parseDouble(sp[2]), Double.parseDouble(sp[3]), 3);
              }
              
              
              if(sp[0].equals("logout")){
                estado.logout(sp[1],-1);
              }
              
              if(sp[0].equals("logout_time")){
                estado.logout(sp[1],Integer.parseInt(sp[2]));
              }
              
              if(sp[0].equals("planeta")){
                estado.addPlaneta(Integer.parseInt(sp[1]),
                new AvatarPlaneta(Float.parseFloat(sp[2]),Float.parseFloat(sp[3]),Float.parseFloat(sp[4]),Float.parseFloat(sp[5])));
              }
              
              if(sp[0].equals("planeta_upd")){
                estado.updatePosicaoPlaneta(Integer.parseInt(sp[1]),Float.parseFloat(sp[2]),Float.parseFloat(sp[3]));
              }
              
              if(sp[0].equals("dead")){
                estado.retiraMorto(sp[1],Integer.parseInt(sp[2]));
              }
              
              if(sp[0].equals("charge")){
                estado.carrega(sp[1],Double.parseDouble(sp[2]),Double.parseDouble(sp[3]),Double.parseDouble(sp[4]));
              }
              
              if(sp[0].equals("pontos")){
                estado.setPontuacoes(sp[1],Integer.parseInt(sp[2]));
              }
              if(sp[0].equals("topPontos")){
                estado.topPontos(sp[1],Integer.parseInt(sp[2]));
                }
              
            }
            
            
            
        }catch (Exception e){
            e.printStackTrace();
        }
    }
}