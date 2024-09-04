# Use permits.csv in the same directory as this file.
# Commit to the database in chunks.
"#{__DIR__}/permits.csv"
|> File.stream!()
|> Challenge.CSVSeed.stream_permits()
|> Stream.chunk_every(100)
|> Enum.each(fn chunk ->
  Challenge.Repo.transaction(fn ->
    Enum.each(chunk, fn attrs ->
      {:ok, _permit} = Challenge.Permits.create_permit(attrs)
    end)
  end)
end)
