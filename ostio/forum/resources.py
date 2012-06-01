from django import forms
from django.core.urlresolvers import reverse as django_reverse
from django.utils.functional import lazy
from djangorestframework.resources import ModelResource
from ostio.forum import models

def reverse(viewname, *args, **kwargs):
    """
    Same as `django.core.urlresolvers.reverse`, but optionally takes a request
    and returns a fully qualified URL, using the request to get the base URL.
    """
    request = kwargs.pop('request', None)
    url = django_reverse(viewname, *args, **kwargs)
    if request:
        return request.build_absolute_uri(url)
    return url


reverse_lazy = lazy(reverse, str)


def gen_fields(model, rel_fields=tuple()):
    all_fields = set(field.name for field in model._meta.fields)
    fields = all_fields - set(rel_fields.keys()) | set(rel_fields.items())
    return frozenset(fields)


class UserResource(ModelResource):
    model = models.User
    include = ('gravatar_id', 'type')
    exclude = ('password', 'is_active', 'is_staff', 'is_superuser')

    def gravatar_id(self, instance):
        return instance.userprofile.gravatar_id

    def type(self, instance):
        return instance.userprofile.type

    def url(self, request, instance):
        return reverse(
            'user',
            kwargs={'username': instance.username}
        )

    def repos(self, request, instance):
        return reverse(
            'repos',
            kwargs={'user': instance}
        )


class RepoResource(ModelResource):
    model = models.Repo
    fields = gen_fields(model, {'user': UserResource})
    parents = (UserResource,)

    def url(self, request, instance=None):
        if instance is None:
            instance = request
        return reverse(
            'repo',
            kwargs={'name': instance.name}
        )

    def threads(self, request, instance):
        return reverse(
            'threads',
            kwargs={'repo': instance}
        )


class ThreadResource(ModelResource):
    model = models.Thread
    fields = gen_fields(model, {'repo': RepoResource}) |\
        frozenset(('first_post', 'total_posts'))
    parents = (RepoResource,)

    def first_post(self, instance):
        return instance.post_set.all()[0]

    def total_posts(self, instance):
        return instance.post_set.count()

    def url(self, request, instance):
        return reverse(
            'thread',
            kwargs={'number': instance.number}
        )

    def posts(self, request, instance):
        return reverse(
            'posts',
            kwargs={'thread': instance}
        )


class PostResource(ModelResource):
    model = models.Post
    fields = gen_fields(model, {'thread': ThreadResource, 'user': UserResource})
    parents = (ThreadResource,)

    def thread(self, request, instance):
        return reverse(
            'thread',
            kwargs={'thread': instance}
        )
