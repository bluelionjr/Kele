module Roadmap
  def get_roadmap
    roadmap_id = get_me['current_enrollment']['roadmap_id']
    map_response = self.class.get("/roadmaps/#{roadmap_id}", headers: { authorization: @auth_token })
    @roadmap = JSON.parse(map_response.body)
  end

  def get_checkpoint(checkpoint_id)
    cp_response = self.class.get("/checkpoints/#{checkpoint_id}", headers: { authorization: @auth_token })
    @checkpoint = JSON.parse(cp_response.body)
  end
end
