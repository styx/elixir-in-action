defmodule TodoServer do
  @doc """
  TodoServer module
  """

  def start do
    spawn(fn ->
      loop(TodoList.new)
    end)
  end

  def add_entry(todo_server, entry) do
    send(todo_server, {:add_entry, entry})
  end

  def entries(todo_server, date) do
    send(todo_server, {:entries, self, date})
    receive do
      {:entries_result, entries} ->
        entries
      _ -> nil
    end
  end

  defp loop(todo_list) do
    new_todo_list = receive do
      message ->
        process_message(todo_list, message)
    end

    loop(new_todo_list)
  end

  defp process_message(todo_list, {:add_entry, entry}) do
    TodoList.add_entry(todo_list, entry)
  end

  defp process_message(todo_list, {:entries, caller, date}) do
    entries_result = TodoList.entries(todo_list, date)
    send(caller, {:entries_result, entries_result})
    todo_list
  end

  defp process_message(todo_list, message) do
    IO.puts("Invalid request: #{message |> inspect}")
    todo_list
  end

end
