defmodule Altabarra.Stac.SearchKeyGenerator do
  @moduledoc """
  Provides functionality to generate unique keys for CMR (Common Metadata Repository) searches.

  This module is responsible for creating consistent and unique keys based on search parameters
  and page numbers. These keys can be used for caching search results or other purposes where
  a unique identifier for a specific search and page combination is needed.

  The generated keys are composed of three parts:
  1. A prefix ("cmr_search:")
  2. A hash of the sorted search parameters
  3. The page number

  ## Examples

      iex> params = %{"query" => "landsat", "limit" => "10"}
      iex> Altabarra.Stac.SearchKeyGenerator.generate_key(params, 1)
      "cmr_search:a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6:page_1"

  """

  @doc """
  Generates a unique key for a CMR search based on search parameters and page number.

  This function takes a map of search parameters and a page number, and returns a string
  that can be used as a unique key for that specific search and page combination.

  ## Parameters

    - search_params: A map containing the search parameters.
    - page_number: An integer representing the page number of the search results.

  ## Returns

  A string in the format "cmr_search:[hash]:page_[page_number]", where [hash] is a
  lowercase hexadecimal MD5 hash of the sorted and joined search parameters.

  ## Examples

      iex> params = %{"instrument" => "OLI", "cloud_cover" => "10"}
      iex> Altabarra.Stac.SearchKeyGenerator.generate_key(params, 2)
      "cmr_search:7d9fe7dcef5d6c0d37c24e7bf3a63b1e:page_2"

      iex> Altabarra.Stac.SearchKeyGenerator.generate_key(%{}, 1)
      "cmr_search:d41d8cd98f00b204e9800998ecf8427e:page_1"

  """
  @spec generate_key(map(), integer()) :: String.t()
  def generate_key(search_params, page_number) do
    params_hash = generate_params_hash(search_params)
    "cmr_search:#{params_hash}:page_#{page_number}"
  end

  @spec generate_params_hash(map()) :: String.t()
  defp generate_params_hash(search_params) do
    search_params
    |> Enum.sort_by(fn {k, _} -> k end)
    |> Enum.map_join("&", fn {k, v} -> "#{k}=#{v}" end)
    |> (&:crypto.hash(:md5, &1)).()
    |> Base.encode16(case: :lower)
  end
end
