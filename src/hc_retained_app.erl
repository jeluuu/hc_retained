-module(hc_retained_app).

-behaviour(application).

-emqx_plugin(?MODULE).

-export([ start/2
        , stop/1
        ]).

start(_StartType, _StartArgs) ->
    {ok, Sup} = hc_retained_sup:start_link(),
    hc_retained:load(application:get_all_env()),
    {ok, Sup}.

stop(_State) ->
    hc_retained:unload().