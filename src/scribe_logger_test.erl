-module(scribe_logger_test).

-export([run/0]).

run() ->
    {ok, C} = scribe_logger:start("localhost", 1463),

    io:format("Connected ~p~n", [C]),

    Res = scribe_logger:log(C, "rest", "This is a test"),
    io:format("Log result ~p ~n", [Res]),

    {ok, Name} = scribe_logger:get_status(C),
    io:format("Name ~p~n",[Name]),
    ok.
