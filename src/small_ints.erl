-module(small_ints).

%% API exports
-export([decode_varint/1]).
-export([encode_varint/1]).
-export([decode_zigzag/1]).
-export([encode_zigzag/1]).
-export([decode_zigzag_varint/1]).
-export([encode_zigzag_varint/1]).

%%====================================================================
%% API functions
%%====================================================================

-spec decode_varint(binary()) -> {non_neg_integer(), binary()}.
decode_varint(Data) when is_binary(Data) ->
    decode_varint(Data, 0, 0).

-spec encode_varint(non_neg_integer()) -> binary().
encode_varint(I) when is_integer(I), I >= 0, I =< 127 ->
    <<I>>;
encode_varint(I) when is_integer(I), I > 127 ->
    <<1:1, (I band 127):7, (encode_varint(I bsr 7))/binary>>.

-spec decode_zigzag(non_neg_integer()) -> integer().
decode_zigzag(I) when I rem 2 == 0 -> I div 2;
decode_zigzag(I) when I rem 2 == 1 -> - (I div 2) - 1.

-spec encode_zigzag(integer()) -> non_neg_integer().
encode_zigzag(I) when is_integer(I), I >= 0 -> I * 2;
encode_zigzag(I) when is_integer(I), I < 0  -> - (I * 2) - 1.

-spec decode_zigzag_varint(binary()) -> {integer(), binary()}.
decode_zigzag_varint(Data) ->
    {I, Rest} = decode_varint(Data),
    {decode_zigzag(I), Rest}.

-spec encode_zigzag_varint(integer()) -> binary().
encode_zigzag_varint(I) ->
    encode_varint(encode_zigzag(I)).

%%====================================================================
%% Internal functions
%%====================================================================

decode_varint(<<1:1, Number:7, Rest/binary>>, Position, Acc) ->
    decode_varint(Rest, Position + 7, (Number bsl Position) + Acc);
decode_varint(<<0:1, Number:7, Rest/binary>>, Position, Acc) ->
    {(Number bsl Position) + Acc, Rest}.

%%====================================================================
%% Tests
%%====================================================================

-ifdef(TEST).

-include_lib("eunit/include/eunit.hrl").

decode_varint_test() ->
    ?assertEqual({1, <<>>}, decode_varint(<<1:8>>)),
    ?assertEqual({1, <<"foo">>}, decode_varint(<<1:8, "foo">>)),
    ?assertEqual({300, <<>>}, decode_varint(<<44034:16>>)),
    ?assertEqual({300, <<"bar">>}, decode_varint(<<44034:16, "bar">>)).

encode_varint_test() ->
    ?assertEqual(<<1:8>>, encode_varint(1)),
    ?assertEqual(<<44034:16>>, encode_varint(300)).

decode_zigzag_test() ->
    ?assertEqual(0, decode_zigzag(0)),
    ?assertEqual(-1, decode_zigzag(1)),
    ?assertEqual(1, decode_zigzag(2)),
    ?assertEqual(5, decode_zigzag(10)),
    ?assertEqual(-5, decode_zigzag(9)).

encode_zigzag_test() ->
    ?assertEqual(0, encode_zigzag(0)),
    ?assertEqual(1, encode_zigzag(-1)),
    ?assertEqual(2, encode_zigzag(1)),
    ?assertEqual(15, encode_zigzag(-8)),
    ?assertEqual(100, encode_zigzag(50)),
    ?assertEqual(4294967294, encode_zigzag(2147483647)).

decode_zigzag_varint_test() ->
    ?assertEqual({2, <<"foo">>}, decode_zigzag_varint(<<4:8, "foo">>)).

encode_zigzag_varint_test() ->
    ?assertEqual(<<17:8>>, encode_zigzag_varint(-9)).

-endif.
