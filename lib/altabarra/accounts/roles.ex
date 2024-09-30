defmodule Altabarra.Accounts.Roles do
  def has_role?(nil, _role), do: false
  def has_role?(user, role) when is_binary(role), do: has_role?(user, [role])
  def has_role?(user, roles) when is_list(roles), do: user.role in roles

  def is_admin?(user), do: has_role?(user, "admin")
  def is_user?(user), do: has_role?(user, ["admin", "user"])
end
