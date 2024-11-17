defmodule AltabarraWeb.ArticleTagControllerTest do
  use AltabarraWeb.ConnCase

  import Altabarra.ContentFixtures

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  describe "index" do
    test "lists all article_tags", %{conn: conn} do
      conn = get(conn, ~p"/article_tags")
      assert html_response(conn, 200) =~ "Listing Article tags"
    end
  end

  describe "new article_tag" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/article_tags/new")
      assert html_response(conn, 200) =~ "New Article tag"
    end
  end

  describe "create article_tag" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/article_tags", article_tag: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/article_tags/#{id}"

      conn = get(conn, ~p"/article_tags/#{id}")
      assert html_response(conn, 200) =~ "Article tag #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/article_tags", article_tag: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Article tag"
    end
  end

  describe "edit article_tag" do
    setup [:create_article_tag]

    test "renders form for editing chosen article_tag", %{conn: conn, article_tag: article_tag} do
      conn = get(conn, ~p"/article_tags/#{article_tag}/edit")
      assert html_response(conn, 200) =~ "Edit Article tag"
    end
  end

  describe "update article_tag" do
    setup [:create_article_tag]

    test "redirects when data is valid", %{conn: conn, article_tag: article_tag} do
      conn = put(conn, ~p"/article_tags/#{article_tag}", article_tag: @update_attrs)
      assert redirected_to(conn) == ~p"/article_tags/#{article_tag}"

      conn = get(conn, ~p"/article_tags/#{article_tag}")
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, article_tag: article_tag} do
      conn = put(conn, ~p"/article_tags/#{article_tag}", article_tag: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Article tag"
    end
  end

  describe "delete article_tag" do
    setup [:create_article_tag]

    test "deletes chosen article_tag", %{conn: conn, article_tag: article_tag} do
      conn = delete(conn, ~p"/article_tags/#{article_tag}")
      assert redirected_to(conn) == ~p"/article_tags"

      assert_error_sent 404, fn ->
        get(conn, ~p"/article_tags/#{article_tag}")
      end
    end
  end

  defp create_article_tag(_) do
    article_tag = article_tag_fixture()
    %{article_tag: article_tag}
  end
end
