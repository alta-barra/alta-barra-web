defmodule Altabarra.Content.FactCheck do
  use Ecto.Schema
  import Ecto.Changeset

  schema "fact_checks" do
    field :status, :string
    field :source, :string
    field :notes, :string
    field :verified_at, :utc_datetime
    field :checker_id, :id
    field :article_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(fact_check, attrs) do
    fact_check
    |> cast(attrs, [:source, :status, :notes, :verified_at])
    |> validate_required([:source, :status, :notes, :verified_at])
  end
end
