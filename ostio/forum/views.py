# Create your views here.
from djangorestframework import views


class RepoListOrCreateView(views.ListOrCreateModelView):
    """
    Behavior to list a set of `model` instances on GET requests
    """

    def get(self, request, *args, **kwargs):
        queryset = self.get_queryset()
        ordering = self.get_ordering()
        query_kwargs = self.get_query_kwargs(request, *args, **kwargs)

        queryset = queryset.filter(**query_kwargs)
        if ordering:
            queryset = queryset.order_by(*ordering)

        return queryset

    def post(self, request, *args, **kwargs):
        print kwargs, dict(self.CONTENT)
        return None
        model = self.resource.model

        # Copy the dict to keep self.CONTENT intact
        content = dict(self.CONTENT)
        m2m_data = {}

        for field in model._meta.many_to_many:
            if field.name in content:
                m2m_data[field.name] = (
                    field.m2m_reverse_field_name(), content[field.name]
                )
                del content[field.name]

        for field in kwargs.keys():
            if '__' in field:
                del kwargs[field]

        instance = model(**self.get_instance_data(model, content, *args, **kwargs))
        instance.save()

        for fieldname in m2m_data:
            manager = getattr(instance, fieldname)

            if hasattr(manager, 'add'):
                manager.add(*m2m_data[fieldname][1])
            else:
                data = {}
                data[manager.source_field_name] = instance

                for related_item in m2m_data[fieldname][1]:
                    data[m2m_data[fieldname][0]] = related_item
                    manager.through(**data).save()
