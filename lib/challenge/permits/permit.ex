defmodule Challenge.Permits.Permit do
  @moduledoc """
  Module to define a Permit ecto schema and corresponding functionality
  """

  use Challenge.Schema

  alias Ecto.Changeset

  @type t :: %__MODULE__{}

  schema "permits" do
    field :location_id, :integer
    field :location_description, :string
    field :permit_number, :string
    field :permit_holder, :string
    field :food_items, :string
    field :hours_of_operation, :string
    field :status, Ecto.Enum, values: [:requested, :approved, :issued, :expired, :suspend]

    timestamps()
  end

  @doc """
  Returns a changeset for a permit
  """
  @spec changeset(t, map()) :: Changeset.t(t)
  def changeset(permit, attrs) do
    permit
    |> Changeset.cast(attrs, [
      :location_id,
      :location_description,
      :permit_number,
      :permit_holder,
      :food_items,
      :hours_of_operation,
      :status
    ])
    |> Changeset.validate_required([
      :location_id,
      :permit_number,
      :permit_holder,
      :status
    ])
    |> Changeset.validate_length(:permit_number, max: 255)
    |> Changeset.validate_length(:hours_of_operation, max: 255)
    |> Changeset.unique_constraint(:location_id)
  end
end
