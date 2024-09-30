defmodule AltabarraWeb.PageViewControllerTest do
  use AltabarraWeb.ConnCase

  import Altabarra.AnalyticsFixtures

  @create_attrs %{timestamp: ~N[2024-09-29 17:39:00], url: "some url", user_agent: "some user_agent", ip_address: "some ip_address", referer: "some referer"}
  @update_attrs %{timestamp: ~N[2024-09-30 17:39:00], url: "some updated url", user_agent: "some updated user_agent", ip_address: "some updated ip_address", referer: "some updated referer"}
  @invalid_attrs %{timestamp: nil, url: nil, user_agent: nil, ip_address: nil, referer: nil}

  describe "index" do
    test "lists all page_views", %{conn: conn} do
      conn = get(conn, ~p"/page_views")
      assert html_response(conn, 200) =~ "Listing Page views"
    end
  end

  describe "new page_view" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/page_views/new")
      assert html_response(conn, 200) =~ "New Page view"
    end
  end

  describe "create page_view" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/page_views", page_view: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/page_views/#{id}"

      conn = get(conn, ~p"/page_views/#{id}")
      assert html_response(conn, 200) =~ "Page view #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/page_views", page_view: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Page view"
    end
  end

  describe "edit page_view" do
    setup [:create_page_view]

    test "renders form for editing chosen page_view", %{conn: conn, page_view: page_view} do
      conn = get(conn, ~p"/page_views/#{page_view}/edit")
      assert html_response(conn, 200) =~ "Edit Page view"
    end
  end

  describe "update page_view" do
    setup [:create_page_view]

    test "redirects when data is valid", %{conn: conn, page_view: page_view} do
      conn = put(conn, ~p"/page_views/#{page_view}", page_view: @update_attrs)
      assert redirected_to(conn) == ~p"/page_views/#{page_view}"

      conn = get(conn, ~p"/page_views/#{page_view}")
      assert html_response(conn, 200) =~ "some updated url"
    end

    test "renders errors when data is invalid", %{conn: conn, page_view: page_view} do
      conn = put(conn, ~p"/page_views/#{page_view}", page_view: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Page view"
    end
  end

  describe "delete page_view" do
    setup [:create_page_view]

    test "deletes chosen page_view", %{conn: conn, page_view: page_view} do
      conn = delete(conn, ~p"/page_views/#{page_view}")
      assert redirected_to(conn) == ~p"/page_views"

      assert_error_sent 404, fn ->
        get(conn, ~p"/page_views/#{page_view}")
      end
    end
  end

  defp create_page_view(_) do
    page_view = page_view_fixture()
    %{page_view: page_view}
  end
end
