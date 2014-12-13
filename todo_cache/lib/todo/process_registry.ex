defmodule Todo.ProcessRegistry do
  import Kernel, except: [send: 2]

  use GenServer

  @doc """
  ProcessRegistry module
  """

  def start_link do
    IO.puts "Starting process registry"
    GenServer.start_link(__MODULE__, nil, name: :process_registry)
  end

  def init(_) do
    {:ok, HashDict.new}
  end

  def register_name(key, pid) do
    GenServer.call(:process_registry, {:register_name, key, pid})
  end

  def whereis_name(key) do
    GenServer.call(:process_registry, {:whereis_name, key})
  end

  def unregister_name(key) do
    GenServer.cast(:process_registry, {:unregister_name, key})
  end

  def send(key, message) do
    case whereis_name(key) do
      :undefined -> {:badarg, {key, message}}
      pid ->
        Kernel.send(pid, message)
        pid
    end
  end


  def handle_call({:register_name, key, pid}, _caller, state) do
    case HashDict.get(state, key) do
    nil ->
      Process.monitor(pid)
      {:reply, :yes, HashDict.put(state, key, pid)}
    _ ->
      {:reply, :no, state}
    end
  end

  def handle_call({:whereis_name, key}, _caller, state) do
    {:reply, HashDict.get(state, key, :undefined), state}
  end

  def handle_call({:unregister_name, key}, _caller, state) do
    {:reply, key, HashDict.delete(state, key)}
  end

  def handle_info({:DOWN, _, :process, pid, _}, state) do
    new_reristry =
      for {k, v} <- state, v != pid, into: HashDict.new do
        {k, v}
      end
    {:noreply, new_reristry}
  end

  def handle_info(_, state), do: {:noreply, state}
end
