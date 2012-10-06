class TopicMailer < ActionMailer::Base
  default from: 'noreply@ost.io'

  def new_post_email(post, subscriber_email)
    @post = post
    topic = post.topic
    repo = topic.repo
    post_user = post.user
    repo_user = repo.user
    @url = "ost.io/#{repo_user.login}/#{repo.name}/topics/#{topic.number}"
    mail(to: subscriber_email, subject: "Re: [#{repo.name}] #{topic.title}")
  end
end
