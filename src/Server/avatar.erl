-module(avatar).
-export([geraAvatarJogador/0,geraAvatarPlaneta/1,check_edges_planet/2,check_edges_player/2,charge_propulsor/3,check_collision_planet/2,check_collision_players/4]).


geraAvatarJogador() -> %{massa,velocidade,direcao,x,y,largura,altura, prop frente, prop esq, prop dir}
  X = rand:uniform(2),
  if
    X == 1 ->
      {1, 20, 120.0, rand:uniform(1200)+0.0, 50.0, 50, 50, 100, 100, 100};
    true ->
      {1, 20, 120.0, rand:uniform(1200)+0.0, 950.0, 50, 50, 100, 100, 100}
  end.

geraAvatarPlaneta(P) -> %{massa,velocidade,x,y,s}
  Massa = 150 + rand:uniform(50),
  Velocidade = 10 + rand:uniform(20),
  if
    P == 1 ->
      {Massa,Velocidade,200.0,200.0,1};
    P == 2 -> %{massa,velocidade,x,y}
      {Massa,Velocidade,200.0,500.0,1};
    P == 3 -> %{massa,velocidade,x,y}
      {Massa,Velocidade,200.0,800.0,1};
    true -> error
end.

check_edges_planet(Planetas,P) ->
  if
    P == 3 -> Planetas;
    true ->
      {M,V,X,Y,S} = maps:get(P,Planetas),
      if
        X > 1200-(M/2) ->
          check_edges_planet(maps:update(P, {M,V,X+(V*-S),Y,-S},Planetas),P+1);      
        X < (M/2) -> check_edges_planet(maps:update(P,{M,V,X+(V*-S),Y,-S},Planetas),P+1); 
        true -> check_edges_planet(maps:update(P,{M,V,X+(V*S),Y,S},Planetas),P+1)  
      end
  end.

distance(X,Y,X1,Y1) ->
   math:sqrt( math:pow(abs(X1-X),2) + math:pow(abs(Y1-Y),2)).


check_collision_planet(Planetas,[H | T]) ->
  {M,_V,X,Y,_S} = maps:get(0,Planetas),
  {M1,_V1,X1,Y1,_S1} = maps:get(1,Planetas),
  {M2,_V2,X2,Y2,_S2} = maps:get(2,Planetas),
  {U,{_,_,_,XA,YA,HA,_,_,_,_}} = H,
  D = distance(XA,YA,X,Y),
  D1 = distance(XA,YA,X1,Y1),
  D2 = distance(XA,YA,X2,Y2),
  if
    D < ((HA/2) + (M/2)) -> {error, U};
    D1 < ((HA/2) + (M1/2)) -> {error, U};
    D2 < ((HA/2) + (M2/2)) -> {error, U};
    true -> check_collision_planet(Planetas,T)
  end;
check_collision_planet(_Planetas,[]) ->
  {ok}.

check_collision_players(Online,Username,A,[H | T])->
    {U,{MA1,VA1,DA1,XA1,YA1,HA1,WA1,PfA1,PeA1,PdA1}} = H,
    case U of
      Username -> check_collision_players(Online,Username,A,T);
      _ ->
        {_,_,_,XA,YA,HA,_,_,_,_} = A,
        D = distance(XA,YA,XA1,YA1),
        MinDistance = ((HA/2) + (HA1/2)),
        if 
          D < MinDistance ->
            NewX = 0.0+rand:uniform(100)+XA1,
            NewY = 0.0+rand:uniform(100)+YA1,
            On = maps:update(U,{MA1,VA1,DA1,NewX,NewY,HA1,WA1,PfA1,PeA1,PdA1},Online),
            {error,On,"online_upd_pos " ++ U ++ " " ++ float_to_list(NewX) ++ " " ++ float_to_list(NewY) ++ " " ++ integer_to_list(PfA1) ++ "\n"};
          true -> check_collision_players(Online,Username,A,T)
        end
    end;
check_collision_players(_Online,_Username,_A,[]) ->
  {ok}.


check_edges_player(Username,Avatares) ->
  {Massa,Velo,Dir,X,Y,H,W, Pf, Pe, Pd} = maps:get(Username,Avatares),
	
  if
    (X < 0) or (X > 1200) or (Y < 0) or (Y > 1200) -> {error,Username};
    true -> 
      case Pf of
			  N when N>0 -> 
              NewX = X + (math:cos(Dir*math:pi()/180)*Velo),
						  NewY = Y + (math:sin(Dir*math:pi()/180)*Velo),
	        		On = maps:update(Username,{Massa,Velo,Dir,NewX,NewY,H,W,Pf-5,Pe,Pd},Avatares),
              {On,"online_upd_pos " ++ Username ++ " " ++ float_to_list(NewX) ++ " " ++ float_to_list(NewY) ++ " " ++ integer_to_list(Pf-5) ++ "\n"};
			  0 -> 
          On = maps:update(Username,{Massa,Velo,Dir,X,Y,H,W,Pf,Pe,Pd},Avatares),
          {On,"online_upd_pos " ++ Username ++ " " ++ float_to_list(X) ++ " " ++ float_to_list(Y) ++ " " ++ integer_to_list(Pf) ++ "\n"}         
		  end
  end.

charge_propulsor(Username,Prop,Avatares) ->
  case maps:is_key(Username,Avatares) of
    false -> {error};
    true ->
      {Massa,Velo,Dir,X,Y,H,W, Pf, Pe, Pd} =maps:get(Username,Avatares),
      case Prop of
        "Pe" ->
        if
          Pe == 100 -> {full};
          Pe < 100 -> 
            On = maps:update(Username,{Massa,Velo,Dir,X,Y,H,W, Pf, Pe + 5, Pd},Avatares),
            Msg = "charge " ++ Username ++ " " ++ integer_to_list(Pf) ++ " " ++integer_to_list(Pe+5) ++ " " ++ integer_to_list(Pd) ++ "\n",
            {On,Msg}
        end;
      "Pd" ->
        if
          Pd == 100 -> {full};
          Pd < 100 ->
            On = maps:update(Username,{Massa,Velo,Dir,X,Y,H,W, Pf, Pe, Pd + 5},Avatares),
            Msg = "charge " ++ Username ++ " " ++ integer_to_list(Pf) ++ " " ++ integer_to_list(Pe) ++ " " ++ integer_to_list(Pd + 5) ++ "\n",
            {On,Msg}
        end;
      "Pf" ->
        if
          Pf == 100 -> {full};
          Pf < 100 ->
          On = maps:update(Username,{Massa,Velo,Dir,X,Y,H,W, Pf + 5, Pe, Pd},Avatares),
          Msg = "charge " ++ Username ++ " " ++ integer_to_list(Pf + 5) ++ " " ++ integer_to_list(Pe) ++ " " ++ integer_to_list(Pd) ++ "\n",
          {On,Msg}
        end
      end
  end.
