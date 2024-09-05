# Seed from permits.csv in the same directory as this file.
result =
  "#{__DIR__}/permits.csv"
  |> File.stream!()
  |> Challenge.CSVSource.stream_permits()
  |> Challenge.Seeder.seed_permits()

case result do
  :ok ->
    :ok

  {:error, %Ecto.Changeset{} = changeset} ->
    raise Ecto.InvalidChangesetError, action: :seed, changset: changeset
end
