defmodule AltabarraWeb.ArticleControllerTest do
  use AltabarraWeb.ConnCase

  import Altabarra.ContentFixtures

  @create_attrs %{
    status: "some status",
    type: "some type",
    description: "some description",
    title: "some title",
    slug: "some slug",
    content: "some content",
    published_at: ~U[2024-11-15 14:56:00Z],
    featured: true,
    meta_title: "some meta_title",
    meta_description: "some meta_description",
    reading_time: 42
  }
  @update_attrs %{
    status: "some updated status",
    type: "some updated type",
    description: "some updated description",
    title: "some updated title",
    slug: "some updated slug",
    content: "some updated content",
    published_at: ~U[2024-11-16 14:56:00Z],
    featured: false,
    meta_title: "some updated meta_title",
    meta_description: "some updated meta_description",
    reading_time: 43
  }
  @invalid_attrs %{
    status: nil,
    type: nil,
    description: nil,
    title: nil,
    slug: nil,
    content: nil,
    published_at: nil,
    featured: nil,
    meta_title: nil,
    meta_description: nil,
    reading_time: nil
  }

  describe "index" do
    test "lists all articles", %{conn: conn} do
      conn = get(conn, ~p"/articles")
      assert html_response(conn, 200) =~ "Listing Articles"
    end
  end

  describe "new article" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/articles/new")
      assert html_response(conn, 200) =~ "New Article"
    end
  end

  describe "create article" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/articles", article: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/articles/#{id}"

      conn = get(conn, ~p"/articles/#{id}")
      assert html_response(conn, 200) =~ "Article #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/articles", article: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Article"
    end
  end

  describe "edit article" do
    setup [:create_article]

    test "renders form for editing chosen article", %{conn: conn, article: article} do
      conn = get(conn, ~p"/articles/#{article}/edit")
      assert html_response(conn, 200) =~ "Edit Article"
    end
  end

  describe "update article" do
    setup [:create_article]

    test "redirects when data is valid", %{conn: conn, article: article} do
      conn = put(conn, ~p"/articles/#{article}", article: @update_attrs)
      assert redirected_to(conn) == ~p"/articles/#{article}"

      conn = get(conn, ~p"/articles/#{article}")
      assert html_response(conn, 200) =~ "some updated status"
    end

    test "renders errors when data is invalid", %{conn: conn, article: article} do
      conn = put(conn, ~p"/articles/#{article}", article: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Article"
    end
  end

  describe "delete article" do
    setup [:create_article]

    test "deletes chosen article", %{conn: conn, article: article} do
      conn = delete(conn, ~p"/articles/#{article}")
      assert redirected_to(conn) == ~p"/articles"

      assert_error_sent 404, fn ->
        get(conn, ~p"/articles/#{article}")
      end
    end
  end

  defp create_article(_) do
    article = article_fixture()
    %{article: article}
  end
end
