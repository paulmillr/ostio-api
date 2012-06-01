from django.conf.urls.defaults import patterns, url, include
from djangorestframework.views import ListOrCreateModelView, InstanceModelView
from ostio.forum import resources, views
import logging

urls = {
    'users': (r'users/$'),
    'user': (r'users/(?P<username>\w+)$'),
    'repos': (r'users/(?P<user__username>\w+)/repos/$'),
    'repo': (r'users/(?P<user__username>\w+)/repos/(?P<name>\w+)$'),
    'threads': (
        r'users/(?P<repo__user__username>\w+)' + 
        r'/repos/(?P<repo__name>\w+)' +
        r'/threads/$'
    ),
    'thread': (
        r'users/(?P<repo__user__username>\w+)' +
        r'/repos/(?P<repo__name>\w+)' + 
        r'/threads/(?P<number>\d+)$'
    ),
    'posts': (
        r'users/(?P<thread__repo__user__username>\w+)' + 
        r'/repos/(?P<thread__repo__name>\w+)' + 
        r'/threads/(?P<thread__number>\d+)' +
        r'/posts/$'
    ),
    'post': (
        r'users/(?P<thread__repo__user__username>\w+)' + 
        r'/repos/(?P<thread__repo__name>\w+)' + 
        r'/threads/(?P<thread__number>\d+)' + 
        r'/posts/(?P<id>\d+)'
    ),
}


def create_url(name):
    is_instance_url = not name.endswith('s')
    resource_name = name if is_instance_url else name[0:len(name) - 1]
    capitalized = resource_name.capitalize()
    if is_instance_url:
        model_view = getattr(views, '{}InstanceView'.format(capitalized),
            InstanceModelView)
    else:
        model_view = getattr(views, '{}ListOrCreateView'.format(capitalized),
            ListOrCreateModelView)
    resource_url = urls[name] + r'$'
    full_resource_name = '{}Resource'.format(capitalized)
    resource = getattr(resources, full_resource_name)
    return url(resource_url, model_view.as_view(resource=resource), name=name)


v1_urls = patterns('', *map(create_url, urls.keys()))


urlpatterns = patterns('',
    url(r'^restframework/', include('djangorestframework.urls', namespace='djangorestframework')),
    url(r'^v1/', include(v1_urls, namespace='v1')),
)
