defmodule QueueChallenge.QueueService do
  @moduledoc """
  The QueueService GenServer
  """

  use GenServer
  require Logger

  @registry :queue_registry

  def start_link(queue_name, message) do
    name = get_name(queue_name)

    GenServer.start_link(
      __MODULE__,
      %{
        messages: [message],
        queue: queue_name
      },
      name: name
    )
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, opts},
      restart: :transient
    }
  end

  @impl true
  def init(%{queue: queue} = state) do
    [{pid, _}] = Registry.lookup(@registry, queue)
    :timer.send_interval(1000, pid, :process_message)
    {:ok, state}
  end

  @impl true
  def handle_info(:process_message, %{messages: messages} = state) when length(messages) > 0 do
    {message, updated_messages} = List.pop_at(messages, 0)
    Logger.info(message)
    {:noreply, %{state | messages: updated_messages}}
  end

  def handle_info(:process_message, state) do
    {:noreply, state}
  end

  @impl true
  def handle_call({:add_message, message}, _, %{messages: messages} = state) do
    {:reply, :ok, %{state | messages: List.insert_at(messages, length(messages) - 1, message)}}
  end

  def add_message(queue, message) do
    GenServer.call(get_name(queue), {:add_message, message})
  end

  def get_name(queue) do
    {:via, Registry, {@registry, queue}}
  end
end
