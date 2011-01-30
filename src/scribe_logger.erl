-module(scribe_logger).

-behaviour(gen_server).

%% API
-export([start/2,
	 log/3,
         get_status/1]).

-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

-define(SERVER, ?MODULE).

-include("scribe_types.hrl").

-record(state, {client}).

start(Server, Port) ->
    gen_server:start_link(?MODULE, [Server, Port], []).

log(Client, Category, Message) ->
    gen_server:call(Client, {log, Category, Message}).

get_status(Client) ->
    gen_server:call(Client, get_status).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================
init([Host, Port]) ->
    {ok, Client} = thrift_client_util:new(Host, Port,
                                          scribe_thrift,
                                          [{strict_read, false},
                                           {strict_write, false},
                                           {framed, true}]),
    {ok, #state{client = Client}}.
handle_call({log, Category, Message}, _From, #state{client = Client} = State) ->
    case thrift_client:call(Client, 'Log',
                            [[#logEntry{category=Category,
                                        message=Message}]]) of
        {Client2, {ok, 0}} ->
            {reply, ok, State#state{client = Client2}};
        {Client2, {ok, 1}} ->
            {reply, {error, try_later}, State#state{client = Client2}}
    end;

handle_call(get_status, _From, #state{client = Client} = State) ->
    {Client2, Name} = thrift_client:call(Client, 'getStatus', []),
    {reply, {ok, Name}, State#state{client = Client2}};

handle_call(Request, _From, State) ->
    {stop, {unknown_call, Request}, State}.
handle_cast(_Msg, State) ->
    {noreply, State}.
handle_info(_Info, State) ->
    {noreply, State}.
terminate(_Reason, #state{client = Client} = _State) ->
    thrift_client:close(Client),
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
