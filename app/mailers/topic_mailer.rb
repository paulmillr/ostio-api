class TopicMailer < ActionMailer::Base
  default from: 'noreply@ost.io'

  def new_post_email(post)
    @post = post
    topic = post.topic
    repo = topic.repo
    post_user = post.user
    repo_user = repo.user
    @url = "ost.io/#{repo_user.login}/#{repo.name}/topics/#{topic.number}"

    user_email = post_user.email
    emails = topic.poster_emails.select { |email| email != user_email }
    subject = "Re: [#{repo.name}] #{post.text}"

    emails.each do |email|
      mail(to: email, subject: subject)
    end
  end
end
