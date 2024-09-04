defmodule Challenge.CSVSeed do
  # Use the included CSV parser based on RFC4180
  alias NimbleCSV.RFC4180, as: CSV

  @doc """
    Transforms an enumerable of csv rows into an enumerable
    of permit attributes.
  """
  @spec stream_permits(Enumerable.t()) :: Enumerable.t()
  def stream_permits(enumerable) do
    enumerable
    |> CSV.parse_stream(skip_headers: false)
    |> Stream.transform(nil, fn
      # The first row will be the headers.
      # We need to rename them to align with our schema.
      headers, nil ->
        {[], rename_headers(headers)}

      # Every other row will be data.
      # Combine the headers with the row
      # to create key value pairs and
      # turn the into a map.
      #
      # Some of our data requires postprocessing
      # so we'll handle that here as well.
      row, headers ->
        attrs =
          [
            headers
            |> Enum.zip(row)
            |> Map.new()
            |> postprocess_data()
          ]

        {attrs, headers}
    end)
  end

  # Mappings from the CSV header to our schema field name.
  @header_rename %{
    "locationid" => "location_id",
    "Applicant" => "permit_holder",
    "LocationDescription" => "location_description",
    "permit" => "permit_number",
    "Status" => "status",
    "FoodItems" => "food_items",
    "dayshours" => "hours_of_operation"
  }

  # The CSV headers differ from our schema fields.
  # As necessary, rename the ones that are represented
  # in the schema and ignore the rest.
  defp rename_headers(headers) do
    headers
    |> Enum.reduce([], fn h, headers ->
      case Map.get(@header_rename, h) do
        nil -> [h | headers]
        renamed -> [renamed | headers]
      end
    end)
    |> Enum.reverse()
  end

  # Our schema expects some fields to be in a particular form.
  # 'status' is expected to be lower case.
  defp postprocess_data(row) do
    Map.update!(row, "status", &String.downcase/1)
  end
end
