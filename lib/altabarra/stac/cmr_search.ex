defmodule Altabarra.Stac.CMRSearch do
  @moduledoc """
  STAC search module that uses NASA's Common Metadata Repository (CMR) as the data source.
  """

  alias Altabarra.LRUCache, as: FastCache
  alias Altabarra.Stac.GeoUtils

  use Tesla

  @stac_cache Altabarra.LRUCache.CMRCollectionCache
  @cmr_root "https://cmr.earthdata.nasa.gov"
  @providers_cache_key "cmr_providers"

  plug Tesla.Middleware.BaseUrl, @cmr_root
  plug Tesla.Middleware.JSON

  @doc """
  Search for STAC items (granules) based on the given parameters.
  """
  def search_items(params, base_url) do
    {:ok, response} = get("/search/granules.json", query: convert_params(params))

    case response.status do
      200 ->
        items =
          Enum.map(response.body["feed"]["entry"], &convert_granule_to_stac_item(&1, base_url))

        {:ok, items}

      _ ->
        {:error, "Failed to fetch granules: #{response.status}"}
    end
  end

  @doc """
  Search for STAC collections based on the given parameters.
  """
  def search_collections(params, base_url) do
    {:ok, response} = get("/search/collections.json", query: convert_params(params))

    case response.status do
      200 ->
        collections =
          Enum.map(
            response.body["feed"]["entry"],
            &convert_collection_to_stac_collection(&1, base_url)
          )

        {:ok, collections}

      _ ->
        {:error, "Failed to fetch collections: #{response.status}"}
    end
  end

  defp convert_params(params) do
    # Convert STAC parameters to CMR parameters
    Enum.map(params, fn
      {"limit", value} -> {"page_size", value}
      {"bbox", value} -> {"bounding_box", value}
      {"datetime", value} -> {"temporal", value}
      {"collection", value} -> {"collection_concept_id", value}
      {key, value} -> {key, value}
    end)
  end

  defp convert_granule_to_stac_item(granule, base_url) do
    cmr_concept_id = granule["id"]
    collection_concept_id = granule["collection_concept_id"]

    collection_id =
      case FastCache.get(@stac_cache, collection_concept_id) do
        nil -> fetch_and_cache_collection(collection_concept_id)
        cached_result -> cached_result
      end

    bbox = GeoUtils.spatial_to_bbox(granule)

    provider = granule["data_center"]

    %{
      "stac_version" => "1.1.0",
      "stac_extensions" => [],
      "type" => "Feature",
      "id" => granule["title"],
      "collection" => collection_id,
      # NOTE: bbox for ITEMS is a flat array
      "bbox" => bbox,
      "properties" =>
        remove_null_values(%{
          "datetime" => granule["time_start"],
          "start_datetime" => granule["time_start"],
          "end_datetime" => granule["time_end"],
          "created" => granule["insert_time"],
          "updated" => granule["update_time"],
          "cmr:granule_ur" => granule["title"],
          "cmr:concept_id" => granule["id"],
          "cmr:dataset_id" => granule["dataset_id"],
          "cmr:data_center" => granule["data_center"],
          "cmr:collection_concept_id" => granule["collection_concept_id"]
        }),
      "assets" => convert_granule_links_to_assets(granule["links"]),
      "links" => [
        %{
          "rel" => "self",
          "href" =>
            "#{base_url}/#{provider}/collections/#{collection_id}/items/#{granule["title"]}"
        },
        %{
          "rel" => "parent",
          "href" => "#{base_url}/#{provider}/collections/#{collection_id}"
        },
        %{
          "rel" => "collection",
          "href" => "#{base_url}/#{provider}/collections/#{collection_id}"
        },
        %{
          "rel" => "via",
          "href" => "#{@cmr_root}/search/concepts/#{cmr_concept_id}.json",
          "type" => "application/json",
          "title" => "CMR JSON"
        },
        %{
          "rel" => "via",
          "href" => "#{@cmr_root}/search/concepts/#{cmr_concept_id}.xml",
          "type" => "application/xml",
          "title" => "CMR ECHO10"
        },
        %{
          "rel" => "via",
          "href" => "#{@cmr_root}/search/concepts/#{cmr_concept_id}.umm_json",
          "type" => "application/vnd.nasa.cmr.umm+json",
          "title" => "CMR UMM-G"
        }
      ]
    }
  end

  defp fetch_and_cache_collection(collection_concept_id) do
    with {:ok, response} <-
           get("/search/collections.json", query: %{"concept_id" => collection_concept_id}),
         [collection | _] <- response.body["feed"]["entry"] do
      FastCache.put(@stac_cache, collection["id"], collection["short_name"])
      collection["short_name"]
    else
      _ -> nil
    end
  end

  defp convert_collection_to_stac_collection(collection, base_url) do
    cmr_concept_id = collection["id"]
    bbox = GeoUtils.spatial_to_bbox(collection)
    provider = collection["id"] |> String.split(~r/-/) |> Enum.at(1)

    %{
      "stac_version" => "1.1.0",
      "stac_extensions" => [],
      "type" => "Collection",
      "id" => collection["short_name"],
      "license" => "other",
      "title" => collection["short_name"],
      "description" => collection["summary"],
      "extent" => %{
        "spatial" => %{
          # NOTE: STAC Collection bbox is an array of arrays
          "bbox" => [bbox]
        },
        "temporal" => %{
          "interval" => [[collection["time_start"], collection["time_end"]]]
        }
      },
      "properties" =>
        remove_null_values(%{
          "cmr:provider" => provider,
          "cmr:concept_id" => collection["id"],
          "cmr:revision_id" => collection["revision_id"],
          "cmr:dataset_id" => collection["dataset_id"]
        }),
      "links" => [
        %{
          "rel" => "self",
          "href" => "#{base_url}/#{provider}collections/#{collection["short_name"]}"
        },
        %{
          "rel" => "items",
          "href" => "#{base_url}/#{provider}/collections/#{collection["short_name"]}/items"
        },
        %{"rel" => "root", "href" => base_url},
        %{
          "rel" => "via",
          "href" => "#{@cmr_root}/search/concepts/#{cmr_concept_id}.json",
          "type" => "application/json",
          "title" => "CMR JSON"
        },
        %{
          "rel" => "via",
          "href" => "#{@cmr_root}/search/concepts/#{cmr_concept_id}.xml",
          "type" => "application/xml",
          "title" => "CMR ECHO10"
        },
        %{
          "rel" => "via",
          "href" => "#{@cmr_root}/search/concepts/#{cmr_concept_id}.umm_json",
          "type" => "application/vnd.nasa.cmr.umm+json",
          "title" => "CMR UMM-C"
        }
      ]
    }
  end

  defp remove_null_values(%{} = map) do
    Enum.into(
      Enum.reject(map, fn {_k, v} ->
        if is_map(v), do: remove_null_values(v)
        is_nil(v)
      end),
      %{}
    )
  end

  defp convert_granule_links_to_assets(links) do
    Enum.reduce(links, %{}, fn link, acc ->
      Map.put(acc, link["rel"], %{
        "href" => link["href"],
        "type" => link["type"],
        "title" => link["title"]
      })
    end)
  end

  def fetch_providers do
    case FastCache.get(Altabarra.LRUCache.Default, @providers_cache_key) do
      nil -> fetch_and_cache_providers()
      cached_result -> {:ok, decode_cached_result(cached_result)}
    end
  end

  def provider_exists?(provider) do
    with {:ok, providers} <- fetch_providers() do
      Enum.any?(providers, &(&1 == provider))
    end
  end

  defp fetch_and_cache_providers do
    case get("/search/providers") do
      {:ok, %{status: 200, body: body}} ->
        provider_ids = extract_provider_ids(body)
        cache_provider_ids(provider_ids)
        {:ok, provider_ids}

      {:ok, %{status: status}} ->
        {:error, "Failed to fetch providers: HTTP #{status}"}

      {:error, reason} ->
        {:error, "Request failed: #{inspect(reason)}"}
    end
  end

  defp extract_provider_ids(body) do
    body["items"]
    |> Enum.reject(&is_nil/1)
    |> Enum.map(fn provider ->
      provider["Organizations"]
      |> List.first()
      |> Map.get("ShortName")
    end)
  end

  defp cache_provider_ids(provider_ids) do
    encoded_ids = :erlang.term_to_binary(provider_ids)
    FastCache.put(Altabarra.LRUCache.Default, @providers_cache_key, encoded_ids)
  end

  defp decode_cached_result(cached_result) do
    :erlang.binary_to_term(cached_result)
  end
end
