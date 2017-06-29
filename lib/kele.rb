require 'httparty'
require 'json'
require './lib/roadmap'

class Kele
  include HTTParty
  include Roadmap

  base_uri 'https://www.bloc.io/api/v1'

  def initialize(email, password)
    @email = email
    @password = password

    response = self.class.post('/sessions', body: {email: email, password: password})

    @auth_token = response['auth_token']
  end

  def get_me
    response = self.class.get('/users/me', headers: { authorization: @auth_token })
    @user_data = JSON.parse(response.body)
  end

  def get_mentor_availability
    mentor_id = self.get_me['current_enrollment']['mentor_id']
    mentor_response = self.class.get("/mentors/#{mentor_id}/student_availability", headers: { authorization: @auth_token })
    @mentor_sched = JSON.parse(mentor_response.body)
    @mentor_sched.to_a
  end

  def get_messages(page=1)
    msg_response = self.class.get("/message_threads", headers: { authorization: @auth_token }, body: { page: page })
    @messages = JSON.parse(msg_response.body)
  end

  def create_message(sender_email, recipient_id, subject = "", message)
    inputs = {body: {user_id: sender_email, recipient_id: recipient_id, subject: subject, "stripped-text": message}, headers: { authorization: @auth_token }}
    post_response = self.class.post("/messages", inputs)
    raise "There was an error, try again." if post_response.code != 200
  end

  def create_submission(assignment_branch, assignment_commit_link, checkpoint_id, comment = "", enrollment_id=get_me['current_enrollment']['id'])
    body = {
      assignment_branch: assignment_branch,
      assignment_commit_link: assignment_commit_link,
      checkpoint_id: checkpoint_id,
      comment: comment,
      enrollment_id: enrollment_id
    }

    submission_response = self.class.post("/checkpoint_submissions", headers: { authorization: @auth_token }, body: body)
  end
end
