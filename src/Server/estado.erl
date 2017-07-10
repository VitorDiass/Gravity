-module(estado).
-export([start/0]).
-import(avatar,[geraAvatarJogador/0,geraAvatarPlaneta/1,check_edges_planet/2,check_edges_player/2,charge_propulsor/3,check_collision_planet/2,check_collision_players/4]).


start() ->
  Pid = spawn(fun() -> estado(#{}, #{}, queue:new(),[],#{},[],#{}) end),
  register(?MODULE, Pid).


%funcao que recebe socket do user que acabou de fazer login e map dos Online e envia mensagem
login_estado(Online,Planetas,Socket,PontuacoesServidor) ->
  case maps:to_list(Online) of
    [] -> skip;
    L ->
  [gen_tcp:send(Socket,list_to_binary("online " ++ U ++ " 0 " ++ integer_to_list(Massa) ++ " " ++ integer_to_list(Velo) ++ " " ++ float_to_list(Dir) 
                ++ " " ++ float_to_list(X) ++ " " ++ float_to_list(Y) ++ " " ++ integer_to_list(H) ++ " " ++ integer_to_list(W) ++
                " "++ integer_to_list(Pf) ++ " " ++ integer_to_list(Pe) ++ " " ++ integer_to_list(Pd)++ "\n"))
                 || {U,{Massa, Velo, Dir, X, Y, H, W, Pf, Pe, Pd}} <- L]    
  end,
  case maps:to_list(Planetas) of
    [] -> skip;
    Pla ->
      [gen_tcp:send(Socket,list_to_binary("planeta " ++ integer_to_list(N) ++ " " ++ integer_to_list(Massa) ++ " " ++ integer_to_list(Velo) ++ " " ++ float_to_list(X) 
                ++ " " ++ float_to_list(Y) ++ "\n"))
                 || {N,{Massa, Velo, X, Y,_S}} <- Pla]
  end,
  case maps:to_list(PontuacoesServidor) of
    [] -> skip;
    PontServ ->
      [gen_tcp:send(Socket,list_to_binary("topPontos " ++ Username ++ " " ++ integer_to_list(Pontos) ++ "\n"))
                 || {Username,Pontos} <- PontServ]
  end.


    
%Online é um map com Username chave e o seu avatar como chave #{Username => {massa,velocidade,direcao,x,y,height,width}}, Pontuacoes = #{Username => Tempo}
estado(Online, Planetas, EsperaQ,Socks, Pontuacoes,PontuacoesJogo, PontuacoesServidor) ->
  receive
    {pontua} ->
      Fun = fun({U,P}) -> {U,P+1} end,
      Top = lists:map(Fun,PontuacoesJogo),
      [gen_tcp:send(Socket,list_to_binary("pontos " ++ U ++ " " ++ integer_to_list(P) ++ "\n")) || Socket <- Socks,{U,P} <- Top,maps:is_key(U,Online)],
      pontuar ! {back},
      estado(Online,Planetas,EsperaQ,Socks,Pontuacoes,Top,PontuacoesServidor);
    {gera_planetas} ->
      P = maps:put(0,geraAvatarPlaneta(1),Planetas),
      P1 = maps:put(1,geraAvatarPlaneta(2),P),
      P2 = maps:put(2,geraAvatarPlaneta(3),P1),
      estado(Online,P2,EsperaQ,Socks,Pontuacoes,PontuacoesJogo,PontuacoesServidor);
    {planetas, From} ->
      case lists:flatlength(Socks) of
        0 ->
          From ! {back},
          estado(Online,Planetas,EsperaQ,Socks,Pontuacoes,PontuacoesJogo,PontuacoesServidor);
        _ ->
          P = check_edges_planet(Planetas,0),
          case check_collision_planet(Planetas,maps:to_list(Online)) of
            {ok} ->
              Pla = maps:to_list(P),
              [gen_tcp:send(Socket,list_to_binary("planeta_upd " ++ integer_to_list(N) ++ " " ++ float_to_list(X) ++ " " 
                ++ float_to_list(Y) ++ "\n")) || Socket <- Socks, {N,{_Massa, _Velo, X, Y,_S}} <- Pla],
              From ! {back},
              estado(Online,P,EsperaQ,Socks,Pontuacoes,PontuacoesJogo,PontuacoesServidor);
            {error,Username} ->
              Jogador = hd([{U,Pontuacao} || {U,Pontuacao} <- PontuacoesJogo, U == Username]),
              Ini = maps:get(Username,Pontuacoes),
              Pont = maps:remove(Username,Pontuacoes),
              {_,Now,_} = os:timestamp(),
              Fun = fun(V) -> max((Now-Ini),V)end,
              PServidor = maps:update_with(Username,Fun,Now-Ini,PontuacoesServidor),
              Msg = "dead " ++ Username ++ " " ++ integer_to_list(Now-Ini) ++ "\n",
              case queue:out(EsperaQ) of
                {empty,_Q1} ->
                  [gen_tcp:send(Socket,list_to_binary(Msg)) || Socket <- Socks],
                  From ! {back},
                  estado(maps:remove(Username,Online),Planetas,EsperaQ,Socks,Pont,PontuacoesJogo -- [Jogador],PServidor);
                {{value,Item},Q1} -> %o Item é o Username que esta na queue
                  [gen_tcp:send(Socket,list_to_binary(Msg)) || Socket <- Socks],
                  estado ! {online,add,Item},
                  From ! {back},
                  estado(maps:remove(Username,Online),Planetas,Q1,Socks,Pont,PontuacoesJogo -- [Jogador],PServidor)
              end
          end          
      end;  
    {time,Socket,Username} ->      %<--------
      {_,Sec,_} = os:timestamp(),
      P = maps:put(Username,Sec,Pontuacoes),
		  login_estado(Online,Planetas,Socket,PontuacoesServidor),
		  estado(Online,Planetas,EsperaQ,Socks++[Socket],P,PontuacoesJogo,PontuacoesServidor);
    {online, add, Username} ->
      {Massa, Velo, Dir, X, Y, H, W,Pf,Pe,Pd} = geraAvatarJogador(),
      Dados = "online " ++ Username ++ " 0 " ++ integer_to_list(Massa) ++ " " ++ integer_to_list(Velo) ++ " " ++ float_to_list(Dir) 
                ++ " " ++ float_to_list(X) ++ " " ++ float_to_list(Y) ++ " " ++ integer_to_list(H) 
                ++ " " ++ integer_to_list(W) ++" "++ integer_to_list(Pf) ++ " " ++ integer_to_list(Pe) ++ " " ++ integer_to_list(Pd)++ "\n",
      [gen_tcp:send(Socket,list_to_binary(Dados)) || Socket <- Socks], %enviar os dados do jogador
      On = maps:put(Username, {Massa, Velo, Dir, X, Y, H, W,Pf,Pe,Pd}, Online),
      estado(On,Planetas,EsperaQ,Socks,Pontuacoes,PontuacoesJogo ++ [{Username,0}],PontuacoesServidor);
    {espera, add, Username} ->
      Q = queue:in(Username,EsperaQ),
      %io:format("~p~n",[Q]),
      estado(Online, Planetas,Q,Socks,Pontuacoes,PontuacoesJogo,PontuacoesServidor);
    {walk,Username} ->
      case maps:is_key(Username,Online) of
        false ->
          estado(Online,Planetas,EsperaQ,Socks,Pontuacoes,PontuacoesJogo,PontuacoesServidor);
        true ->
          case check_edges_player(Username,Online) of
            {error, Username} ->
              Jogador = hd([{U,P} || {U,P} <- PontuacoesJogo, U == Username]),
              Ini = maps:get(Username,Pontuacoes),
              P = maps:remove(Username,Pontuacoes),
              {_,Now,_} = os:timestamp(),
              Fun = fun(V) -> max((Now-Ini),V)end,
              PServidor = maps:update_with(Username,Fun,Now-Ini,PontuacoesServidor),
              Dados = "dead " ++ Username ++ " " ++ integer_to_list(Now-Ini) ++ "\n",
              case queue:out(EsperaQ) of
                {empty,_Q1} ->
                  [gen_tcp:send(Socket,list_to_binary(Dados)) || Socket <- Socks],
                  estado(maps:remove(Username,Online),Planetas,EsperaQ,Socks,P,PontuacoesJogo -- [Jogador],PServidor);
                {{value,Item},Q1} -> %o Item é o Username que esta na queue
                    [gen_tcp:send(Socket,list_to_binary(Dados)) || Socket <- Socks],
                    estado ! {online,add,Item},
                    estado(maps:remove(Username,Online),Planetas,Q1,Socks,P,PontuacoesJogo -- [Jogador],PServidor)
              end;              
            {On,Dados} ->
              case check_collision_players(On,Username,maps:get(Username,On),maps:to_list(On)) of
                {no_key} ->
                  charge ! {walk,Username},  
	                [gen_tcp:send(Socket,list_to_binary(Dados)) || Socket <-Socks],
                  estado(On,Planetas,EsperaQ,Socks,Pontuacoes,PontuacoesJogo,PontuacoesServidor);
                {ok} -> 
                  charge ! {walk,Username},  
	                [gen_tcp:send(Socket,list_to_binary(Dados)) || Socket <-Socks],
                  estado(On,Planetas,EsperaQ,Socks,Pontuacoes,PontuacoesJogo,PontuacoesServidor);
                {error,NewOn,Msg} ->
                  [gen_tcp:send(Socket,list_to_binary(Msg)) || Socket <-Socks],
                  charge ! {walk,Username},  
	                [gen_tcp:send(Socket,list_to_binary(Dados)) || Socket <-Socks],
                  estado(NewOn,Planetas,EsperaQ,Socks,Pontuacoes,PontuacoesJogo,PontuacoesServidor)
              end
          end
      end;
    {left,Username} ->
      case maps:is_key(Username,Online) of
        false ->
          estado(Online,Planetas,EsperaQ,Socks,Pontuacoes,PontuacoesJogo,PontuacoesServidor);
        true ->
	        {Massa,Velo,Dir,X,Y,H,W, Pf, Pe, Pd} = maps:get(Username,Online),
          case Pe of 
				    N when N > 0 -> 
              On = maps:update(Username,{Massa,Velo,Dir-10,X,Y,H,W,Pf,Pe-5,Pd},Online),
              Dados = "online_upd_left " ++ Username ++ " " ++ float_to_list(Dir-10) ++" "++integer_to_list(Pe-5)++ "\n";
				    0 ->  
              On = maps:update(Username,{Massa,Velo,Dir,X,Y,H,W,Pf,Pe,Pd},Online),
              Dados = "online_upd_left " ++ Username ++ " " ++ float_to_list(Dir) ++" "++integer_to_list(Pe)++ "\n"
			    end,	      
          charge ! {left,Username},  
	        [gen_tcp:send(Socket,list_to_binary(Dados)) || Socket <-Socks],          
          estado(On,Planetas,EsperaQ,Socks,Pontuacoes,PontuacoesJogo,PontuacoesServidor)
      end;
    {right,Username} ->
      case maps:is_key(Username,Online) of
        false ->
          estado(Online,Planetas,EsperaQ,Socks,Pontuacoes,PontuacoesJogo,PontuacoesServidor);
        true ->
	        {Massa,Velo,Dir,X,Y,H,W,Pf,Pe,Pd} = maps:get(Username,Online),
          case Pd of 
				    N when N>0 -> On = maps:update(Username,{Massa,Velo,Dir+10,X,Y,H,W,Pf,Pe,Pd-5},Online),
            Dados = "online_upd_right " ++ Username ++ " " ++ float_to_list(Dir+10) ++" "++integer_to_list(Pd-5) ++ "\n";
				    0 -> 
              On = maps:update(Username,{Massa,Velo,Dir,X,Y,H,W,Pf,Pe,Pd},Online),
              Dados = "online_upd_right " ++ Username ++ " " ++ float_to_list(Dir) ++" "++integer_to_list(Pd) ++ "\n"
			    end,
	        charge ! {right,Username},
	        [gen_tcp:send(Socket,list_to_binary(Dados)) || Socket <-Socks], 
          estado(On,Planetas,EsperaQ,Socks,Pontuacoes,PontuacoesJogo,PontuacoesServidor)
      end;
    {charge,Username,Prop} ->
      case charge_propulsor(Username,Prop,Online) of
        {error} -> estado(Online,Planetas,EsperaQ,Socks,Pontuacoes,PontuacoesJogo,PontuacoesServidor);
        {full} -> estado(Online,Planetas,EsperaQ,Socks,Pontuacoes,PontuacoesJogo,PontuacoesServidor);
        {On,Msg} -> 
          [gen_tcp:send(Socket,list_to_binary(Msg)) || Socket <-Socks],
          estado(On,Planetas,EsperaQ,Socks,Pontuacoes,PontuacoesJogo,PontuacoesServidor)
      end;
    {logout,Username,Sock} ->
      case queue:out(EsperaQ) of
        {empty,_Q1} ->
          On = maps:remove(Username,Online),
          case maps:is_key(Username,Pontuacoes) of
            true ->
              Jogador = hd([{U,P} || {U,P} <- PontuacoesJogo, U == Username]),
              Ini = maps:get(Username,Pontuacoes),
              P = maps:remove(Username,Pontuacoes),
              {_,Now,_} = os:timestamp(),
              Fun = fun(V) -> max((Now-Ini),V)end,
              PServidor = maps:update_with(Username,Fun,Now-Ini,PontuacoesServidor),
              Dados = "logout_time " ++ Username ++ " " ++ integer_to_list(Now-Ini) ++ "\n",
              [gen_tcp:send(Socket,list_to_binary(Dados)) || Socket <- Socks],
              estado(On,Planetas,EsperaQ,Socks--[Sock],P,PontuacoesJogo--[Jogador],PServidor);
            false ->
              Dados = "logout " ++ Username ++ " " ++ "\n",
              [gen_tcp:send(Socket,list_to_binary(Dados)) || Socket <- Socks],
              estado(On,Planetas,EsperaQ,Socks--[Sock],Pontuacoes,PontuacoesJogo,PontuacoesServidor)
          end;          
        {{value,Item},Q1} -> %o Item é o Username que esta na queue
          case Item of
            Username -> estado(Online,Planetas,Q1,Socks--[Sock],Pontuacoes,PontuacoesJogo,PontuacoesServidor);
            _ ->
              On = maps:remove(Username,Online),
              case maps:is_key(Username,Pontuacoes) of
                true ->
                  Jogador = hd([{U,P} || {U,P} <- PontuacoesJogo, U == Username]),
                  Ini = maps:get(Username,Pontuacoes),
                  P = maps:remove(Username,Pontuacoes),
                  {_,Now,_} = os:timestamp(),
                  Fun = fun(V) -> max((Now-Ini),V)end,
                  PServidor = maps:update_with(Username,Fun,Now-Ini,PontuacoesServidor),
                  Dados = "logout_time " ++ Username ++ " " ++ integer_to_list(Now-Ini) ++ "\n",
                  [gen_tcp:send(Socket,list_to_binary(Dados)) || Socket <- Socks],
                  estado ! {online,add,Item},
                  estado(On,Planetas,EsperaQ,Socks--[Sock],P,PontuacoesJogo--[Jogador],PServidor);
                false ->
                  Dados = "logout " ++ Username ++ " " ++ "\n",
                  [gen_tcp:send(Socket,list_to_binary(Dados)) || Socket <- Socks],
                  estado ! {online,add,Item},
                  estado(On,Planetas,EsperaQ,Socks--[Sock],Pontuacoes,PontuacoesJogo,PontuacoesServidor)
              end
          end
      end    
  end.

    
