defmodule Todo.Cache do
  use GenServer

  def init(_) do
    Todo.Database.start("./persist/")
    {:ok, HashDict.new}
  end

  def start do
    GenServer.start_link(__MODULE__, nil)
  end

  def get_or_create(cache_pid, todo_list_name) do
    GenServer.call(cache_pid, {:get_or_create, todo_list_name})
  end

  def handle_call({:get_or_create, todo_list_name}, _, todo_servers) do
    case HashDict.fetch(todo_servers, todo_list_name) do
      {:ok, todo_server} ->
        {:reply, todo_server, todo_servers}
      :error ->
        {:ok, new_server} = Todo.Server.start(todo_list_name)
        {
          :reply,
          new_server,
          HashDict.put(todo_servers, todo_list_name, new_server)
        }
    end
  end
end
