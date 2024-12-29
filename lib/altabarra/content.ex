defmodule Altabarra.Content do
  @moduledoc """
  The Content context.
  """

  import Ecto.Query, warn: false
  alias Altabarra.Repo

  alias Altabarra.Content.Article

  @doc """
  Returns the list of articles.

  ## Examples

      iex> list_articles()
      [%Article{}, ...]

  """
  def list_articles do
    Repo.all(Article)
  end

  @doc """
  Get all posts that are in the "published" state.
  """
  def list_published_posts do
    Article
    |> where([a], a.status == :published)
    |> order_by([p], desc: p.published_at)
    |> Repo.all()
  end

  @doc """
  Gets a single article.

  Raises `Ecto.NoResultsError` if the Article does not exist.

  ## Examples

      iex> get_article!(123)
      %Article{}

      iex> get_article!(456)
      ** (Ecto.NoResultsError)

  """
  def get_article!(id), do: Repo.get!(Article, id)

  @doc """
  Gets a single article by its slug.

  Raises `Ecto.NoResultsError` if the Article does not exist.

  ## Examples
  iex> get_article_by_slug!('how-to-salt-your-corn')
  %Article{}

  iex get_article_by_slug!('how-to-increase-corn-salinity')
  ** (Ecto.NoResultsError)
  """
  def get_article_by_slug!(slug), do: Repo.get_by!(Article, slug: slug)

  @doc """
  Creates a article.

  ## Examples

      iex> create_article(%{field: value})
      {:ok, %Article{}}

      iex> create_article(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_article(attrs \\ %{}) do
    %Article{}
    |> Article.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a article.

  ## Examples

      iex> update_article(article, %{field: new_value})
      {:ok, %Article{}}

      iex> update_article(article, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_article(%Article{} = article, attrs) do
    IO.puts("updating an article")

    IO.inspect(article)
    IO.inspect(attrs)

    article
    |> Article.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a article.

  ## Examples

      iex> delete_article(article)
      {:ok, %Article{}}

      iex> delete_article(article)
      {:error, %Ecto.Changeset{}}

  """
  def delete_article(%Article{} = article) do
    Repo.delete(article)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking article changes.

  ## Examples

      iex> change_article(article)
      %Ecto.Changeset{data: %Article{}}

  """
  def change_article(%Article{} = article, attrs \\ %{}) do
    Article.changeset(article, attrs)
  end

  alias Altabarra.Content.FactCheck

  @doc """
  Returns the list of fact_checks.

  ## Examples

      iex> list_fact_checks()
      [%FactCheck{}, ...]

  """
  def list_fact_checks do
    Repo.all(FactCheck)
  end

  @doc """
  Gets a single fact_check.

  Raises `Ecto.NoResultsError` if the Fact check does not exist.

  ## Examples

      iex> get_fact_check!(123)
      %FactCheck{}

      iex> get_fact_check!(456)
      ** (Ecto.NoResultsError)

  """
  def get_fact_check!(id), do: Repo.get!(FactCheck, id)

  @doc """
  Creates a fact_check.

  ## Examples

      iex> create_fact_check(%{field: value})
      {:ok, %FactCheck{}}

      iex> create_fact_check(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_fact_check(attrs \\ %{}) do
    %FactCheck{}
    |> FactCheck.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a fact_check.

  ## Examples

      iex> update_fact_check(fact_check, %{field: new_value})
      {:ok, %FactCheck{}}

      iex> update_fact_check(fact_check, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_fact_check(%FactCheck{} = fact_check, attrs) do
    fact_check
    |> FactCheck.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a fact_check.

  ## Examples

      iex> delete_fact_check(fact_check)
      {:ok, %FactCheck{}}

      iex> delete_fact_check(fact_check)
      {:error, %Ecto.Changeset{}}

  """
  def delete_fact_check(%FactCheck{} = fact_check) do
    Repo.delete(fact_check)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking fact_check changes.

  ## Examples

      iex> change_fact_check(fact_check)
      %Ecto.Changeset{data: %FactCheck{}}

  """
  def change_fact_check(%FactCheck{} = fact_check, attrs \\ %{}) do
    FactCheck.changeset(fact_check, attrs)
  end

  alias Altabarra.Content.Tag

  @doc """
  Returns the list of tags.

  ## Examples

      iex> list_tags()
      [%Tag{}, ...]

  """
  def list_tags do
    Repo.all(Tag)
  end

  @doc """
  Gets a single tag.

  Raises `Ecto.NoResultsError` if the Tag does not exist.

  ## Examples

      iex> get_tag!(123)
      %Tag{}

      iex> get_tag!(456)
      ** (Ecto.NoResultsError)

  """
  def get_tag!(id), do: Repo.get!(Tag, id)

  @doc """
  Creates a tag.

  ## Examples

      iex> create_tag(%{field: value})
      {:ok, %Tag{}}

      iex> create_tag(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_tag(attrs \\ %{}) do
    %Tag{}
    |> Tag.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a tag.

  ## Examples

      iex> update_tag(tag, %{field: new_value})
      {:ok, %Tag{}}

      iex> update_tag(tag, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_tag(%Tag{} = tag, attrs) do
    tag
    |> Tag.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a tag.

  ## Examples

      iex> delete_tag(tag)
      {:ok, %Tag{}}

      iex> delete_tag(tag)
      {:error, %Ecto.Changeset{}}

  """
  def delete_tag(%Tag{} = tag) do
    Repo.delete(tag)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking tag changes.

  ## Examples

      iex> change_tag(tag)
      %Ecto.Changeset{data: %Tag{}}

  """
  def change_tag(%Tag{} = tag, attrs \\ %{}) do
    Tag.changeset(tag, attrs)
  end

  alias Altabarra.Content.ArticleTag

  @doc """
  Returns the list of article_tags.

  ## Examples

      iex> list_article_tags()
      [%ArticleTag{}, ...]

  """
  def list_article_tags do
    Repo.all(ArticleTag)
  end

  @doc """
  Gets a single article_tag.

  Raises `Ecto.NoResultsError` if the Article tag does not exist.

  ## Examples

      iex> get_article_tag!(123)
      %ArticleTag{}

      iex> get_article_tag!(456)
      ** (Ecto.NoResultsError)

  """
  def get_article_tag!(id), do: Repo.get!(ArticleTag, id)

  @doc """
  Creates a article_tag.

  ## Examples

      iex> create_article_tag(%{field: value})
      {:ok, %ArticleTag{}}

      iex> create_article_tag(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_article_tag(attrs \\ %{}) do
    %ArticleTag{}
    |> ArticleTag.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a article_tag.

  ## Examples

      iex> update_article_tag(article_tag, %{field: new_value})
      {:ok, %ArticleTag{}}

      iex> update_article_tag(article_tag, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_article_tag(%ArticleTag{} = article_tag, attrs) do
    article_tag
    |> ArticleTag.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a article_tag.

  ## Examples

      iex> delete_article_tag(article_tag)
      {:ok, %ArticleTag{}}

      iex> delete_article_tag(article_tag)
      {:error, %Ecto.Changeset{}}

  """
  def delete_article_tag(%ArticleTag{} = article_tag) do
    Repo.delete(article_tag)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking article_tag changes.

  ## Examples

      iex> change_article_tag(article_tag)
      %Ecto.Changeset{data: %ArticleTag{}}

  """
  def change_article_tag(%ArticleTag{} = article_tag, attrs \\ %{}) do
    ArticleTag.changeset(article_tag, attrs)
  end

  alias Altabarra.Content.Category

  @doc """
  Returns the list of categories.

  ## Examples

      iex> list_categories()
      [%Category{}, ...]

  """
  def list_categories do
    Repo.all(Category)
  end

  @doc """
  Gets a single category.

  Raises `Ecto.NoResultsError` if the Category does not exist.

  ## Examples

      iex> get_category!(123)
      %Category{}

      iex> get_category!(456)
      ** (Ecto.NoResultsError)

  """
  def get_category!(id), do: Repo.get!(Category, id)

  @doc """
  Creates a category.

  ## Examples

      iex> create_category(%{field: value})
      {:ok, %Category{}}

      iex> create_category(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_category(attrs \\ %{}) do
    %Category{}
    |> Category.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a category.

  ## Examples

      iex> update_category(category, %{field: new_value})
      {:ok, %Category{}}

      iex> update_category(category, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_category(%Category{} = category, attrs) do
    category
    |> Category.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a category.

  ## Examples

      iex> delete_category(category)
      {:ok, %Category{}}

      iex> delete_category(category)
      {:error, %Ecto.Changeset{}}

  """
  def delete_category(%Category{} = category) do
    Repo.delete(category)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking category changes.

  ## Examples

      iex> change_category(category)
      %Ecto.Changeset{data: %Category{}}

  """
  def change_category(%Category{} = category, attrs \\ %{}) do
    Category.changeset(category, attrs)
  end

  alias Altabarra.Content.ArticleCategory

  @doc """
  Returns the list of article_categories.

  ## Examples

      iex> list_article_categories()
      [%ArticleCategory{}, ...]

  """
  def list_article_categories do
    Repo.all(ArticleCategory)
  end

  @doc """
  Gets a single article_category.

  Raises `Ecto.NoResultsError` if the Article category does not exist.

  ## Examples

      iex> get_article_category!(123)
      %ArticleCategory{}

      iex> get_article_category!(456)
      ** (Ecto.NoResultsError)

  """
  def get_article_category!(id), do: Repo.get!(ArticleCategory, id)

  @doc """
  Creates a article_category.

  ## Examples

      iex> create_article_category(%{field: value})
      {:ok, %ArticleCategory{}}

      iex> create_article_category(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_article_category(attrs \\ %{}) do
    %ArticleCategory{}
    |> ArticleCategory.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a article_category.

  ## Examples

      iex> update_article_category(article_category, %{field: new_value})
      {:ok, %ArticleCategory{}}

      iex> update_article_category(article_category, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_article_category(%ArticleCategory{} = article_category, attrs) do
    article_category
    |> ArticleCategory.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a article_category.

  ## Examples

      iex> delete_article_category(article_category)
      {:ok, %ArticleCategory{}}

      iex> delete_article_category(article_category)
      {:error, %Ecto.Changeset{}}

  """
  def delete_article_category(%ArticleCategory{} = article_category) do
    Repo.delete(article_category)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking article_category changes.

  ## Examples

      iex> change_article_category(article_category)
      %Ecto.Changeset{data: %ArticleCategory{}}

  """
  def change_article_category(%ArticleCategory{} = article_category, attrs \\ %{}) do
    ArticleCategory.changeset(article_category, attrs)
  end
end
