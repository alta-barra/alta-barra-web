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
    draft: [:in_review, :archived],
    in_review: [:draft, :published],
    published: [:unpublished, :archived],
    unpublished: [:draft, :archived],
    archived: [:draft]
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

    belongs_to :author, Altabarra.Accounts.User, on_replace: :nilify
    has_many :fact_checks, Altabarra.Content.FactCheck

    timestamps(type: :utc_datetime)
  end

  defp all_fields() do
    __MODULE__.__schema__(:fields)
  end

  @doc false
  def changeset(article, attrs) do
    article
    |> cast(attrs, all_fields())
    |> validate_required([
      :slug,
      :title,
      :description,
      :content,
      :type,
      :status,
      :published_at,
      :meta_title,
      :meta_description,
      :reading_time,
      :author_id
    ])
    |> validate_status_transition()
    |> foreign_key_constraint(:author_id)
  end

  def valid_transitions(status), do: [status] ++ @transitions[status]

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
