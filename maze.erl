-module(maze).

-export([main/0]).

genRandomTest() ->
    N = 2 + rand:uniform(48),
    Maze =
        binary:list_to_bin([
                            case I==0 orelse I==N*N-1 of
                                true ->
                                    <<" ">>;
                                false ->
                                    case rand:uniform() < 0.3 of
                                        true -> <<"#">>;
                                        false -> <<" ">>
                                    end
                            end
                            || I <- lists:seq(0, N*N-1)]),
    {N, Maze}.

main() ->
    Tests = [
             {5, <<
                   "     "
                   "# ## "
                   "     "
                   " ####"
                   "     "
                 >>},
             {10, <<
                    "          "
                    "######### "
                    "          "
                    "          "
                    "          "
                    "          "
                    "          "
                    "          "
                    " #########"
                    "          "
                  >>},
             {10, <<
                    "     #    "
                    " ###  ### "
                    " # #   #  "
                    "    ##    "
                    "##     ###"
                    "   ###    "
                    "  #   ### "
                    " #  #     "
                    " # #######"
                    " #        "
                  >>}
            ] ++ [genRandomTest() || _ <- lists:seq(1, 10)],
    %% io:format("~p~n", [Tests]),
    [print(N, solver_kh:solve(N, Maze)) || {N, Maze} <- lists:sublist(Tests, 1000)].

print(N, Ans) ->
    io:format("~nMAZE ~p~n", [N]),
    lists:foreach(
      fun(I)->
              io:format("~s~n", [binary:part(Ans, N*I, N)])
      end, lists:seq(0, N-1)).

