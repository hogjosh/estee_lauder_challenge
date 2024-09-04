defmodule Challenge.Permits do
  @moduledoc """
  Context module used to perform actions with permits.
  """

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
end
