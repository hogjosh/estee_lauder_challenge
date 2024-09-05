defmodule ChallengeWeb.PermitController do
  use ChallengeWeb, :controller

  alias Challenge.Permits

  @doc """
  Renders a page of permits in accordance with the query params
  """
  @spec index(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def index(conn, params) do
    page =
      params
      |> build_page_opts()
      |> Permits.page_permits()

    render(conn, :index, %{page: page})
  end

  # Turn the query params into a set of options
  # supported by the Permits context module.
  defp build_page_opts(params) do
    [
      search: params["q"],
      status: params["status"],
      page: params["page"],
      page_size: params["page_size"]
    ]
    |> Keyword.update!(:page, &parse_int/1)
    |> Keyword.update!(:page_size, &parse_int/1)
    |> Keyword.reject(fn {_k, v} -> v == nil end)
  end

  defp parse_int(s) do
    case Integer.parse("#{s}") do
      {n, ""} -> n
      _ -> nil
    end
  end
end
