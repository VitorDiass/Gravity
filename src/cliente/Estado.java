//Classe que vai armazenar o estado do jogo, memoria partilhada entre a classe Message e login
import java.util.List;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.Comparator;
import java.util.TreeSet;
import java.util.concurrent.locks.*;

  
public class Estado{
    private Map<Jogador, AvatarJogador> online;
    private Map<Jogador, AvatarJogador> espera;
    private Map<Integer,AvatarPlaneta> planetas;
    private TreeSet<Jogador> topPontuacao;
    private TreeSet<Jogador> topServidor;
    private Lock l = new ReentrantLock();
    
    Estado(){
      online = new HashMap();
      espera = new HashMap();
      planetas = new HashMap();
      topPontuacao = new TreeSet();
      topServidor = new TreeSet();
    }
    
    
    public void addPlayer(Jogador j,AvatarJogador aj){
      l.lock();
      try{
        online.put(j,aj);  
      }finally{
        l.unlock();
      }
    }
    
    public void addPlaneta(int N,AvatarPlaneta ap){
      l.lock();
      try{
        planetas.put(N,ap);  
      }finally{
        l.unlock();
      }
    
    }
    
    public String[] getNome(){
      l.lock();  
      String[] nomes = new String[4];
      int i=0; 
        try{
         for(Map.Entry<Jogador,AvatarJogador> entry : online.entrySet()){
             nomes[i] = entry.getKey().getUsername();
             i++;
         }
        }finally{
          l.unlock();
          return nomes;
        }
        
    }
    
    public float[][] getPlanetas(){
      l.lock();
      float[][] plan = new float[3][3];
      int i = 0;
      try{
        for(Map.Entry<Integer,AvatarPlaneta> entry : planetas.entrySet()){
             plan[i] = entry.getValue().getAtributos();
             i++;
         }
      }finally{
        l.unlock();
        return plan;
      }
    }
    
    
    public double[][] atributosJogador(){
      l.lock();
      
      double[][] elementos = new double[4][8];
      int i = 0;
      try{
        for (Map.Entry<Jogador,AvatarJogador> entry : online.entrySet()){
          double[] atr = entry.getValue().getAtributos();
          //System.out.println(entry.getKey().toString() + entry.getValue().toString());
          elementos[i][0] = atr[0]; elementos[i][1] = atr[1];
          elementos[i][2] = atr[2]; elementos[i][3] = atr[3];
          elementos[i][4] = atr[4]; elementos[i][5] = atr[5];
          elementos[i][6] = atr[6]; elementos[i][7] = atr[7];
          i++;
        }
      }finally{
        l.unlock();
        return elementos;
      }
    }
    
    public void updatePosicao(String username,double x, double y, double energia){
      l.lock();
      
      try{
        AvatarJogador j = null;
        for (Map.Entry<Jogador,AvatarJogador> entry : online.entrySet()){
          if(entry.getKey().getUsername().equals(username)){
            j = entry.getValue();
            j.updatePos(x,y);
            j.updatePropFrente(energia);
            break;
          }
        }
      }finally{
        l.unlock();
      }
    }
    
    public void carrega(String username, double p1, double p2, double p3){
      l.lock();
      try{
        AvatarJogador j = null;
        for (Map.Entry<Jogador,AvatarJogador> entry : online.entrySet()){
          if(entry.getKey().getUsername().equals(username)){
            j = entry.getValue();
            j.updatePropFrente(p1);
            j.updatePropLeft(p2);
            j.updatePropRight(p3);
            break;
          }
        }
      }finally{
        l.unlock();
      }
    }
    
    public void updateDirecao(String username,double dir, double energia, int p){
      l.lock();
      
      try{
        AvatarJogador j = null;
        for (Map.Entry<Jogador,AvatarJogador> entry : online.entrySet()){
          if(entry.getKey().getUsername().equals(username)){
            j = entry.getValue();
            j.updateDir(dir);
            switch(p){
              case 2:
                j.updatePropLeft(energia);
                break;
              case 3:
                j.updatePropRight(energia);
                break;
            }
            break;
          }
        }
      }finally{
        l.unlock();
      }
    }
    
