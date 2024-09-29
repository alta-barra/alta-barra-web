defmodule Altabarra.Stac.SearchKeyGenerator do
  def generate_key(search_params, page_number) do
    params_hash = generate_params_hash(search_params)
    "cmr_search:#{params_hash}:page_#{page_number}"
  end

  defp generate_params_hash(search_params) do
    search_params
    |> Enum.sort_by(fn {k, _} -> k end)
    |> Enum.map(fn {k, v} -> "#{k}=#{v}" end)
    |> Enum.join("&")
    |> (&:crypto.hash(:md5, &1)).()
    |> Base.encode16(case: :lower)
  end
end
