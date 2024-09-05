defmodule ChallengeWeb.PermitJSONTest do
  use ExUnit.Case, async: true

  alias ChallengeWeb.PermitJSON

  test "index/1 renders a page of permits under a data key" do
    permits =
      for n <- 1..3 do
        permit(%{location_id: n})
      end

    page = %Scrivener.Page{
      entries: permits,
      page_number: 1,
      page_size: 50,
      total_pages: 1,
      total_entries: length(permits)
    }

    assert %{
             data: %{
               entries: [entry | _] = entries,
               page_number: 1,
               page_size: 50,
               total_pages: 1,
               total_entries: 3
             }
           } = PermitJSON.index(%{page: page})

    assert length(entries) == 3

    assert %{
             id: _,
             location_id: 1,
             location_description: "1ST ST => LYMAN AVE to TAPESTRY RDG",
             permit_number: "23MFF-00030",
             permit_holder: "Bill's Snacks",
             food_items: "American Food: Hot dogs: pretzels: beverages",
             hours_of_operation: "Mo-Fr:12PM-8PM",
             status: :approved
           } = entry
  end

  defp permit(attrs) do
    %Challenge.Permits.Permit{
      location_id: 1234,
      location_description: "1ST ST => LYMAN AVE to TAPESTRY RDG",
      permit_number: "23MFF-00030",
      permit_holder: "Bill's Snacks",
      food_items: "American Food: Hot dogs: pretzels: beverages",
      hours_of_operation: "Mo-Fr:12PM-8PM",
      status: :approved
    }
    |> Map.merge(attrs)
  end
end
