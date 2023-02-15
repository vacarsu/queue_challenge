defmodule QueueChallenge.QueueSupervisor do
  @moduledoc """
  The QueueService dynamic supervisor
  """
  use DynamicSupervisor

  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def start_child(name, message) do
    DynamicSupervisor.start_child(__MODULE__, {
      QueueChallenge.QueueService,
      [
        name,
        message
      ]
    })
  end

  @impl true
  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
