defmodule Todo.Database do

  use GenServer

  @doc """
  Database module
  """

  def start(db_folder) do
    GenServer.start(__MODULE__, db_folder, name: :database_server)
  end

  def init(db_folder) do
    File.mkdir_p(db_folder)
    {:ok, db_folder}
  end

  def store(key, data) do
    GenServer.cast(:database_server, {:store, key, data})
  end

  def get(key) do
    GenServer.call(:database_server, {:get, key})
  end

  def handle_cast({:store, name, data}, db_folder) do
    file_name(db_folder, key)
    |> File.write!(data |> :erlang.term_to_binary)

    {:noreply, db_folder}
  end

  def handle_call({:get, name}, caller, db_folder) do
    data = case File.read(file_name(db_folder, key)) do
      {:ok, contents} -> :erlang.binary_to_term(contents)
      _ -> nil
    end

    {:reply, data, db_folder}
  end

  defp file_name(db_folder, key), do: "#{db_folder}/#{key}"
end
