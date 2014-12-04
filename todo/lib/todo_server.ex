defmodule TodoServer do

  use GenServer

  @doc """
  TodoServer module
  """

  def start do
    {:ok, pid} = GenServer.start_link(__MODULE__, nil)
    pid
  end

  def init(_) do
    {:ok, TodoList.new}
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
  def handle_cast({:add_entry, entry}, todo_list) do
    {:noreply, TodoList.add_entry(todo_list, entry)}
  end
  def handle_cast({:update_entry, entry_id}, todo_list) do
    {:noreply, TodoList.delete_entry(todo_list, entry_id)}
  end
  def handle_cast({:delete_entry, entry_id}, todo_list) do
    {:noreply, TodoList.delete_entry(todo_list, entry_id)}
  end

  def handle_call({:entries, date}, _caller, todo_list) do
    entries_result = TodoList.entries(todo_list, date)
    {:reply, entries_result, todo_list}
  end
end
