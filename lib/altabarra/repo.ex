defmodule Altabarra.Repo do
  use Ecto.Repo,
    otp_app: :altabarra,
    adapter: Ecto.Adapters.Postgres
end
