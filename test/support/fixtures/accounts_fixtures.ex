defmodule Altabarra.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Altabarra.Accounts` context.
  """

  def unique_user_email, do: "user#{System.unique_integer()}@alta-barra.com"
  def valid_user_password, do: "altabarra_awesome_password!"

  def valid_user_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: unique_user_email(),
      password: valid_user_password()
    })
  end

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> valid_user_attributes()
      |> Altabarra.Accounts.register_user()

    user
  end

  def admin_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> valid_user_attributes()
      |> Altabarra.Accounts.register_user()

    user
    |> Altabarra.Accounts.User.role_changeset(%{role: "admin"})
    |> Altabarra.Repo.update!()
  end

  def extract_user_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end
end