    public void updatePosicaoPlaneta(int n,float x, float y){
      l.lock();
      try{
        AvatarPlaneta a = planetas.get(n);
        a.updatePos(x,y);
      }finally{
        l.unlock();
      }
    }
    
    public void logout(String username,int pontuacao){
      l.lock();
      boolean changed = false;
      Jogador j = null;
      try{
        for (Map.Entry<Jogador,AvatarJogador> entry : online.entrySet()){
          if(entry.getKey().getUsername().equals(username)) {
          j = entry.getKey();
          for(Jogador j1:topPontuacao){
            if(username.equals(j1.getUsername())){topPontuacao.remove(j1); break;}
          }
          for(Jogador j1: topServidor){
            if(username.equals(j1.getUsername()) && pontuacao > j1.getPontuacao()){
              topServidor.remove(j1);
              j = new Jogador(username,pontuacao);
              topServidor.add(j);
              changed=true;
              break;
            }
          }
            if(!changed) topServidor.add(new Jogador(username,pontuacao));    

          online.remove(j);break;}
        }
      }finally{
        l.unlock();
      }
    }
    
    
    public void retiraMorto(String username,int pontuacao){
    
      l.lock();
      boolean changed = false;
      Jogador j = null;
      try{
        for (Map.Entry<Jogador,AvatarJogador> entry : online.entrySet()){
          if(entry.getKey().getUsername().equals(username)) {
            j = entry.getKey();
            for(Jogador j1:topPontuacao){
              if(username.equals(j1.getUsername())){topPontuacao.remove(j1); break;}
            }
             for(Jogador j1: topServidor){
            if(username.equals(j1.getUsername()) && pontuacao > j1.getPontuacao()){
              topServidor.remove(j1);
              j = new Jogador(username,pontuacao);
              topServidor.add(j);
              changed=true;
              break;
            }
             }
            if(!changed) topServidor.add(new Jogador(username,pontuacao));               
            online.remove(j);break;
          }
        }
        topPontuacaoString();
        topServidorString();
      }finally{
        l.unlock();
      }
    }
    
    public void setPontuacoes(String username, int pontuacao){
      l.lock();
      boolean changed = false;
      try{
        for(Jogador j:topPontuacao){
          if(username.equals(j.getUsername()) && pontuacao > j.getPontuacao()){
            topPontuacao.remove(j);
            topPontuacao.add(new Jogador(username,pontuacao));
            changed = true;
            break;
          }
        }
        if(!changed)
          topPontuacao.add(new Jogador(username,pontuacao));
      }finally{
        l.unlock();
      }
    }
    
    public String toString(){
      String s = "";
      for (Map.Entry<Jogador,AvatarJogador> entry : online.entrySet()){
        s += entry.getKey().toString() + entry.getValue().toString();
      }
      return s;
    }
    
    public String[] topServidorString(){
    l.lock();
    String[] jog = new String[topServidor.size()];
    int i = 0;
    try{
      for(Jogador j:topServidor){
          //System.out.println("1 " + j.toString());
        jog[i++]= j.toString();
      }
    }finally{
      l.unlock();
      return jog;
      }
    
    }
    
    public void topPontos(String username, int pontos){
      l.lock();
      try{
        topServidor.add(new Jogador(username,pontos));
      }finally{
        l.unlock();
      }
    }
    
    
    
    public String[] topPontuacaoString(){
     l.lock();
     String[] jog = new String[topPontuacao.size()];
     int i = 0;
     try{
       for(Jogador j:topPontuacao){
         //System.out.println("1 " + j.toString());
         jog[i++] = j.toString();
       }
     }finally{
       l.unlock();
       return jog;
     }
   }
}