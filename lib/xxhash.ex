defmodule XXHash do
  use Bitwise

  defmodule Int32 do
    def prime_1, do: 2_654_435_761
    def prime_2, do: 2_246_822_519
    def prime_3, do: 3_266_489_917
    def prime_4, do: 668_265_263
    def prime_5, do: 374_761_393

    def add(a, b), do: (a + b) |> mask
    def sub(a, b), do: (a - b) |> mask
    def mul(a, b), do: (a * b) |> mask
    def lshift(a, b), do: a <<< b |> mask
    def rshift(a, b), do: a >>> b
    def xor(a, b), do: (a ^^^ b) |> mask
    def rotl(a, b), do: lshift(a, b) ||| rshift(a, 32 - b)
    def rshift_xor(a, b), do: a |> xor(rshift(a, b))
    def read(<<a::32>>) when <<1::32-little>> != <<1::32-native>>, do: a
    def read(<<a::32>>), do: byteswap(a)
    defp mask(a), do: a &&& 0xFFFFFFFF

    defp byteswap(a) do
      <<b::32-big>> = <<a::32-little>>
      b
  end
  end

  defmodule Int64 do
    def prime_1, do: 11_400_714_785_074_694_791
    def prime_2, do: 14_029_467_366_897_019_727
    def prime_3, do: 1_609_587_929_392_839_161
    def prime_4, do: 9_650_029_242_287_828_579
    def prime_5, do: 2_870_177_450_012_600_261

    def add(a, b), do: (a + b) |> mask
    def sub(a, b), do: (a - b) |> mask
    def mul(a, b), do: (a * b) |> mask
    def lshift(a, b), do: a <<< b |> mask
    def rshift(a, b), do: a >>> b
    def xor(a, b), do: (a ^^^ b) |> mask
    def rotl(a, b), do: lshift(a, b) ||| rshift(a, 64 - b)
    def rshift_xor(a, b), do: a |> xor(rshift(a, b))
    def read(<<a::64>>) when <<1::64-little>> != <<1::64-native>>, do: a
    def read(<<a::64>>), do: byteswap(a)
    def mask(a), do: a &&& 0xFFFFFFFFFFFFFFFF

    defp byteswap(a) do
      <<b::64-big>> = <<a::64-little>>
      b
  end
  end

  @spec xxh32(binary | term, non_neg_integer, non_neg_integer) :: non_neg_integer
  def xxh32(input), do: xxh32(input, String.length(input), 0)

  @spec xxh32(binary | term, non_neg_integer) :: non_neg_integer
  def xxh32(input, seed), do: xxh32(input, String.length(input), seed)

  @spec xxh32(binary | term, non_neg_integer, non_neg_integer) :: non_neg_integer
  def xxh32(<<>>, _length, _seed), do: 0

  @spec xxh32(binary | term, non_neg_integer, non_neg_integer) :: non_neg_integer
  def xxh32(input, length, seed) do
    {h32, buffer} =
      if length >= 16 do
        do_xxh32(0, seed, input)
      else
        {Int32.add(seed, Int32.prime_5()), input}
      end

    h32
    |> Int32.add(length)
    |> do_xxh32(seed, buffer)
    |> Int32.rshift_xor(15)
    |> Int32.mul(Int32.prime_2())
    |> Int32.rshift_xor(13)
    |> Int32.mul(Int32.prime_3())
    |> Int32.rshift_xor(16)
  end

  @spec do_xxh32(non_neg_integer, non_neg_integer, binary | term) :: non_neg_integer
  defp do_xxh32(h, seed, <<_a::32, _b::32, _c::32, _d::32, _rest::binary>> = all) do
    v1 = Int32.add(seed, Int32.prime_1()) |> Int32.add(Int32.prime_2())
    v2 = Int32.add(seed, Int32.prime_2())
    v3 = Int32.add(seed, 0)
    v4 = Int32.sub(seed, Int32.prime_1())
    do_xxh32(h, seed, all, {v1, v2, v3, v4})
  end

  @spec do_xxh32(non_neg_integer, non_neg_integer, binary | term) :: non_neg_integer
  defp do_xxh32(h, _seed, <<>>), do: h

  @spec do_xxh32(non_neg_integer, non_neg_integer, binary | term) :: non_neg_integer
  defp do_xxh32(h, seed, <<p::32, rest::binary>>) do
    Int32.read(<<p::32>>)
    |> Int32.mul(Int32.prime_3())
    |> Int32.add(h)
    |> Int32.rotl(17)
    |> Int32.mul(Int32.prime_4())
    |> do_xxh32(seed, rest)
  end

  @spec do_xxh32(non_neg_integer, non_neg_integer, binary | term) :: non_neg_integer
  defp do_xxh32(h, seed, <<p::8, rest::binary>>) do
    Int32.mul(p, Int32.prime_5())
    |> Int32.add(h)
    |> Int32.rotl(11)
    |> Int32.mul(Int32.prime_1())
    |> do_xxh32(seed, rest)
  end

  @spec do_xxh32(non_neg_integer, non_neg_integer, binary | term, tuple) :: non_neg_integer
  defp do_xxh32(h, seed, <<a::32, b::32, c::32, d::32, rest::binary>>, {v1, v2, v3, v4}) do
    cv =
      &(Int32.read(&1)
        |> Int32.mul(Int32.prime_2())
        |> Int32.add(&2)
        |> Int32.rotl(13)
        |> Int32.mul(Int32.prime_1()))

    do_xxh32(
      h,
      seed,
      rest,
      {cv.(<<a::32>>, v1), cv.(<<b::32>>, v2), cv.(<<c::32>>, v3), cv.(<<d::32>>, v4)}
    )
  end

  @spec do_xxh32(non_neg_integer, non_neg_integer, binary | term, tuple) :: non_neg_integer
  defp do_xxh32(_h, _seed, rest, {v1, v2, v3, v4}) do
    {Int32.rotl(v1, 1) + Int32.rotl(v2, 7) + Int32.rotl(v3, 12) + Int32.rotl(v4, 18), rest}
  end
end
