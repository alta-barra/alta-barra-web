defmodule AltabarraWeb.StacController do
  use AltabarraWeb, :controller

  alias Altabarra.Stac.CMRSearch, as: Search

  def root_catalog(conn, _params) do
    base_url = get_base_url(conn)

    catalog = %{
      "type" => "Catalog",
      "id" => "cmr-stac-api",
      "stac_version" => "1.0.0",
      "description" =>
        "NASA CMR STAC API by Alta Barra. Please reference the official https://cmr.earthdata.nasa.gov/stac for any production based uses.",
      "links" => [
        %{
          "rel" => "self",
          "href" => "#{base_url}"
        },
        %{
          "rel" => "search",
          "href" => "#{base_url}/search"
        },
        %{
          "rel" => "collections",
          "href" => "#{base_url}/collections"
        },
        %{
          "rel" => "root",
          "href" => "#{base_url}"
        }
      ]
    }

    json(conn, catalog)
  end

  def search(conn, params) do
    base_url = get_base_url(conn)

    case Search.search_items(params, base_url) do
      {:ok, items} ->
        json(conn, %{type: "FeatureCollection", features: items})

      {:error, message} ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{error: message})
    end
  end

  def list_collections(conn, params) do
    base_url = get_base_url(conn)

    case Search.search_collections(params, base_url) do
      {:ok, collections} ->
        json(conn, %{collections: collections})

      {:error, message} ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{error: message})
    end
  end

  def get_collection(conn, %{"id" => id}) do
    base_url = get_base_url(conn)

    case Search.search_collections(%{"short_name" => id}, base_url) do
      {:ok, [collection | _]} ->
        json(conn, collection)

      {:ok, []} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Collection not found"})

      {:error, message} ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{error: message})
    end
  end

  def list_items(conn, %{"collection_id" => collection_id} = params) do
    base_url = get_base_url(conn)
    # First, we need to get the collection's concept_id
    case Search.search_collections(%{"short_name" => collection_id}, base_url) do
      {:ok, [collection | _]} ->
        collection_concept_id = collection["properties"]["cmr:concept_id"]

        params =
          params
          |> Map.put("collection_concept_id", collection_concept_id)
          |> Map.delete("collection_id")

        case Search.search_items(params, base_url) do
          {:ok, items} ->
            json(conn, %{type: "FeatureCollection", features: items})

          {:error, message} ->
            conn
            |> put_status(:internal_server_error)
            |> json(%{error: message})
        end

      {:ok, []} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Collection not found"})

      {:error, message} ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{error: message})
    end
  end

  def get_item(conn, %{"collection_id" => collection_id, "item_id" => item_id}) do
    base_url = get_base_url(conn)
    # First, we need to get the collection's concept_id
    case Search.search_collections(%{"short_name" => collection_id}, base_url) do
      {:ok, [collection | _]} ->
        concept_id = collection["properties"]["cmr:concept_id"]

        case Search.search_items(%{"short_name" => item_id, "collection" => concept_id}, base_url) do
          {:ok, [item | _]} ->
            json(conn, item)

          {:ok, []} ->
            conn
            |> put_status(:not_found)
            |> json(%{error: "Item not found"})

          {:error, message} ->
            conn
            |> put_status(:internal_server_error)
            |> json(%{error: message})
        end

      {:ok, []} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Collection not found"})

      {:error, message} ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{error: message})
    end
  end

  defp get_base_url(conn) do
    port = if conn.port in [80, 443], do: "", else: ":#{conn.port}"

    "#{conn.scheme}://#{conn.host}#{port}/api/stac"
  end
end
