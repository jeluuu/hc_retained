-module(hc_retained_utils).

-export([encrypt/1
  , decrypt/1
  ,num/1]).


encrypt(Message) ->
    crypto:crypto_one_time(aes_128_ctr,<<1:128>>,<<0:128>> ,Message ,true).

decrypt(Message) ->
    crypto:crypto_one_time(aes_128_ctr,<<1:128>>,<<0:128>> ,Message ,false).

% Length of the list
num(L) ->
    length([X || X <- L, X < 1]).