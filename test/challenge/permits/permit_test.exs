defmodule Challenge.Permits.PermitTest do
  use Challenge.DataCase, async: true

  alias Challenge.Permits.Permit

  describe "changeset/2" do
    test "valid attrs produce a valid changeset" do
      attrs = %{
        location_id: "1234",
        location_description: "1ST ST: LYMAN AVE to TAPESTRY RDG",
        permit_number: "23MFF-00030",
        permit_holder: "Bill's Snacks",
        food_items: "American Food: Hog dogs: pretzels: beverages",
        hours_of_operation: "Mo-Fr:12PM-8PM",
        status: "approved"
      }

      expect = %{attrs | location_id: 1234, status: :approved}

      changeset = Permit.changeset(%Permit{}, attrs)

      assert changeset.valid?

      for {k, v} <- expect do
        assert changeset.changes[k] == v
      end
    end

    test "empty attrs produce an invalid changeset" do
      changeset = Permit.changeset(%Permit{}, %{})

      refute changeset.valid?

      assert %{
               location_id: ["can't be blank"],
               permit_number: ["can't be blank"],
               permit_holder: ["can't be blank"],
               status: ["can't be blank"]
             } == errors_on(changeset)
    end

    test "lengthy fields produce changeset errors" do
      too_long = String.duplicate("ABCDE", 52)

      attrs = %{
        permit_number: too_long,
        hours_of_operation: too_long
      }

      changeset = Permit.changeset(%Permit{}, attrs)

      refute changeset.valid?

      assert %{
               permit_number: ["should be at most 255 character(s)"],
               hours_of_operation: ["should be at most 255 character(s)"]
             } = errors_on(changeset)
    end
  end
end
