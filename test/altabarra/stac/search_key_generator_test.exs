defmodule Altabarra.Stac.SearchKeyGeneratorTest do
  use ExUnit.Case, async: true
  alias Altabarra.Stac.SearchKeyGenerator

  describe "generate_key/2" do
    test "generates a key with sorted params" do
      params = %{"b" => "2", "a" => "1", "c" => "3"}
      key = SearchKeyGenerator.generate_key(params, 1)
      assert String.starts_with?(key, "cmr_search:")
      assert String.ends_with?(key, ":page_1")
    end

    test "generates different keys for different page numbers" do
      params = %{"query" => "test"}
      key1 = SearchKeyGenerator.generate_key(params, 1)
      key2 = SearchKeyGenerator.generate_key(params, 2)
      assert key1 != key2
      assert String.ends_with?(key1, ":page_1")
      assert String.ends_with?(key2, ":page_2")
    end

    test "generates the same key for the same params and page number" do
      params = %{"query" => "test", "limit" => "10"}
      key1 = SearchKeyGenerator.generate_key(params, 1)
      key2 = SearchKeyGenerator.generate_key(params, 1)
      assert key1 == key2
    end

    test "handles empty params" do
      key = SearchKeyGenerator.generate_key(%{}, 1)
      assert String.starts_with?(key, "cmr_search:")
      assert String.ends_with?(key, ":page_1")
    end

    test "handles params with special characters" do
      params = %{"query" => "test&special=true"}
      key = SearchKeyGenerator.generate_key(params, 1)
      assert String.starts_with?(key, "cmr_search:")
      assert String.ends_with?(key, ":page_1")
    end

    test "generates different keys for different param orders" do
      params1 = %{"a" => "1", "b" => "2"}
      params2 = %{"b" => "2", "a" => "1"}
      key1 = SearchKeyGenerator.generate_key(params1, 1)
      key2 = SearchKeyGenerator.generate_key(params2, 1)
      assert key1 == key2
    end
  end
end
