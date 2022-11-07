-module(hc_retained_sup).

-behaviour(supervisor).

-export([start_link/0]).

-export([init/1]).

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
    % {ok, { {one_for_all, 0, 1}, []} }.
    SupFlags = #{strategy => one_for_one,
               intensity => 10,
               period => 10},
    ChildSpecs = [ #{id => hc_retained_actions, start => {hc_retained_actions, start_link, []}} ],
    {ok, {SupFlags, ChildSpecs}}.