defmodule Todo.Cache do
  use GenServer

  def start_link do
    IO.puts "Starting TodoCache..."
    GenServer.start_link(__MODULE__, nil, name: :todo_cache)
  end

  def init(_) do
    {:ok, HashDict.new}
  end

  def get_or_create(todo_list_name) do
    IO.puts("Starting to-do server for #{todo_list_name}")
    GenServer.call(:todo_cache, {:get_or_create, todo_list_name})
  end

  def handle_call({:get_or_create, todo_list_name}, _, todo_servers) do
    case HashDict.fetch(todo_servers, todo_list_name) do
      {:ok, todo_server} ->
        {:reply, todo_server, todo_servers}
      :error ->
        {:ok, new_server} = Todo.Server.start_link(todo_list_name)
        {
          :reply,
          new_server,
          HashDict.put(todo_servers, todo_list_name, new_server)
        }
    end
  end
end
