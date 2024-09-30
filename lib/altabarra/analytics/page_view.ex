defmodule Altabarra.Analytics.PageView do
  use Ecto.Schema
  import Ecto.Changeset

  schema "page_views" do
    field :timestamp, :naive_datetime
    field :url, :string
    field :user_agent, :string
    field :ip_address, :string
    field :referer, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(page_view, attrs) do
    page_view
    |> cast(attrs, [:url, :user_agent, :ip_address, :referer, :timestamp])
    |> validate_required([:url, :ip_address, :timestamp])
  end
end
