# small_ints

`small_ints` is an Erlang module that can help you deal with encoding and
decoding of integers using the varint and ZigZag algorithms described in the
["Encoding" section][docs-protobuf] of Google Protocol Buffer's docs.

## Building

    $ rebar3 compile

### Varint

Basically, you use a variable number of bytes to represent a positive
integer. You can encode varints to binaries and decode them from binaries like
this:

```erlang
small_ints:encode_varint(5).    %=> <<5>>
small_ints:encode_varint(1034). %=> <<138,8>>

small_ints:decode_varint(<<5,"foo">>). %=> {5, <<"foo">>}
small_ints:decode_varint(<<138,8>>). %=> {1034, <<>>}
```

### ZigZag

The ZigZag algorithm is used to encode small positive *and negative* numbers
with a small number of bytes.

```erlang
small_ints:encode_zigzag(1).  %=> 2
small_ints:encode_zigzag(-5). %=> 9

small_ints:decode_zigzag(6).  %=> 3
```

### Other stuff

`small_ints` also provides two utility functions which just combine the varint
and ZigZag algorithms:

* `small_ints:decode_zigzag_varint/1`: decodes the next varint from the given
  binary and then decodes it with ZigZag
* `small_ints:encode_zigzag_varint/1`: encodes the given integer with ZigZag,
  then encodes the result with varint

## License

MIT License &copy; 2015, Andrea Leopardi


[docs-protobuf]: https://developers.google.com/protocol-buffers/docs/encoding
