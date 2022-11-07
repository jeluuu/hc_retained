-module(hc_retained_app).

-behaviour(application).

-emqx_plugin(?MODULE).

-export([ start/2
        , stop/1
        ]).

start(_StartType, _StartArgs) ->
    Env = application:get_all_env(hc_retained),
    {ok, Sup} = hc_retained_sup:start_link(Env),
    % hc_retained:load(application:get_all_env()),
    hc_retained:load(Env),
    {ok, Sup}.

stop(_State) ->
    hc_retained:unload().