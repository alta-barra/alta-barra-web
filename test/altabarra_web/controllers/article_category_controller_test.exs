defmodule AltabarraWeb.ArticleCategoryControllerTest do
  use AltabarraWeb.ConnCase

  import Altabarra.ContentFixtures

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  describe "index" do
    test "lists all article_categories", %{conn: conn} do
      conn = get(conn, ~p"/article_categories")
      assert html_response(conn, 200) =~ "Listing Article categories"
    end
  end

  describe "new article_category" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/article_categories/new")
      assert html_response(conn, 200) =~ "New Article category"
    end
  end

  describe "create article_category" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/article_categories", article_category: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/article_categories/#{id}"

      conn = get(conn, ~p"/article_categories/#{id}")
      assert html_response(conn, 200) =~ "Article category #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/article_categories", article_category: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Article category"
    end
  end

  describe "edit article_category" do
    setup [:create_article_category]

    test "renders form for editing chosen article_category", %{conn: conn, article_category: article_category} do
      conn = get(conn, ~p"/article_categories/#{article_category}/edit")
      assert html_response(conn, 200) =~ "Edit Article category"
    end
  end

  describe "update article_category" do
    setup [:create_article_category]

    test "redirects when data is valid", %{conn: conn, article_category: article_category} do
      conn = put(conn, ~p"/article_categories/#{article_category}", article_category: @update_attrs)
      assert redirected_to(conn) == ~p"/article_categories/#{article_category}"

      conn = get(conn, ~p"/article_categories/#{article_category}")
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, article_category: article_category} do
      conn = put(conn, ~p"/article_categories/#{article_category}", article_category: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Article category"
    end
  end

  describe "delete article_category" do
    setup [:create_article_category]

    test "deletes chosen article_category", %{conn: conn, article_category: article_category} do
      conn = delete(conn, ~p"/article_categories/#{article_category}")
      assert redirected_to(conn) == ~p"/article_categories"

      assert_error_sent 404, fn ->
        get(conn, ~p"/article_categories/#{article_category}")
      end
    end
  end

  defp create_article_category(_) do
    article_category = article_category_fixture()
    %{article_category: article_category}
  end
end
