-module(hc_retained).

-behaviour(gen_server).

% -include("emqx_retainer.hrl").
% -include_lib("emqx/include/emqx.hrl").
% -include_lib("emqx/include/logger.hrl").
-include("emqx.hrl").
% -include("logger.hrl").             %change to above code when connected to server
% -include_lib("stdlib/include/ms_transform.hrl").
% -include_lib("stdlib-3.17.2.1/include/ms_transform.hrl").


% -logger_header("[HC_Retained]").

% -export([start_link/1]).

-export([ load/1
        , unload/0
        ]).

-export([ on_session_subscribed/4
        , on_message_delivered/3
        , on_message_publish/2
        ]).

% -export([clean/1]).

% %% gen_server callbacks
% -export([ init/1
%         , handle_call/3
%         , handle_cast/2
%         , handle_info/2
%         , terminate/2
%         , code_change/3
%         ]).


load(Env) ->
    emqx:hook('session.subscribed',  {?MODULE, on_session_subscribed, [Env]}),
    emqx:hook('message.publish',     {?MODULE, on_message_publish, [Env]}),
    emqx:hook('message.delivered',   {?MODULE, on_message_delivered, [Env]}).

unload() -> 
    emqx:unhook('session.subscribed',  {?MODULE, on_session_subscribed}),
    emqx:unhook('message.publish',     {?MODULE, on_message_publish}),
    emqx:unhook('message.delivered',   {?MODULE, on_message_delivered}).



on_session_subscribed(#{clientid := ClientId}, Topic, SubOpts, _Env) ->
    
    io:format("Session(~s) subscribed ~s with subopts: ~p~n", [ClientId, Topic, SubOpts]).


on_message_delivered(_ClientInfo = #{clientid := ClientId}, Message, _Env) ->
    io:format("Message delivered to client(~s): ~s~n",
              [ClientId, emqx_message:format(Message)]),
    {ok, Message}.

on_message_publish(Message = #message{topic = <<"$SYS/", _/binary>>}, _Env) ->
    {ok, Message};

on_message_publish(Message, _Env) ->
    io:format("Publish ~s~n", [emqx_message:format(Message)]),
    % io:format("-------------home ---~nPublish ~s~n", [Message]),
    % emqx_hoolva_chat_actions:publish(Message),
    {ok, Message}.