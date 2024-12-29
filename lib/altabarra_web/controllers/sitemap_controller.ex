defmodule AltabarraWeb.SitemapController do
  @moduledoc """
  Dynamically create a sitemap.xml file to include blog entries for better SEO.
  """
  use AltabarraWeb, :controller

  alias Altabarra.Content, as: Blog

  @searchable_routes ["contact", "services", "blog", "apis"]

  def index(conn, _params) do
    conn
    |> put_resp_content_type("application/xml")
    |> render("index.xml", entries: get_entries())
  end

  defp get_entries() do
    blog_posts =
      Blog.list_published_posts()
      |> Enum.map(&to_sitemap_entry/1)

    static_pages = get_static_pages()

    static_pages ++ blog_posts
  end

  defp get_static_pages() do
    child_pages =
      @searchable_routes
      |> Enum.map(fn path ->
        %{
          url: "/#{path}",
          updated_at: DateTime.utc_now(), #TODO deep magic with git timestamps?
          changefreq: "monthly",
          priority: 0.9
        }
      end)

    index_page =
      %{url: ~p"/", updated_at: DateTime.utc_now(), changefreq: "monthly", priority: 1.0}

    [index_page] ++ child_pages
  end

  defp to_sitemap_entry(post) do
    %{
      url: ~p"/blog/#{post.slug}",
      updated_at: post.updated_at || post.published_at,
      changefreq: "monthly",
      priority: 0.6
    }
  end
end
