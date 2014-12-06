defmodule Todo.Server do

  use GenServer

  @doc """
  Todo.Server module
  """

  def start(name) do
    GenServer.start_link(__MODULE__, name)
  end

  def init(name) do
    send(self, {:real_init, name})
    {:ok, nil}
  end

  def add_entry(todo_server, entry) do
    GenServer.cast(todo_server, {:add_entry, entry})
  end

  def entries(todo_server, date) do
    GenServer.call(todo_server, {:entries, date})
  end

  def update_entry(todo_server, new_entry) do
    GenServer.cast(todo_server, {:update_entry, new_entry})
  end

  def delete_entry(todo_server, entry_id) do
    GenServer.cast(todo_server, {:delete_entry, entry_id})
  end

  def handle_info({:real_init, name}, nil) do
    initial_todo = Todo.Database.get(name) || Todo.List.new
    {:noreply, {name, initial_todo}}
  end

  def handle_cast({:add_entry, entry}, {name, todo_list}) do
    new_state = Todo.List.add_entry(todo_list, entry)
    Todo.Database.store(name, new_state)
    {:noreply, {name, new_state}}
  end
  def handle_cast({:update_entry, entry_id}, {name, todo_list}) do
    {:noreply, {name, Todo.List.delete_entry(todo_list, entry_id)}}
  end
  def handle_cast({:delete_entry, entry_id}, {name, todo_list}) do
    {:noreply, {name, Todo.List.delete_entry(todo_list, entry_id)}}
  end

  def handle_call({:entries, date}, _caller, {name, todo_list}) do
    entries_result = Todo.List.entries(todo_list, date)
    {:reply, entries_result, {name, todo_list}}
  end
end
