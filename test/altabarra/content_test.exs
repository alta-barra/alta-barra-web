defmodule Altabarra.ContentTest do
  use Altabarra.DataCase

  alias Altabarra.Content

  describe "articles" do
    alias Altabarra.Content.Article

    import Altabarra.ContentFixtures

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

    test "list_articles/0 returns all articles" do
      article = article_fixture()
      assert Content.list_articles() == [article]
    end

    test "get_article!/1 returns the article with given id" do
      article = article_fixture()
      assert Content.get_article!(article.id) == article
    end

    test "create_article/1 with valid data creates a article" do
      valid_attrs = %{
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

      assert {:ok, %Article{} = article} = Content.create_article(valid_attrs)
      assert article.status == "some status"
      assert article.type == "some type"
      assert article.description == "some description"
      assert article.title == "some title"
      assert article.slug == "some slug"
      assert article.content == "some content"
      assert article.published_at == ~U[2024-11-15 14:56:00Z]
      assert article.featured == true
      assert article.meta_title == "some meta_title"
      assert article.meta_description == "some meta_description"
      assert article.reading_time == 42
    end

    test "create_article/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Content.create_article(@invalid_attrs)
    end

    test "update_article/2 with valid data updates the article" do
      article = article_fixture()

      update_attrs = %{
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

      assert {:ok, %Article{} = article} = Content.update_article(article, update_attrs)
      assert article.status == "some updated status"
      assert article.type == "some updated type"
      assert article.description == "some updated description"
      assert article.title == "some updated title"
      assert article.slug == "some updated slug"
      assert article.content == "some updated content"
      assert article.published_at == ~U[2024-11-16 14:56:00Z]
      assert article.featured == false
      assert article.meta_title == "some updated meta_title"
      assert article.meta_description == "some updated meta_description"
      assert article.reading_time == 43
    end

    test "update_article/2 with invalid data returns error changeset" do
      article = article_fixture()
      assert {:error, %Ecto.Changeset{}} = Content.update_article(article, @invalid_attrs)
      assert article == Content.get_article!(article.id)
    end

    test "delete_article/1 deletes the article" do
      article = article_fixture()
      assert {:ok, %Article{}} = Content.delete_article(article)
      assert_raise Ecto.NoResultsError, fn -> Content.get_article!(article.id) end
    end

    test "change_article/1 returns a article changeset" do
      article = article_fixture()
      assert %Ecto.Changeset{} = Content.change_article(article)
    end
  end

  describe "fact_checks" do
    alias Altabarra.Content.FactCheck

    import Altabarra.ContentFixtures

    @invalid_attrs %{status: nil, source: nil, notes: nil, verified_at: nil}

    test "list_fact_checks/0 returns all fact_checks" do
      fact_check = fact_check_fixture()
      assert Content.list_fact_checks() == [fact_check]
    end

    test "get_fact_check!/1 returns the fact_check with given id" do
      fact_check = fact_check_fixture()
      assert Content.get_fact_check!(fact_check.id) == fact_check
    end

    test "create_fact_check/1 with valid data creates a fact_check" do
      valid_attrs = %{
        status: "some status",
        source: "some source",
        notes: "some notes",
        verified_at: ~U[2024-11-15 14:58:00Z]
      }

      assert {:ok, %FactCheck{} = fact_check} = Content.create_fact_check(valid_attrs)
      assert fact_check.status == "some status"
      assert fact_check.source == "some source"
      assert fact_check.notes == "some notes"
      assert fact_check.verified_at == ~U[2024-11-15 14:58:00Z]
    end

    test "create_fact_check/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Content.create_fact_check(@invalid_attrs)
    end

    test "update_fact_check/2 with valid data updates the fact_check" do
      fact_check = fact_check_fixture()

      update_attrs = %{
        status: "some updated status",
        source: "some updated source",
        notes: "some updated notes",
        verified_at: ~U[2024-11-16 14:58:00Z]
      }

      assert {:ok, %FactCheck{} = fact_check} =
               Content.update_fact_check(fact_check, update_attrs)

      assert fact_check.status == "some updated status"
      assert fact_check.source == "some updated source"
      assert fact_check.notes == "some updated notes"
      assert fact_check.verified_at == ~U[2024-11-16 14:58:00Z]
    end

    test "update_fact_check/2 with invalid data returns error changeset" do
      fact_check = fact_check_fixture()
      assert {:error, %Ecto.Changeset{}} = Content.update_fact_check(fact_check, @invalid_attrs)
      assert fact_check == Content.get_fact_check!(fact_check.id)
    end

    test "delete_fact_check/1 deletes the fact_check" do
      fact_check = fact_check_fixture()
      assert {:ok, %FactCheck{}} = Content.delete_fact_check(fact_check)
      assert_raise Ecto.NoResultsError, fn -> Content.get_fact_check!(fact_check.id) end
    end

    test "change_fact_check/1 returns a fact_check changeset" do
      fact_check = fact_check_fixture()
      assert %Ecto.Changeset{} = Content.change_fact_check(fact_check)
    end
  end

  describe "tags" do
    alias Altabarra.Content.Tag

    import Altabarra.ContentFixtures

    @invalid_attrs %{name: nil, description: nil, slug: nil}

    test "list_tags/0 returns all tags" do
      tag = tag_fixture()
      assert Content.list_tags() == [tag]
    end

    test "get_tag!/1 returns the tag with given id" do
      tag = tag_fixture()
      assert Content.get_tag!(tag.id) == tag
    end

    test "create_tag/1 with valid data creates a tag" do
      valid_attrs = %{name: "some name", description: "some description", slug: "some slug"}

      assert {:ok, %Tag{} = tag} = Content.create_tag(valid_attrs)
      assert tag.name == "some name"
      assert tag.description == "some description"
      assert tag.slug == "some slug"
    end

    test "create_tag/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Content.create_tag(@invalid_attrs)
    end

    test "update_tag/2 with valid data updates the tag" do
      tag = tag_fixture()

      update_attrs = %{
        name: "some updated name",
        description: "some updated description",
        slug: "some updated slug"
      }

      assert {:ok, %Tag{} = tag} = Content.update_tag(tag, update_attrs)
      assert tag.name == "some updated name"
      assert tag.description == "some updated description"
      assert tag.slug == "some updated slug"
    end

    test "update_tag/2 with invalid data returns error changeset" do
      tag = tag_fixture()
      assert {:error, %Ecto.Changeset{}} = Content.update_tag(tag, @invalid_attrs)
      assert tag == Content.get_tag!(tag.id)
    end

    test "delete_tag/1 deletes the tag" do
      tag = tag_fixture()
      assert {:ok, %Tag{}} = Content.delete_tag(tag)
      assert_raise Ecto.NoResultsError, fn -> Content.get_tag!(tag.id) end
    end

    test "change_tag/1 returns a tag changeset" do
      tag = tag_fixture()
      assert %Ecto.Changeset{} = Content.change_tag(tag)
    end
  end

  describe "article_tags" do
    alias Altabarra.Content.ArticleTag

    import Altabarra.ContentFixtures

    @invalid_attrs %{}

    test "list_article_tags/0 returns all article_tags" do
      article_tag = article_tag_fixture()
      assert Content.list_article_tags() == [article_tag]
    end

    test "get_article_tag!/1 returns the article_tag with given id" do
      article_tag = article_tag_fixture()
      assert Content.get_article_tag!(article_tag.id) == article_tag
    end

    test "create_article_tag/1 with valid data creates a article_tag" do
      valid_attrs = %{}

      assert {:ok, %ArticleTag{} = article_tag} = Content.create_article_tag(valid_attrs)
    end

    test "create_article_tag/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Content.create_article_tag(@invalid_attrs)
    end

    test "update_article_tag/2 with valid data updates the article_tag" do
      article_tag = article_tag_fixture()
      update_attrs = %{}

      assert {:ok, %ArticleTag{} = article_tag} =
               Content.update_article_tag(article_tag, update_attrs)
    end

    test "update_article_tag/2 with invalid data returns error changeset" do
      article_tag = article_tag_fixture()
      assert {:error, %Ecto.Changeset{}} = Content.update_article_tag(article_tag, @invalid_attrs)
      assert article_tag == Content.get_article_tag!(article_tag.id)
    end

    test "delete_article_tag/1 deletes the article_tag" do
      article_tag = article_tag_fixture()
      assert {:ok, %ArticleTag{}} = Content.delete_article_tag(article_tag)
      assert_raise Ecto.NoResultsError, fn -> Content.get_article_tag!(article_tag.id) end
    end

    test "change_article_tag/1 returns a article_tag changeset" do
      article_tag = article_tag_fixture()
      assert %Ecto.Changeset{} = Content.change_article_tag(article_tag)
    end
  end

  describe "categories" do
    alias Altabarra.Content.Category

    import Altabarra.ContentFixtures

    @invalid_attrs %{name: nil, description: nil, slug: nil}

    test "list_categories/0 returns all categories" do
      category = category_fixture()
      assert Content.list_categories() == [category]
    end

    test "get_category!/1 returns the category with given id" do
      category = category_fixture()
      assert Content.get_category!(category.id) == category
    end

    test "create_category/1 with valid data creates a category" do
      valid_attrs = %{name: "some name", description: "some description", slug: "some slug"}

      assert {:ok, %Category{} = category} = Content.create_category(valid_attrs)
      assert category.name == "some name"
      assert category.description == "some description"
      assert category.slug == "some slug"
    end

    test "create_category/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Content.create_category(@invalid_attrs)
    end

    test "update_category/2 with valid data updates the category" do
      category = category_fixture()

      update_attrs = %{
        name: "some updated name",
        description: "some updated description",
        slug: "some updated slug"
      }

      assert {:ok, %Category{} = category} = Content.update_category(category, update_attrs)
      assert category.name == "some updated name"
      assert category.description == "some updated description"
      assert category.slug == "some updated slug"
    end

    test "update_category/2 with invalid data returns error changeset" do
      category = category_fixture()
      assert {:error, %Ecto.Changeset{}} = Content.update_category(category, @invalid_attrs)
      assert category == Content.get_category!(category.id)
    end

    test "delete_category/1 deletes the category" do
      category = category_fixture()
      assert {:ok, %Category{}} = Content.delete_category(category)
      assert_raise Ecto.NoResultsError, fn -> Content.get_category!(category.id) end
    end

    test "change_category/1 returns a category changeset" do
      category = category_fixture()
      assert %Ecto.Changeset{} = Content.change_category(category)
    end
  end

  describe "article_categories" do
    alias Altabarra.Content.ArticleCategory

    import Altabarra.ContentFixtures

    @invalid_attrs %{}

    test "list_article_categories/0 returns all article_categories" do
      article_category = article_category_fixture()
      assert Content.list_article_categories() == [article_category]
    end

    test "get_article_category!/1 returns the article_category with given id" do
      article_category = article_category_fixture()
      assert Content.get_article_category!(article_category.id) == article_category
    end

    test "create_article_category/1 with valid data creates a article_category" do
      valid_attrs = %{}

      assert {:ok, %ArticleCategory{} = article_category} =
               Content.create_article_category(valid_attrs)
    end

    test "create_article_category/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Content.create_article_category(@invalid_attrs)
    end

    test "update_article_category/2 with valid data updates the article_category" do
      article_category = article_category_fixture()
      update_attrs = %{}

      assert {:ok, %ArticleCategory{} = article_category} =
               Content.update_article_category(article_category, update_attrs)
    end

    test "update_article_category/2 with invalid data returns error changeset" do
      article_category = article_category_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Content.update_article_category(article_category, @invalid_attrs)

      assert article_category == Content.get_article_category!(article_category.id)
    end

    test "delete_article_category/1 deletes the article_category" do
      article_category = article_category_fixture()
      assert {:ok, %ArticleCategory{}} = Content.delete_article_category(article_category)

      assert_raise Ecto.NoResultsError, fn ->
        Content.get_article_category!(article_category.id)
      end
    end

    test "change_article_category/1 returns a article_category changeset" do
      article_category = article_category_fixture()
      assert %Ecto.Changeset{} = Content.change_article_category(article_category)
    end
  end
end
