defmodule XXHash do
  @moduledoc """
  Elixir implementation of XXHash.
  Includes both 32 bit and 64 bit versions both outlined here:
  https://github.com/Cyan4973/xxHash/blob/dev/doc/xxhash_spec.md
  """
  use Bitwise

  @prime_32_1 2_654_435_761
  @prime_32_2 2_246_822_519
  @prime_32_3 3_266_489_917
  @prime_32_4 668_265_263
  @prime_32_5 374_761_393

  defmodule Int32 do
    def add(a, b), do: (a + b) |> mask
    def sub(a, b), do: (a - b) |> mask
    def mul(a, b), do: (a * b) |> mask
    def lshift(a, b), do: a <<< b |> mask
    def rshift(a, b), do: a >>> b
    def xor(a, b), do: Bitwise.bxor(a, b) |> mask
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

  @prime_64_1 11_400_714_785_074_694_791
  @prime_64_2 14_029_467_366_897_019_727
  @prime_64_3 1_609_587_929_392_839_161
  @prime_64_4 9_650_029_242_287_828_579
  @prime_64_5 2_870_177_450_012_600_261

  defmodule Int64 do
    def add(a, b), do: (a + b) |> mask
    def sub(a, b), do: (a - b) |> mask
    def mul(a, b), do: (a * b) |> mask
    def lshift(a, b), do: a <<< b |> mask
    def rshift(a, b), do: a >>> b
    def xor(a, b), do: Bitwise.bxor(a, b) |> mask
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

  # 32 bit empty binary hardcoded hash
  @spec xxh32(binary | term, non_neg_integer, non_neg_integer) :: non_neg_integer
  def xxh32(<<>>, _length, _seed), do: 46_947_589

  @spec xxh32(binary | term, non_neg_integer, non_neg_integer) :: non_neg_integer
  def xxh32(input, length, seed) do
    {h32, buffer} =
      if length >= 16 do
        do_xxh32(0, seed, input)
      else
        {Int32.add(seed, @prime_32_5), input}
      end

    h32
    |> Int32.add(length)
    |> do_xxh32(seed, buffer)
    |> Int32.rshift_xor(15)
    |> Int32.mul(@prime_32_2)
    |> Int32.rshift_xor(13)
    |> Int32.mul(@prime_32_3)
    |> Int32.rshift_xor(16)
  end

  # Seed accumulators
  @spec do_xxh32(non_neg_integer, non_neg_integer, binary | term) :: non_neg_integer
  defp do_xxh32(h, seed, <<_a::32, _b::32, _c::32, _d::32, _rest::binary>> = all) do
    v1 = Int32.add(seed, @prime_32_1) |> Int32.add(@prime_32_2)
    v2 = Int32.add(seed, @prime_32_2)
    v3 = Int32.add(seed, 0)
    v4 = Int32.sub(seed, @prime_32_1)
    do_xxh32(h, seed, all, {v1, v2, v3, v4})
  end

  @spec do_xxh32(non_neg_integer, non_neg_integer, binary | term) :: non_neg_integer
  defp do_xxh32(h, _seed, <<>>), do: h

  # Consume remaining input in 32 bit chunks
  @spec do_xxh32(non_neg_integer, non_neg_integer, binary | term) :: non_neg_integer
  defp do_xxh32(h, seed, <<p::32, rest::binary>>) do
    Int32.read(<<p::32>>)
    |> Int32.mul(@prime_32_3)
    |> Int32.add(h)
    |> Int32.rotl(17)
    |> Int32.mul(@prime_32_4)
    |> do_xxh32(seed, rest)
  end

  # Consume remaining input in 8 bit chunks
  @spec do_xxh32(non_neg_integer, non_neg_integer, binary | term) :: non_neg_integer
  defp do_xxh32(h, seed, <<p::8, rest::binary>>) do
    Int32.mul(p, @prime_32_5)
    |> Int32.add(h)
    |> Int32.rotl(11)
    |> Int32.mul(@prime_32_1)
    |> do_xxh32(seed, rest)
  end

  # Process stripes
  @spec do_xxh32(non_neg_integer, non_neg_integer, binary | term, tuple) :: non_neg_integer
  defp do_xxh32(h, seed, <<a::32, b::32, c::32, d::32, rest::binary>>, {v1, v2, v3, v4}) do
    do_xxh32(
      h,
      seed,
      rest,
      {round32(v1, <<a::32>>), round32(v2, <<b::32>>), round32(v3, <<c::32>>),
       round32(v4, <<d::32>>)}
    )
  end

  # Convergence
  @spec do_xxh32(non_neg_integer, non_neg_integer, binary | term, tuple) :: non_neg_integer
  defp do_xxh32(_h, _seed, rest, {v1, v2, v3, v4}) do
    {Int32.rotl(v1, 1) + Int32.rotl(v2, 7) + Int32.rotl(v3, 12) + Int32.rotl(v4, 18), rest}
  end

  defp round32(acc_n, lane_n) do
    lane_n
    |> Int32.read()
    |> Int32.mul(@prime_32_2)
    |> Int32.add(acc_n)
    |> Int32.rotl(13)
    |> Int32.mul(@prime_32_1)
  end

  ## 64 bit implementation

  @spec xxh64(binary | term, non_neg_integer, non_neg_integer) :: non_neg_integer
  def xxh64(input), do: xxh64(input, String.length(input), 0)

  @spec xxh64(binary | term, non_neg_integer) :: non_neg_integer
  def xxh64(input, seed), do: xxh64(input, String.length(input), seed)

  # 64 bit empty binary hardcoded hash
  @spec xxh64(binary | term, non_neg_integer, non_neg_integer) :: non_neg_integer
  def xxh64(<<>>, _length, _seed), do: 17_241_709_254_077_376_921

  @spec xxh64(binary | term, non_neg_integer, non_neg_integer) :: non_neg_integer
  def xxh64(input, length, seed) do
    {h64, buffer} =
      if length >= 32 do
        do_xxh64(0, seed, input)
      else
        {Int64.add(seed, @prime_64_5), input}
      end

    h64
    |> Int64.add(length)
    |> do_xxh64(seed, buffer)
    |> Int64.rshift_xor(33)
    |> Int64.mul(@prime_64_2)
    |> Int64.rshift_xor(29)
    |> Int64.mul(@prime_64_3)
    |> Int64.rshift_xor(32)
  end

  # Seed accumulators
  @spec do_xxh64(non_neg_integer, non_neg_integer, binary | term) :: non_neg_integer
  defp do_xxh64(h, seed, <<_a::64, _b::64, _c::64, _d::64, _rest::binary>> = all) do
    v1 = Int64.add(seed, @prime_64_1) |> Int64.add(@prime_64_2)
    v2 = Int64.add(seed, @prime_64_2)
    v3 = Int64.add(seed, 0)
    v4 = Int64.sub(seed, @prime_64_1)
    do_xxh64(h, seed, all, {v1, v2, v3, v4})
  end

  @spec do_xxh64(non_neg_integer, non_neg_integer, binary | term) :: non_neg_integer
  defp do_xxh64(h, _seed, <<>>), do: h

  # Consume remaining input in 64 bit chunks
  @spec do_xxh64(non_neg_integer, non_neg_integer, binary | term) :: non_neg_integer
  defp do_xxh64(h, seed, <<p::64, rest::binary>>) do
    round64(0, Int64.read(<<p::64>>))
    |> Int64.xor(h)
    |> Int64.rotl(27)
    |> Int64.mul(@prime_64_1)
    |> Int64.add(@prime_64_4)
    |> do_xxh64(seed, rest)
  end

  # Consume remaining input in 32 bit chunks

  @spec do_xxh64(non_neg_integer, non_neg_integer, binary | term) :: non_neg_integer
  defp do_xxh64(h, seed, <<p::32, rest::binary>>) do
    Int32.read(<<p::32>>)
    |> Int64.mul(@prime_64_1)
    |> Int64.xor(h)
    |> Int64.rotl(23)
    |> Int64.mul(@prime_64_2)
    |> Int64.add(@prime_64_3)
    |> do_xxh64(seed, rest)
  end

  # Consume remaining input in 8 bit chunks
  @spec do_xxh64(non_neg_integer, non_neg_integer, binary | term) :: non_neg_integer
  defp do_xxh64(h, seed, <<p::8, rest::binary>>) do
    p
    |> Int64.mul(@prime_64_5)
    |> Int64.xor(h)
    |> Int64.rotl(11)
    |> Int64.mul(@prime_64_1)
    |> do_xxh64(seed, rest)
  end

  @spec do_xxh64(non_neg_integer, non_neg_integer, binary | term, tuple) :: non_neg_integer
  defp do_xxh64(h, seed, <<a::64, b::64, c::64, d::64, rest::binary>>, {v1, v2, v3, v4}) do
    do_xxh64(
      h,
      seed,
      rest,
      {round64(v1, Int64.read(<<a::64>>)), round64(v2, Int64.read(<<b::64>>)),
       round64(v3, Int64.read(<<c::64>>)), round64(v4, Int64.read(<<d::64>>))}
    )
  end

  @spec do_xxh64(non_neg_integer, non_neg_integer, binary | term, tuple) :: non_neg_integer
  defp do_xxh64(_h, _seed, rest, {v1, v2, v3, v4}) do
    acc =
      (Int64.rotl(v1, 1) + Int64.rotl(v2, 7) + Int64.rotl(v3, 12) + Int64.rotl(v4, 18))
      |> merge64(v1)
      |> merge64(v2)
      |> merge64(v3)
      |> merge64(v4)

    {acc, rest}
  end

  defp round64(acc_n, lane_n) do
    lane_n
    |> Int64.mul(@prime_64_2)
    |> Int64.add(acc_n)
    |> Int64.rotl(31)
    |> Int64.mul(@prime_64_1)
  end

  defp merge64(acc, acc_n) do
    0
    |> round64(acc_n)
    |> Int64.xor(acc)
    |> Int64.mul(@prime_64_1)
    |> Int64.add(@prime_64_4)
  end
end
