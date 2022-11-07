-module(hc_retained_cli).

-export([cmd/1]).

cmd(["arg1", "arg2"]) ->
    emqx_ctl:print("ok");

cmd(_) ->
    emqx_ctl:usage([{"cmd arg1 arg2", "cmd demo"}]).
