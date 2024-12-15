defmodule Altabarra.ContentFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Altabarra.Content` context.
  """

  @doc """
  Generate a article.
  """
  def article_fixture(attrs \\ %{}) do
    {:ok, article} =
      attrs
      |> Enum.into(%{
        content: "some content",
        description: "some description",
        featured: true,
        meta_description: "some meta_description",
        meta_title: "some meta_title",
        published_at: ~U[2024-11-15 14:56:00Z],
        reading_time: 42,
        slug: "some slug",
        status: "some status",
        title: "some title",
        type: "some type"
      })
      |> Altabarra.Content.create_article()

    article
  end

  @doc """
  Generate a fact_check.
  """
  def fact_check_fixture(attrs \\ %{}) do
    {:ok, fact_check} =
      attrs
      |> Enum.into(%{
        notes: "some notes",
        source: "some source",
        status: "some status",
        verified_at: ~U[2024-11-15 14:58:00Z]
      })
      |> Altabarra.Content.create_fact_check()

    fact_check
  end

  @doc """
  Generate a tag.
  """
  def tag_fixture(attrs \\ %{}) do
    {:ok, tag} =
      attrs
      |> Enum.into(%{
        description: "some description",
        name: "some name",
        slug: "some slug"
      })
      |> Altabarra.Content.create_tag()

    tag
  end

  @doc """
  Generate a article_tag.
  """
  def article_tag_fixture(attrs \\ %{}) do
    {:ok, article_tag} =
      attrs
      |> Enum.into(%{})
      |> Altabarra.Content.create_article_tag()

    article_tag
  end

  @doc """
  Generate a category.
  """
  def category_fixture(attrs \\ %{}) do
    {:ok, category} =
      attrs
      |> Enum.into(%{
        description: "some description",
        name: "some name",
        slug: "some slug"
      })
      |> Altabarra.Content.create_category()

    category
  end

  @doc """
  Generate a article_category.
  """
  def article_category_fixture(attrs \\ %{}) do
    {:ok, article_category} =
      attrs
      |> Enum.into(%{})
      |> Altabarra.Content.create_article_category()

    article_category
  end
end
