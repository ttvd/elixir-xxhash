defmodule XXHashTest do
  use ExUnit.Case

  describe "32 bit implementation" do
    test "with empty string and default seed" do
      assert XXHash.xxh32("") == 46_947_589
    end

    test "with a string < 16 characters" do
      assert XXHash.xxh32("howdy") == 3_656_460_142
    end

    test "with a string < 16 characters using 8bit and 32bit buffers" do
      assert XXHash.xxh32("howdyhowdy") == 2_955_902_467
    end

    test "with a string > 16 characters" do
      assert XXHash.xxh32("howdyhowdymoomoohowdyhowdymoomoo") == 3_515_583_491
    end

    test "with a seed of '10'" do
      assert XXHash.xxh32("howdyhowdymoomoohowdyhowdymoomoo", 10) == 1_124_996_114
    end
  end

  describe "64 bit implementation" do
    test "with empty string and default seed" do
      assert XXHash.xxh64("") == 17_241_709_254_077_376_921
    end

    test "with a string < 16 characters" do
      assert XXHash.xxh64("howdy") == 10_631_137_994_255_926_386
    end

    test "with a string < 16 characters using 8bit, 32bit, and 64bit buffers" do
      assert XXHash.xxh64("howdyhowdy") == 2_144_175_473_417_988_058
    end

    test "with a string > 16 characters" do
      assert XXHash.xxh64("howdyhowdymoomoohowdyhowdymoomoo") == 13_228_332_242_145_796_837
    end

    test "with a seed of '10'" do
      assert XXHash.xxh64("howdyhowdymoomoohowdyhowdymoomoo", 10) == 8_226_117_543_209_784_396
    end
  end
end
