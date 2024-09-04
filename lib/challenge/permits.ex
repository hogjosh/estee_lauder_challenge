defmodule Challenge.Permits do
  @moduledoc """
  Context module used to perform actions with permits.
  """

  import Ecto.Query, only: [from: 2]

  alias Challenge.Repo
  alias Challenge.Permits.Permit

  @doc """
  Creates a permit based on the attributes provided.
  """
  @spec create_permit(map()) :: {:ok, Permit.t()} | {:error, Ecto.Changeset.t(Permit.t())}
  def create_permit(attrs) do
    %Permit{}
    |> Permit.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Lists permits based on the parameters provided.
  """
  @spec list_permits(map()) :: list(Permit.t())
  def list_permits(params \\ %{}) do
    query =
      from p in Permit,
        as: :permit,
        order_by: [asc: p.permit_holder]

    query
    |> build_query(params)
    |> Repo.all()
  end

  defp build_query(query, params) do
    Enum.reduce(params, query, &param_query/2)
  end

  defp param_query({"status", v}, query) do
    v = String.downcase(v)

    from [permit: permit] in query,
      where: permit.status == ^v
  end

  defp param_query(_kv, query), do: query
end
