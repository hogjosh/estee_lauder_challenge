# Use permits.csv in the same directory as this file.
# Commit to the database in chunks.
# Note that the seed operation is idempotent, and thus
# can be re-run safely.
"#{__DIR__}/permits.csv"
|> File.stream!()
|> Challenge.CSVSeed.stream_permits()
|> Stream.chunk_every(100)
|> Enum.each(fn chunk ->
  Challenge.Repo.transaction(fn ->
    Enum.each(chunk, fn attrs ->
      {:ok, _permit} = Challenge.Permits.upsert_permit(attrs)
    end)
  end)
end)
