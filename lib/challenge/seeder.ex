defmodule Challenge.Seeder do
  alias Challenge.Permits
  alias Challenge.Repo

  @doc """
  Inserts an enumerable of permits into the database.
  This function is idempotent and can be safely called multiple times.
  """
  @spec seed_permits(Enumerable.t(), pos_integer()) :: :ok | {:error, Ecto.Changeset.t()}
  def seed_permits(enumerable, chunk_size \\ 100) do
    enumerable
    |> Stream.chunk_every(chunk_size)
    |> Enum.reduce_while(:ok, fn permits, :ok ->
      case insert_permits(permits) do
        :ok -> {:cont, :ok}
        {:error, changeset} -> {:halt, {:error, changeset}}
      end
    end)
  end

  # Inserts permits within a database transaction.
  # Initiates rollback upon first failure.
  defp insert_permits(permits) do
    tx_result =
      Repo.transaction(fn ->
        Enum.reduce_while(permits, :ok, fn permit, :ok ->
          case Permits.upsert_permit(permit) do
            {:ok, _permit} -> {:cont, :ok}
            {:error, changeset} -> {:halt, Repo.rollback(changeset)}
          end
        end)
      end)

    case tx_result do
      {:ok, :ok} -> :ok
      {:error, error} -> {:error, error}
    end
  end
end
