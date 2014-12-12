defmodule Todo.Database do

  use GenServer

  @doc """
  Database module
  """

  @pool_size 3

  def start_link(db_folder) do
    GenServer.start_link(__MODULE__, db_folder, name: :database_server)
  end

  def store(key, data) do
    key
    |> choose_worker
    |> Todo.DatabaseWorker.store(key, data)
  end

  def get(key) do
    key
    |> choose_worker
    |> Todo.DatabaseWorker.get(key)
  end

  defp choose_worker(key) do
    GenServer.call(:database_server, {:choose_worker, key})
  end

  def init(db_folder) do
    File.mkdir_p(db_folder)
    {:ok, start_workers(db_folder)}
  end

  defp start_workers(db_folder) do
    for n <- 0..(@pool_size - 1), into: HashDict.new do
      {:ok, pid} = Todo.DatabaseWorker.start_link(db_folder)
      {n, pid}
    end
  end

  def handle_call({:choose_worker, key}, _, workers) do
    worker_key = :erlang.phash2(key, @pool_size)
    {:reply, HashDict.get(workers, worker_key), workers}
  end

end
