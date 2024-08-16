class SetPostJob < ApplicationJob
  queue_as :default

  def perform(fork_id)
    fork = Fork.find(fork_id)
    if (fork)
      result = get_post e621_post['id'], fork
      assign_e621_post_to_self result, fork if result
    end
  end
end
