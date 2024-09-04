defmodule Challenge.Permits do
  @moduledoc """
  Context module used to perform actions with permits.
  """

  import Ecto.Query, only: [from: 2]

  alias Challenge.Repo
  alias Challenge.Permits.Permit

  @type filter :: {:q, String.t()} | {:status, String.t()}
  @type filters :: [filter()]

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
  Lists permits based on the filters provided.
  """
  @spec list_permits(filters) :: list(Permit.t())
  def list_permits(filters \\ []) do
    # In order to stabilize the permit order we'll first
    # sort by the permit holder and then the permit id.
    query =
      from p in Permit,
        as: :permit,
        order_by: [asc: p.permit_holder, asc: p.id]

    query
    |> apply_filters(filters)
    |> Repo.all()
  end

  defp apply_filters(query, filter) do
    Enum.reduce(filter, query, &filter_query/2)
  end

  # Filter by the value of :q. It can be contained in
  # any of location_description, permit_number, permit_holder,
  # or food_items and is a case insensitive comparison.
  defp filter_query({:q, v}, query) do
    contains_v = "%#{v}%"

    from [permit: permit] in query,
      where: ilike(permit.location_description, ^contains_v),
      or_where: ilike(permit.permit_number, ^contains_v),
      or_where: ilike(permit.permit_holder, ^contains_v),
      or_where: ilike(permit.food_items, ^contains_v)
  end

  # Filter by a case insensitive status.
  defp filter_query({:status, v}, query) do
    v = String.downcase(v)

    from [permit: permit] in query,
      where: permit.status == ^v
  end

  # If there are other keys in the filter, ignore them.
  defp filter_query(_kv, query), do: query
end
