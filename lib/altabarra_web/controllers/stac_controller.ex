defmodule AltabarraWeb.StacController do
  use AltabarraWeb, :controller

  alias Altabarra.Stac.CMRSearch, as: Stac

  @cmr_page_size_max 2000

  def root_catalog(conn, _params) do
    base_url = get_base_url(conn)

    catalog = %{
      "type" => "Catalog",
      "id" => "alta-barra-stac-api",
      "stac_version" => "1.0.0",
      "description" =>
        "NASA CMR STAC API by Alta Barra. Please reference the official https://cmr.earthdata.nasa.gov/stac for any production based uses.",
      "links" =>
        [
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
        ] ++ get_cmr_provider_catalog_links(base_url)
    }

    json(conn, catalog)
  end

  defp get_cmr_provider_catalog_links(base_url) do
    with {:ok, providers} <- Stac.fetch_providers() do
      providers
      |> Enum.map(fn provider ->
        %{
          "rel" => "child",
          "href" => "#{base_url}/#{provider}",
          "type" => "application/json"
        }
      end)
    end
  end

  def get_catalog(conn, %{"provider" => provider}) do
    base_url = get_base_url(conn)

    case Stac.provider_exists?(provider) do
      true ->
        catalog = %{
          "type" => "Catalog",
          "id" => "#{provider}",
          "stac_version" => "1.0.0",
          "description" =>
            "#{provider} Please reference the official https://cmr.earthdata.nasa.gov/stac for any production based uses.",
          "links" =>
            [
              %{
                "rel" => "self",
                "href" => "#{base_url}/#{provider}"
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
            ] ++ get_provider_collections(conn, provider)
        }

        json(conn, catalog)

      false ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Provider not found"})
    end
  end

  defp get_provider_collections(conn, provider) do
    base_url = get_base_url(conn)

    case Stac.search_collections(%{provider: provider, page_size: @cmr_page_size_max}, base_url) do
      {:ok, collections} ->
        collections
        |> Enum.map(fn %{"id" => id} ->
          %{
            "rel" => "child",
            "href" => "#{base_url}/collections/#{id}",
            "type" => "application/json"
          }
        end)

      {:error, message} ->
        IO.inspect(message)
        []
    end
  end

  def search(conn, _params) do
    redirect(conn, to: ~p"/api/stac")
    # base_url = get_base_url(conn)

    # case Stac.search_items(params, base_url) do
    #   {:ok, items} ->
    #     json(conn, %{type: "FeatureCollection", features: items})

    #   {:error, message} ->
    #     conn
    #     |> put_status(:internal_server_error)
    #     |> json(%{error: message})
    # end
  end

  def list_collections(conn, params) do
    base_url = get_base_url(conn)

    case Stac.search_collections(params, base_url) do
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

    case Stac.search_collections(%{"short_name" => id}, base_url) do
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
    case Stac.search_collections(%{"short_name" => collection_id}, base_url) do
      {:ok, [collection | _]} ->
        collection_concept_id = collection["properties"]["cmr:concept_id"]

        params =
          params
          |> Map.put("collection_concept_id", collection_concept_id)
          |> Map.delete("collection_id")

        case Stac.search_items(params, base_url) do
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
    case Stac.search_collections(%{"short_name" => collection_id}, base_url) do
      {:ok, [collection | _]} ->
        concept_id = collection["properties"]["cmr:concept_id"]

        case Stac.search_items(%{"granule_ur" => item_id, "collection" => concept_id}, base_url) do
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
