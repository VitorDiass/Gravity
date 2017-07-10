/**
 * Created by paulo on 23-05-2017.
 */
public class AvatarPlaneta {
    private float massa;
    private float velocidade;
    private float x, y;
    
    AvatarPlaneta(float massa,float velocidade, float x, float y){
      this.massa = massa;this.velocidade = velocidade;this.x = x;this.y=y;
    }
    
    public float[] getAtributos(){
      float[] f = {massa,x,y};
      return f;
    }
    
    public void updatePos(float x, float y){
      this.x = x;this.y = y;
    }
}