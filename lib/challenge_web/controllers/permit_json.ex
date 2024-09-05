defmodule ChallengeWeb.PermitJSON do
  @moduledoc """
  This module is used to render permit data as json
  """

  @type t() :: %{
          id: String.t(),
          location_id: integer(),
          location_description: String.t(),
          permit_number: String.t(),
          permit_holder: String.t(),
          food_items: String.t(),
          hours_of_operation: String.t(),
          status: String.t()
        }

  @type page(entry) :: %{
          entries: list(entry),
          page_number: non_neg_integer(),
          page_size: non_neg_integer(),
          total_pages: non_neg_integer(),
          total_entries: non_neg_integer()
        }

  @doc """
  Renders a page of permits
  """
  @spec index(%{page: Scrivener.Page.t()}) :: %{data: page(t)}
  def index(%{page: page}) do
    %{data: page(page)}
  end

  defp page(page) do
    %{
      entries: for(permit <- page.entries, do: permit(permit)),
      page_number: page.page_number,
      page_size: page.page_size,
      total_pages: page.total_pages,
      total_entries: page.total_entries
    }
  end

  defp permit(permit) do
    Map.take(permit, [
      :id,
      :location_id,
      :location_description,
      :permit_number,
      :permit_holder,
      :food_items,
      :hours_of_operation,
      :status
    ])
  end
end
