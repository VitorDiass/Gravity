/**
 * Created by paulo on 23-05-2017.
 */
import java.lang.*;

public class Jogador implements Comparable<Jogador>{
    private String username;
    private int pontuacao;
    
    Jogador(String user,int pontuacao){
      username = user;
      this.pontuacao = pontuacao;
    }
    public String getUsername(){return username;}
    
    public void setPontuacao(int pontuacao){
      this.pontuacao = pontuacao;
    }
    
    public int getPontuacao(){
      return pontuacao;
    }
    
    public String toString(){
      return "Jogador: " + username + " Pontuacao: " + pontuacao +"\n";
    }
    
    public int compareTo(Jogador j){
      synchronized(j){
        if(pontuacao > j.getPontuacao()) return -1;
        else if(pontuacao < j.getPontuacao()) return 1;
        else return 0;
      }
    }
    
}