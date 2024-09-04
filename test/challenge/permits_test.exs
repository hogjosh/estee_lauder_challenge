defmodule Challenge.PermitsTest do
  use Challenge.DataCase, async: true

  alias Challenge.Permits
  alias Challenge.Permits.Permit

  describe "create_permit/1" do
    test "valid attrs create a permit" do
      attrs = %{
        location_id: "1234",
        location_description: "1ST ST: LYMAN AVE to TAPESTRY RDG",
        permit_number: "23MFF-00030",
        permit_holder: "Bill's Snacks",
        food_items: "American Food: Hot dogs: pretzels: beverages",
        hours_of_operation: "Mo-Fr:12PM-8PM",
        status: "approved"
      }

      assert {:ok, %Permit{}} = Permits.create_permit(attrs)
    end

    test "invalid attrs will not create a permit" do
      assert {:error, %Ecto.Changeset{}} = Permits.create_permit(%{})
    end
  end

  describe "list_permits/1" do
    test "filter by status with case insensitivity" do
      %{id: inserted_id} =
        %{"status" => "approved"}
        |> permit()
        |> insert!()

      filters = [status: "APPROVED"]

      assert [%Permit{id: ^inserted_id}] = Permits.list_permits(filters)

      filters = [status: "expired"]

      assert [] = Permits.list_permits(filters)
    end

    test "filter by 'contains q', match location_description, case insensitive" do
      %{id: inserted_id} =
        %{"location_description" => "TAPESTRY RDG"}
        |> permit()
        |> insert!()

      filters = [q: "tapestry"]

      assert [%Permit{id: ^inserted_id}] = Permits.list_permits(filters)
    end

    test "filter by 'contains q', match permit_number, case insensitive" do
      %{id: inserted_id} =
        %{"permit_number" => "23MFF-00030"}
        |> permit()
        |> insert!()

      filters = [q: "mff-00"]

      assert [%Permit{id: ^inserted_id}] = Permits.list_permits(filters)
    end

    test "filter by 'contains q', match permit_holder, case insensitive" do
      %{id: inserted_id} =
        %{"permit_holder" => "Bill's Snacks"}
        |> permit()
        |> insert!()

      filters = [q: "bill's"]

      assert [%Permit{id: ^inserted_id}] = Permits.list_permits(filters)
    end

    test "filter by 'contains q', match food_items, case insensitive" do
      %{id: inserted_id} =
        %{"food_items" => "American Food: Hot dogs: Pretzels: beverages"}
        |> permit()
        |> insert!()

      filters = [q: "pretzel"]

      assert [%Permit{id: ^inserted_id}] = Permits.list_permits(filters)
    end

    test "filter by 'contains q', no matches" do
      %{}
      |> permit()
      |> insert!()

      filters = [q: "not-in-permit"]

      assert [] = Permits.list_permits(filters)
    end
  end

  defp permit(attrs) do
    %{
      "location_id" => "1234",
      "location_description" => "1ST ST => LYMAN AVE to TAPESTRY RDG",
      "permit_number" => "23MFF-00030",
      "permit_holder" => "Bill's Snacks",
      "food_items" => "American Food: Hot dogs: pretzels: beverages",
      "hours_of_operation" => "Mo-Fr:12PM-8PM",
      "status" => "approved"
    }
    |> Map.merge(attrs)
  end

  defp insert!(attrs) do
    {:ok, permit} = Permits.create_permit(attrs)
    permit
  end
end
