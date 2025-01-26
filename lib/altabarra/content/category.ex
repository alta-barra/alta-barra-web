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
  alias Altabarra.Repo
  import Ecto.Changeset

  schema "categories" do
    field :name, :string
    field :description, :string
    belongs_to :parent, __MODULE__
    has_many :children, __MODULE__, foreign_key: :parent_id, on_delete: :nilify_all

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
    |> validate_no_circular_reference()
  end

  defp validate_no_circular_reference(changeset) do
    case get_change(changeset, :parent_id) do
      nil -> changeset
      parent_id -> validate_circular_path(changeset, changeset.data.id, parent_id)
    end
  end

  defp validate_circular_path(changeset, current_id, parent_id) when current_id == parent_id do
    add_error(changeset, :parent_id, "cannot create circular reference")
  end

  defp validate_circular_path(changeset, current_id, parent_id) do
    # Recursive check to prevent multi-level circular references
    parents = find_parent_chain(current_id, parent_id)

    if Enum.member?(parents, current_id) do
      add_error(changeset, :parent_id, "cannot create circular reference")
    else
      changeset
    end
  end

  defp find_parent_chain(current_id, parent_id, visited \\ []) do
    case Repo.get!(__MODULE__, parent_id) do
      nil ->
        visited

      parent ->
        new_visited = [parent.id | visited]

        case parent.parent_id do
          nil -> new_visited
          next_parent_id -> find_parent_chain(current_id, next_parent_id, new_visited)
        end
    end
  end
end
