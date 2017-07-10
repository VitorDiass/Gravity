/**
 * Created by paulo on 23-05-2017.
 */
//Avatares de Jogadores
public class AvatarJogador {
    private static double massa;
    private static double velocidade;
    private double direcao; //angulo em graus
    private double x, y; //coordenadas do jogador
    private double h,w; //altura e largura do avatar
    private double p1; // propulsor frente
    private double p2; // propulsor esq
    private double p3; // propulsor dir
    
    AvatarJogador(double massa,double velocidade, double direcao, double x, double y, double h, double w, double p1, double p2, double p3){
      this.massa = massa;this.velocidade = velocidade; this.direcao = direcao; this.x = x; this.y = y; this.h = h; this.w = w;
      this.p1 = p1; this.p2 = p2; this.p3 = p3;
    }
    
    public void updatePos(double x, double y){
      this.x = x;this.y = y;
    }
    
    public void updatePropRight(double p3){
       this.p3=p3;       
    }
    
    public void updatePropLeft(double p2){
       this.p2=p2;       
    }
    
    public void updatePropFrente(double p1){
       this.p1=p1;       
    }
    
    public void updateDir(double dir){
      this.direcao = dir;
    }
    public String toString(){
      return "Massa: " + massa + " Veloc: " + velocidade + " Dir: " + direcao + " x: " + x + " y: " + y + " h: " + h + " w: " + w + "\n";
    }
    
    public double[] getAtributos(){
      double[] feat = {x,y,h,w,direcao,p1,p2,p3};
      
      return feat;
    }
}