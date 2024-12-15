defmodule Altabarra.Content.Article do
  use Ecto.Schema
  import Ecto.Changeset

  @status_options ~w(
    draft
    in_review
    published
    unpublished
    archived
  )a

  @transitions %{
    draft: [:draft, :in_review, :archived],
    in_review: [:in_review, :draft, :published],
    published: [:published, :unpublished, :archived],
    unpublished: [:unpublished, :draft, :archived],
    archived: [:archived, :draft]
  }

  schema "articles" do
    field :status, Ecto.Enum, values: @status_options, default: :draft
    field :type, :string
    field :description, :string
    field :title, :string
    field :slug, :string
    field :content, :string
    field :published_at, :utc_datetime
    field :featured, :boolean, default: false
    field :meta_title, :string
    field :meta_description, :string
    field :reading_time, :integer

    belongs_to :author, Altabarra.Accounts.User, foreign_key: :author_id, on_replace: :nilify
    has_many :fact_checks, Altabarra.Content.FactCheck

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(article, attrs) do
    article
    |> cast(attrs, [
      :slug,
      :title,
      :description,
      :content,
      :type,
      :status,
      :published_at,
      :featured,
      :meta_title,
      :meta_description,
      :reading_time
    ])
    |> validate_required([
      :slug,
      :title,
      :description,
      :content,
      :type,
      :status,
      :published_at,
      :featured,
      :meta_title,
      :meta_description,
      :reading_time
    ])
    |> validate_status_transition()
  end

  def valid_transitions(status), do: @transitions[status]

  defp validate_status_transition(changeset) do
    case {get_field(changeset, :status), get_change(changeset, :status)} do
      {_, nil} ->
        changeset

      {current, new} ->
        if new in @transitions[current] do
          changeset
        else
          add_error(changeset, :status, "Invalid status transition from #{current} to #{new}")
        end
    end
  end
end
