defmodule Bonfire.UI.Social.ThreadLive do
  use Bonfire.Web, :live_component
  alias Bonfire.Fake
  alias Bonfire.Web.LivePlugs
  alias Bonfire.Me.Users
  alias Bonfire.Me.Web.{CreateUserLive, LoggedDashboardLive}
  # import Bonfire.Me.Integration

  @thread_max_depth 3 # TODO: put in config

  def update(%{replies: replies, threaded_replies: threaded_replies} = assigns, socket) when is_list(replies) and length(replies)>0 and is_list(threaded_replies) and length(threaded_replies)>0 do
    IO.inspect("preloaded replies")
    {:ok, assign(socket, assigns |> assigns_merge(
      reply_to_thread_id: e(assigns, :activity, :replied, :thread_id, nil) || e(assigns, :thread_id, nil), # TODO: change for thread forking?
      thread_max_depth: @thread_max_depth
    )) }
  end

  def update(%{replies: replies} = assigns, %{assigns: %{replies: previous_replies}} = socket) when is_list(replies) and length(replies)>0 do
    IO.inspect("add thread reply")
    # IO.inspect(merge_reply: previous_replies)
    replies = e(socket, assigns, :replies, []) ++ previous_replies
    {:ok, assign(socket, assigns |> assigns_merge(
      replies: replies,
      threaded_replies: Bonfire.Social.Threads.arrange_replies_tree(replies),
      reply_to_thread_id: e(assigns, :activity, :replied, :thread_id, nil) || e(assigns, :thread_id, nil), # TODO: change for thread forking?
      thread_max_depth: @thread_max_depth
    )) }
  end

  def update(assigns, socket) do
    # IO.inspect(assigns)

    # replies = Bonfire.Data.Social.Replied.descendants(thread)
    #IO.inspect(replies, label: "REPLIES:")
    # replies = replies |> repo().all

    # replies = Bonfire.Social.Posts.replies_tree(e(thread, :thread_replies, []))

    thread_id = e(assigns, :thread_id, nil)

    if thread_id do

      current_user = e(assigns, :current_user, nil)
      activity = e(assigns, :activity, nil)
      object = e(assigns, :object, e(activity, :object_post_content, e(activity, :object)))
      # IO.inspect(object, label: "thread_object:")

      with %{entries: replies, metadata: page_info} <- Bonfire.Social.Threads.list_replies(thread_id, current_user, e(assigns, :after, nil), @thread_max_depth) do
        threaded_replies = if is_list(replies) and length(replies)>0, do: Bonfire.Social.Threads.arrange_replies_tree(replies), else: []

        # IO.inspect(threaded_replies, label: "threaded_replies:")

        {:ok,
        assign(socket, assigns
        |> assigns_merge(
          thread_id: thread_id,
          activity: activity,
          object: object,
          reply_to_id: e(activity, :object, :id, nil) || thread_id, # TODO: change for thread forking?
          reply_to_thread_id: e(activity, :replied, :thread_id, nil) || thread_id, # TODO: change for thread forking?
          current_user: current_user,
          page: "thread",
          replies: replies || [],
          threaded_replies: threaded_replies,
          page_info: page_info,
          thread_max_depth: @thread_max_depth,
          # participants: participants
        ))}
      end
    end
  end

  # def handle_event(action, attrs, socket), do: Bonfire.Web.LiveHandler.handle_event(action, attrs, socket, __MODULE__)
  # def handle_info(info, socket), do: Bonfire.Web.LiveHandler.handle_info(info, socket, __MODULE__)

end
