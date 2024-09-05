defmodule Challenge.Permits do
  @moduledoc """
  Context module used to perform actions with permits.
  """

  import Ecto.Query, only: [from: 2]

  alias Challenge.Repo
  alias Challenge.Permits.Permit

  @type page_opt ::
          {:page, integer()}
          | {:page_size, integer()}
          | {:search, String.t()}
          | {:status, String.t()}
  @type page_opts :: [page_opt()]

  @doc """
  Upserts a permit based on the attributes provided.
  If the location_id already exists, the record will be updated.
  """
  @spec upsert_permit(map()) :: {:ok, Permit.t()} | {:error, Ecto.Changeset.t(Permit.t())}
  def upsert_permit(attrs) do
    %Permit{}
    |> Permit.changeset(attrs)
    |> Repo.insert(
      # location_id is a potential conflict.
      conflict_target: [:location_id],

      # When we encounter a conflict update most fields. 
      on_conflict: {:replace_all_except, [:id, :inserted_at]},

      # We need to ensure we read back all of the fields, particularly 
      # on conflicts. For example, the Permit returned on conflict will 
      # have the id that we _attempted_ to insert, instead of the one 
      # in the database.
      # [Further reading](https://hexdocs.pm/ecto/Ecto.Repo.html#c:insert/2-upserts)
      returning: true
    )
  end

  @doc """
  Returns a page of users based on the options provided.

  ## Options
  * `:page` - the page number to load, defaults to 1
  * `:page_size` - the number of entries per page, defaults to 20
  * `:search` - search term to query for
  * `:status` - status to filter the results by
  """
  @spec page_permits(page_opts()) :: Scrivener.Page.t(Permit.t())
  def page_permits(opts \\ []) do
    pagination = Keyword.take(opts, [:page, :page_size])

    # In order to stabilize the permit order we'll first
    # sort by the permit holder and then the permit id.
    query =
      from p in Permit,
        as: :permit,
        order_by: [asc: p.permit_holder, asc: p.id]

    query
    |> apply_filters(opts)
    |> Repo.paginate(pagination)
  end

  # Apply the filters to the query
  defp apply_filters(query, filters) do
    Enum.reduce(filters, query, &filter_query/2)
  end

  # Filter by the value of :search. It can be contained in
  # any of location_description, permit_number, permit_holder,
  # or food_items and is a case insensitive comparison.
  defp filter_query({:search, v}, query) do
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
