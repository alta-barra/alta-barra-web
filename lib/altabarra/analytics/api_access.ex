defmodule Altabarra.Analytics.ApiAccess do
  @moduledoc """
  Defines the schema for an API access event.

  This is equivalent to a page_view for the browser based access, but is tailored for API interactions.
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "api_accesses" do
    field :endpoint, :string
    field :method, :string
    field :status_code, :integer
    field :user_agent, :string
    field :ip_address, :string
    field :request_body, :string
    field :response_body, :string
    field :timestamp, :naive_datetime
    field :duration, :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(api_access, attrs) do
    api_access
    |> cast(attrs, [
      :endpoint,
      :method,
      :status_code,
      :user_agent,
      :ip_address,
      :request_body,
      :response_body,
      :timestamp,
      :duration
    ])
    |> validate_required([:endpoint, :method, :timestamp])
  end
end
