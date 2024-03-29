-module(hc_retained_actions).

-behaviour(tivan_server).

-export([
    init/1
  % , publish/1
  , store/1
  % , send/1
  , retained/2
  ,put_chat/1
  ,get_chat/0
  ,get_chat/1
  ,delete_chat/1
]).

-export([start_link/0]).

start_link() ->
    tivan_server:start_link({local, ?MODULE}, ?MODULE, [], []).

put_chat(Chat) when is_map(Chat) ->
    tivan_server:put(?MODULE, hc_chat, Chat).

get_chat() ->
  get_chat(#{}).

get_chat(Options) when is_map(Options) ->
  tivan_server:get(?MODULE, hc_chat, Options).

delete_chat(UserUuid) when is_binary(UserUuid) ->
  delete_chat(#{uuid => UserUuid});
delete_chat(User) when is_map(User) ->
  tivan_server:remove(?MODULE, hc_chat, User).

init([]) ->
    TableDefs = #{
        hc_chat => #{columns => #{topic => #{type => binary
                                        , limit => 30
                                        , null => false}
                                , from_id => #{type => binary}
                                , message => #{type => binary}
                                , time => #{type => integer}
                                , qos => #{type => integer}
                                , status => #{type => binary
                                              ,limit => [<<"delivered">>, <<"undelivered">>]
                                              ,default => <<"undelivered">>
                                              ,index => true}
                                        
                                }
                        ,audit => true
                  }
        % topic => #{colums => #{}}
    },
    {ok, TableDefs}.

store(Message) ->
    io:format("~nMessage publish EMQX : ~p",[Message]),       %published by emqx payload
    MsgCheck = element(8,Message),
    case MsgCheck of
        <<"Connection Closed abnormally..!">> ->
            io:format("\nmqtt client closed successfully...!\n");
        _ ->
            % io:format("~n ------- checking jsx ----- ~n"),
            % DecodedMessage= [element(2,hd(jsx:decode(element(8,Message))))],
            DecodedMessage = jsx:decode(element(8,Message)),
            % io:format("sent message publish : ~p ~n",[DecodedMessage]),
            Topic = proplists:get_value(<<"to_id">>,DecodedMessage),
            io:format("to_id => ~p~n", [Topic]),
            From = proplists:get_value(<<"from">>,DecodedMessage),
            Message1 = proplists:get_value(<<"message">>,DecodedMessage),
            %change
            Message2 = hc_retained_utils:encrypt(Message1),
            % --
            Date = proplists:get_value(<<"time">>,DecodedMessage),
            %emqx_hoolva_chat_utils:self_message(Topic,Message1,DecodedMessage),
            Qos = proplists:get_value(<<"qos">>, DecodedMessage),
            ChatOutput = #{topic => Topic
                        , from_id => From
                        , message => Message2
                        , time => Date
                        , qos => Qos
                    },
            P = put_chat(ChatOutput),
            io:format("~ndata stored in DB"),
            {ok,P}
        
        end.

% send(Uuid) ->                                                 %sending to message to topic when already subscribed
%   io:format("~nmessage recived @ send !"),       
%   H = get_chat(Uuid),
%   P = maps:get(message, H),
%   Qos1 = maps:get(qos, H),
%   Topic = maps:get(topic, H),
%   From1 = maps:get(from_id, H),
%   Uuid1 = maps:get(uuid, H),
%   Message = hc_retained_utils:decrypt(P),
%   Data = emqx_message:make(From1,Qos1,Topic,Message),
%   emqx:publish(Data),
%   put_chat(#{uuid => Uuid1, status => <<"delivered">>}),
%   io:format("~nmessage send to ~p~n",[Topic]).



retained(Topic,B) ->
  % A = get_chat(#{topic => Topic, status => <<"undelivered">>}),
  case B of
    [] ->
      ok;
    _ ->
      messages(Topic,B)
    end.

messages(_,[]) ->
  ok;
messages(Topic,[H|T]) ->
  % Message = element(5,H),
  P = maps:get(message, H),
  Qos1 = maps:get(qos, H),
  From1 = maps:get(from_id, H),
  Uuid = maps:get(uuid, H),
  Message = hc_retained_utils:decrypt(P),

  % Data = emqx_message:make(Topic,Message),
  Data = emqx_message:make(From1,Qos1,Topic,Message),
  emqx:publish(Data),
  io:format("~nmessage send to ~p~n",[Topic]),
  % io:format("~nData - ~p ~n",[Data]),
  Response = put_chat(#{uuid => Uuid, status => <<"delivered">>}),
  % io:format("~nput chat -> ~p~n",[Response]),
  messages(Topic,T).




