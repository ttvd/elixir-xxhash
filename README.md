elixir-xxhash
======

This is a pure Elixir implementation of [xxHash](https://github.com/Cyan4973/xxHash)

## Usage
Add dependency in your mix.exs file:
```
def deps do
  [{:xxhash, "~> 0.2"}]
end
```
Once this is done, execute mix deps.get to fetch and compile elixir-xxhash.

## Running in iex
Run with iex -S mix
```
iex(4)> XXHash.xxh32("")
0
iex(5)> XXHash.xxh32("0")
1212501170
iex(6)> XXHash.xxh32("abcd")
2741253893
iex(7)> XXHash.xxh32("abcde")
2537091483
iex(8)> XXHash.xxh32("xxhash") == XXHash.xxh32("xxhash")
true
iex(9)> XXHash.xxh32("0123456789abcde")
498989583
iex(10)> XXHash.xxh32("0123456789abcdef")
3267648361
iex(11)> XXHash.xxh32("0123456789abcdefg")
3430527511
```

## Limitations
* This is still work in progress.
* Only 32 bit basic hashing is implemented (XXH32).

## Notes
* You should consider creating a NIF of [xxHash](https://github.com/Cyan4973/xxHash) if you require a high performance version.

## License and copyright
* (c) 2015, Mykola Konyk
* Original [xxHash](https://github.com/Cyan4973/xxHash) (c) 2012-2014, Yann Collet
* Distributed under the [MS-RL License.](http://opensource.org/licenses/MS-RL)
