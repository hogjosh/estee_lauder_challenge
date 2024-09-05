defmodule Challenge.PermitsTest do
  use Challenge.DataCase, async: true

  alias Challenge.Permits
  alias Challenge.Permits.Permit
  alias Scrivener.Page

  describe "upsert_permit/1" do
    test "valid attrs insert a permit" do
      attrs = %{
        location_id: "1234",
        location_description: "1ST ST: LYMAN AVE to TAPESTRY RDG",
        permit_number: "23MFF-00030",
        permit_holder: "Bill's Snacks",
        food_items: "American Food: Hot dogs: pretzels: beverages",
        hours_of_operation: "Mo-Fr:12PM-8PM",
        status: "approved"
      }

      assert {:ok, %Permit{} = permit} = Permits.upsert_permit(attrs)

      expect = %{attrs | location_id: 1234, status: :approved}

      for {k, v} <- expect do
        assert Map.get(permit, k) == v
      end
    end

    test "valid attrs update a permit" do
      insert_attrs = %{
        location_id: "1234",
        location_description: "1ST ST: LYMAN AVE to TAPESTRY RDG",
        permit_number: "23MFF-00030",
        permit_holder: "Bill's Snacks",
        food_items: "American Food: Hot dogs: pretzels: beverages",
        hours_of_operation: "Mo-Fr:12PM-8PM",
        status: "approved"
      }

      assert {:ok, %Permit{id: id}} = Permits.upsert_permit(insert_attrs)

      update_attrs = %{
        insert_attrs
        | location_description: "2ND ST: MAIN ST to PEACHTREE BLVD",
          permit_number: "23MFF-00040",
          permit_holder: "Bob's Snacks",
          food_items: "American Food: Hot dogs: beverages",
          hours_of_operation: "Tu-Fr:12PM-8PM",
          status: "issued"
      }

      assert {:ok, %Permit{id: ^id} = permit} = Permits.upsert_permit(update_attrs)

      expect = %{update_attrs | location_id: 1234, status: :issued}

      for {k, v} <- expect do
        assert Map.get(permit, k) == v
      end
    end

    test "invalid attrs will not upsert a permit" do
      assert {:error, %Ecto.Changeset{}} = Permits.upsert_permit(%{})
    end
  end

  describe "page_permits/1" do
    test "opts by status with case insensitivity" do
      %{id: inserted_id} =
        %{"status" => "approved"}
        |> permit()
        |> upsert!()

      opts = [status: "APPROVED"]

      assert %Page{
               entries: [%Permit{id: ^inserted_id}]
             } = Permits.page_permits(opts)

      opts = [status: "expired"]

      assert %Page{
               entries: []
             } = Permits.page_permits(opts)
    end

    test "search matches location_description, case insensitive" do
      %{id: inserted_id} =
        %{"location_description" => "TAPESTRY RDG"}
        |> permit()
        |> upsert!()

      opts = [search: "tapestry"]

      assert %Page{
               entries: [%Permit{id: ^inserted_id}]
             } = Permits.page_permits(opts)
    end

    test "search matches permit_number, case insensitive" do
      %{id: inserted_id} =
        %{"permit_number" => "23MFF-00030"}
        |> permit()
        |> upsert!()

      opts = [search: "mff-00"]

      assert %Page{
               entries: [%Permit{id: ^inserted_id}]
             } = Permits.page_permits(opts)
    end

    test "search matches permit_holder, case insensitive" do
      %{id: inserted_id} =
        %{"permit_holder" => "Bill's Snacks"}
        |> permit()
        |> upsert!()

      opts = [search: "bill's"]

      assert %Page{
               entries: [%Permit{id: ^inserted_id}]
             } = Permits.page_permits(opts)
    end

    test "search matches food_items, case insensitive" do
      %{id: inserted_id} =
        %{"food_items" => "American Food: Hot dogs: Pretzels: beverages"}
        |> permit()
        |> upsert!()

      opts = [search: "pretzel"]

      assert %Page{
               entries: [%Permit{id: ^inserted_id}]
             } = Permits.page_permits(opts)
    end

    test "search no matches" do
      %{}
      |> permit()
      |> upsert!()

      opts = [search: "not-in-permit"]

      assert %Page{
               entries: []
             } = Permits.page_permits(opts)
    end

    test "pagination" do
      for n <- 1..5 do
        %{"location_id" => n}
        |> permit()
        |> upsert!()
      end

      opts = [page: 2, page_size: 1]

      assert %Page{
               page_number: 2,
               page_size: 1,
               entries: [%Permit{}],
               total_entries: 5,
               total_pages: 5
             } = Permits.page_permits(opts)
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

  defp upsert!(attrs) do
    {:ok, permit} = Permits.upsert_permit(attrs)
    permit
  end
end
