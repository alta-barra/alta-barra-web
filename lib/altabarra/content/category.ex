defmodule Altabarra.Content.Category do
  @moduledoc """
  Represents a category in the content management system.

  ## Fields
  - `name`: The name of the category
  - `description`: A description of the category
  - `parent`: A self-referential association to a parent category
  - `children`: A self-referential association to child categories

  ## Associations
  - `belongs_to :parent`: Establishes a relationship with a parent category
  - `has_many :children`: Establishes a relationship with child categories
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "categories" do
    field :name, :string
    field :description, :string
    belongs_to :parent, __MODULE__
    has_many :children, __MODULE__, foreign_key: :parent_id

    timestamps(type: :utc_datetime)
  end

  @doc """
  Generates a changeset for creating or updating a category.
  """
  def changeset(%__MODULE__{} = category, attrs) do
    category
    |> cast(attrs, [:name, :description, :parent_id])
    |> validate_required([:name])
    |> assoc_constraint(:parent)
  end
end
