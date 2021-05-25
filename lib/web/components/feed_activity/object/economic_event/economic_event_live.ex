defmodule Bonfire.UI.Social.Activity.EconomicEventLive do
  use Bonfire.Web, :stateless_component
  import Bonfire.UI.Social.Integration

  prop activity, :map
  prop object, :map

  @resource_preloads [:image, :current_location, onhand_quantity: [:unit], accounting_quantity: [:unit]]

  def update(%{object: object} = assigns, socket) do
    # TODO: run these preloads when fetching the feed, rather than n+1
    object = object |> preloads()
    {:ok, socket |>
      assigns_merge(assigns,
        verb_display: Bonfire.UI.Social.ActivityLive.verb_display(e(object, :action, :label, e(assigns.object, :action_id, ""))),
        object: object #|> IO.inspect
      )
    }
  end

  def preloads(object) do

    resource_preloads = Bonfire.UI.Social.Activity.EconomicResourceLive.resource_preloads()

    object
    |> repo().maybe_preload([
      :input_of,
      :output_of,
      resource_quantity: [:unit],
      effort_quantity: [:unit],
      resource_inventoried_as: resource_preloads,
      to_resource_inventoried_as: resource_preloads,
      action: preload_action(object)
    ])
  end

  def preload_action(object) do
    if module_enabled?(ValueFlows.EconomicEvent.EconomicEvents), do: ValueFlows.EconomicEvent.EconomicEvents.preload_action(object),
    else: Map.get(object, :action, Map.get(object, :action_id, nil))
  end

end