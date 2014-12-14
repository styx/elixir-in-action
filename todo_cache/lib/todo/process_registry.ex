defmodule Todo.ProcessRegistry do
  import Kernel, except: [send: 2]

  def start_link do
    IO.puts "Starting process registry"
    GenServer.start_link(__MODULE__, nil, name: :process_registry)
  end

  def register_name(key, pid) do
    GenServer.call(:process_registry, {:register_name, key, pid})
  end

  def whereis_name(key) do
    GenServer.call(:process_registry, {:whereis_name, key})
  end

  def unregister_name(key) do
    GenServer.call(:process_registry, {:unregister_name, key})
  end

  def send(key, message) do
    case whereis_name(key) do
      :undefined -> {:badarg, {key, message}}
      pid ->
        Kernel.send(pid, message)
        pid
    end
  end

  def init(_) do
    {:ok, HashDict.new}
  end


  def handle_call({:register_name, key, pid}, _, process_registry) do
    case HashDict.get(process_registry, key) do
      nil ->
        # Sets up a monitor to the registered process
        Process.monitor(pid)
        {:reply, :yes, HashDict.put(process_registry, key, pid)}
      _ ->
        {:reply, :no, process_registry}
    end
  end

  def handle_call({:whereis_name, key}, _, process_registry) do
    {:reply, HashDict.get(process_registry, key, :undefined), process_registry}
  end

  def handle_call({:unregister_name, key}, _, process_registry) do
    {:reply, key, HashDict.delete(process_registry, key)}
  end

  # Handles termination of a registered process
  def handle_info({:DOWN, _, :process, pid, _}, process_registry) do
    # Here, we have to remove the entry by value. We basically rebuild the
    # HashDict by including all registry entries except for the crashed pid.
    new_registry =
      for {k, v} <- process_registry, v != pid, into: HashDict.new do
        {k, v}
      end
    {:noreply, new_registry}
  end

  def handle_info(_, state), do: {:noreply, state}
end