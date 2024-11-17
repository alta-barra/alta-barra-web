defmodule Altabarra.Content.Article do
  use Ecto.Schema
  import Ecto.Changeset

  @status_options ~w(
    draft
    in_review
    scheduled
    published
    unpublished
    archived
  )a

  @transitions %{
    draft: [:in_review, :archived],
    in_review: [:draft, :scheduled, :published],
    scheduled: [:draft, :published, :unpublished],
    published: [:unpublished, :archived],
    unpublished: [:draft, :scheduled, :archived],
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

    belongs_to :author, Altabarra.Accounts.User, foreign_key: :author_id, on_replace: :nilify
    has_many :fact_checks, Altabarra.Content.FactCheck

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(article, attrs) do
    article
    |> cast(attrs, [:slug, :title, :description, :content, :type, :status, :published_at, :featured, :meta_title, :meta_description, :reading_time])
    |> validate_required([:slug, :title, :description, :content, :type, :status, :published_at, :featured, :meta_title, :meta_description, :reading_time])
    |> validate_status_transition()
    |> validate_scheduled_publishing()
  end

  def valid_transitions(status), do: @transitions[status]

  defp validate_status_transition(changeset) do
    case {get_field(changeset, :status), get_change(changeset, :status)} do
      {_, nil} -> changeset  # No status change
      {current, new} -> 
        if new in @transitions[current] do
          changeset
        else
          add_error(changeset, :status, "Invalid status transition from #{current} to #{new}")
        end
    end
  end

  defp validate_scheduled_publishing(changeset) do
    case get_change(changeset, :status) do
      :scheduled ->
        changeset
        |> validate_required([:scheduled_for])
        |> validate_scheduled_time()
      _ ->
        changeset
    end
  end

  defp validate_scheduled_time(changeset) do
    case get_field(changeset, :scheduled_for) do
      nil -> changeset
      scheduled_time ->
        if DateTime.compare(scheduled_time, DateTime.utc_now()) == :gt do
          changeset
        else
          add_error(changeset, :scheduled_for, "Scheduled time must be in the future")
        end
    end
  end
end
