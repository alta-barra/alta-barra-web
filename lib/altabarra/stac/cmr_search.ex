defmodule Altabarra.Stac.CMRSearch do
  @moduledoc """
  STAC search module that uses NASA's Common Metadata Repository (CMR) as the data source.
  """

  alias Altabarra.LRUCache, as: FastCache
  alias Altabarra.Cache
  alias Altabarra.Stac.SearchKeyGenerator

  use Tesla

  @collection_cache :cmr_collection_cache
  @cmr_root "https://cmr.earthdata.nasa.gov"

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
      case FastCache.get(@collection_cache, collection_concept_id) do
        nil -> fetch_and_cache_collection(collection_concept_id)
        cached_result -> cached_result
      end

    %{
      "type" => "Feature",
      "id" => granule["title"],
      "collection" => granule["collection_concept_id"],
      "geometry" => parse_granule_geometry(granule),
      "properties" => %{
        "datetime" => granule["time_start"],
        "start_datetime" => granule["time_start"],
        "end_datetime" => granule["time_end"],
        "created" => granule["insert_time"],
        "updated" => granule["update_time"],
        "cmr:granule_ur" => granule["title"],
        "cmr:concept_id" => granule["id"]
      },
      "assets" => convert_granule_links_to_assets(granule["links"]),
      "links" => [
        %{
          "rel" => "self",
          "href" => "#{base_url}/collections/#{collection_id}/items/#{granule["title"]}"
        },
        %{
          "rel" => "parent",
          "href" => "#{base_url}/collections/#{collection_id}"
        },
        %{
          "rel" => "collection",
          "href" => "#{base_url}/collections/#{collection_id}"
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
      FastCache.put(@collection_cache, collection["id"], collection["short_name"])
      collection["short_name"]
    else
      _ -> nil
    end
  end

  defp convert_collection_to_stac_collection(collection, base_url) do
    cmr_concept_id = collection["id"]

    %{
      "type" => "Collection",
      "id" => collection["short_name"],
      "stac_version" => "1.0.0",
      "description" => collection["summary"],
      "license" => "various",
      "extent" => %{
        "spatial" => %{
          "bbox" => parse_bbox(collection["boxes"])
        },
        "temporal" => %{
          "interval" => [[collection["time_start"], collection["time_end"]]]
        }
      },
      "properties" => %{
        "cmr:provider" => collection["id"] |> String.split(~r/-/) |> Enum.at(1),
        "cmr:concept_id" => collection["id"],
        "cmr:revision_id" => collection["revision_id"],
        "cmr:dataset_id" => collection["dataset_id"]
      },
      "links" => [
        %{"rel" => "self", "href" => "#{base_url}/collections/#{collection["short_name"]}"},
        %{
          "rel" => "items",
          "href" => "#{base_url}/collections/#{collection["short_name"]}/items"
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

  defp parse_granule_geometry(%{"boxes" => geometry}) do
    IO.inspect(geometry)
    "BOX"
  end

  defp parse_granule_geometry(%{"polygons" => geometry}) do
    IO.inspect(geometry)
    "POLYGONS"
  end

  defp parse_granule_geometry(%{"points" => geometry}) do
    IO.inspect(geometry)
    "POINTS"
  end

  defp parse_granule_geometry(%{"lines" => geometry}) do
    IO.inspect(geometry)
    "LINES"
  end

  defp parse_bbox(boxes) do
    boxes
    |> Enum.at(0, "")
    |> case do
      "" ->
        []

      box ->
        box
        |> String.split(~r/\s/)
        |> Enum.map(fn s ->
          case Float.parse(s) do
            {num, _} -> num
            :error -> nil
          end
        end)
        |> Enum.reject(&is_nil/1)
    end
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
end
