defmodule TodoList.CsvImporter do

  @doc """
  Reads Todo lists from CSV file
  """

  def import(path) do
    File.stream!(path)
    |> Stream.map(&String.strip/1)
    |> Stream.map(&parse_line/1)
    |> TodoList.new
  end

  defp parse_line([date, title | []]) do
    [year, month, day] = date |> String.split("/")
    %{
      date: { String.to_integer(year), String.to_integer(month), String.to_integer(day) },
      title: title
    }
  end

  defp parse_line(str) do
    String.split(str, ",")
    |> parse_line
  end

end
