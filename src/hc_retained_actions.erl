-module(hc_retained_actions).

-behaviour(tivan_server).

-export([
    init/1
%   , publish/1
%   , store/1
  ,put_chat/1
  ,get_chat/0
  ,get_chat/1
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