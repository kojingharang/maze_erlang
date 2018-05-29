-module(solver_kh).

-export([solve/2]).

maxCost() ->
    100000.

solve(N, Maze) ->
    State0 =
        list_to_tuple([case I=:=0 of
                           true -> {0, -1};
                           false->{maxCost(), -1}
                       end || I <- lists:seq(0, N*N-1)]),
    Q = queue:from_list([{0, 0, 0}]),
    S1 = vis(Q, N, Maze, State0),
    Path = genPath(index(N, N-1, N-1), N, S1),
    %% io:format("~p~n", [Path]),

    lists:foldl(
      fun(Index, A) ->
              I8 = Index*8,
              <<L:I8, _:8, R/binary>> = A,
              <<L:I8, "o", R/binary>>
      end, Maze, Path).

isIn(N, V) ->
    0=<V andalso V<N.

index(N, X, Y) ->
    Y*N+X.

vis(Q, N, Maze, State) ->
    case queue:is_empty(Q) of
        true ->
            State;
        false ->
            {{value, {X, Y, Cost}}, Q1} = queue:out(Q),
            {CCost, _} = element(index(N, X, Y)+1, State),
            %% io:format("Pop ~p~n", [{X, Y, Cost, CCost}]),
            {Q2, State1} =
                case CCost < Cost of
                    true ->
                        {Q1, State};
                    false ->
                        lists:foldl(
                          fun({Dx, Dy}, {Qa, S}) ->
                                  Nx = X+Dx, Ny = Y+Dy,
                                  case isIn(N, Nx) andalso isIn(N, Ny)
                                      andalso binary:part(Maze, Ny*N+Nx, 1) =:= <<" ">> of
                                      true ->
                                          {NCost, _} = element(index(N, Nx, Ny)+1, S),
                                          case Cost+1 < NCost of
                                              true ->
                                                  Qb = queue:in({Nx, Ny, Cost+1}, Qa),
                                                  S1 = setelement(index(N, Nx, Ny)+1, S, {Cost+1, Y*N+X}),
                                                  {Qb, S1};
                                              false ->
                                                  {Qa, S}
                                          end;
                                      false ->
                                          {Qa, S}
                                  end
                          end, {Q1, State}, [{1, 0}, {-1, 0}, {0, -1}, {0, 1}])
                end,
            vis(Q2, N, Maze, State1)
    end.

genPath(0, _, _) ->
    [0];
genPath(Index, N, S) ->
    {Cost, Parent} = element(Index+1, S),
    case Cost=:=maxCost() of
        true -> [];
        false ->
            [Index|genPath(Parent, N, S)]
    end.
