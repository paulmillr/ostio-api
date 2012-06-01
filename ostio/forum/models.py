from django.contrib.auth.models import User
from django.db import models
from datetime import datetime


class UserProfile(models.Model):
    user = models.OneToOneField(User)
    gravatar_id = models.CharField(max_length=255)
    type = models.CharField(max_length=255, default='User')


class Repo(models.Model):
    user = models.ForeignKey(User)
    name = models.CharField(max_length=255)

    def get_last_thread_number(self):
        values = self.thread_set.values_list('number')
        return values[0][0] if values else 0



class Thread(models.Model):
    repo = models.ForeignKey(Repo)
    number = models.PositiveIntegerField(db_index=True)
    name = models.CharField(max_length=255)
    created_at = models.DateTimeField(default=datetime.now)
    updated_at = models.DateTimeField(blank=True)

    def save(self, *args, **kwargs):
        if self.number is None:
            self.number = self.repo.get_last_thread_number() + 1
        if self.updated_at is None:
            self.updated_at = self.created_at
        super(Thread, self).save(*args, **kwargs)

    def first_post(self):
        return self.post_set.all()[0]


class Post(models.Model):
    thread = models.ForeignKey(Thread)
    user = models.ForeignKey(User)
    text = models.TextField()
    created_at = models.DateTimeField(default=datetime.now)

    def save(self, *args, **kwargs):
        """
        * Create thread if the post is first in thread.
        * Update thread.updated_at if the post is new.
        """
        thread_modified = False
        if self.thread is None:
            self.thread = Thread.objects.create(
                repo=kwargs['thread__repo'],
                name=kwargs['thread__name']
            )
            thread_modified = True
        if self.id is None:
            self.thread.updated_at = self.created_at
            thread_modified = True
        if thread_modified:
            self.thread.save()
        super(Post, self).save(*args, **kwargs)


def create_user_profile(sender, instance, created, **kwargs):
    """Connects UserProfile class with built-in User."""
    if created:
        profile, created = UserProfile.objects.get_or_create(user=instance)


models.signals.post_save.connect(create_user_profile, sender=User)
