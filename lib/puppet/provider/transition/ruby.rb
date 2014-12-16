require 'puppet/application/resource'

Puppet::Type.type(:transition).provide(:ruby) do
  desc "Ruby provider for transition type. This provider is not platform
    specific."

  def transition
    catalog_resource = resolve_resource(@resource['resource'])
    name = catalog_resource.name
    type = catalog_resource.type
    resource_key = [type, name].join('/')

    # Retrive original resource definition attributes from catalog
    catalog_attributes = catalog_resource.to_hash

    # Symbolize keys in attributes parameter
    transition_attributes = @resource['attributes'].inject({}) do |new,(k,v)|
      new[k.to_sym] = v
      new
    end

    # Create a transitional, merged set of attributes, sans any attributes
    # with an explicit nil value. Those attributes appear to come from the
    # Type being copied, and we just want to build a new type from a
    # Resource.
    merged = catalog_attributes.merge(transition_attributes).reject do |k,v|
      v.nil? || [:before, :subscribe, :require, :notify].include?(k)
    end

    # Build and apply the resource. There is probably a better way of doing
    # this.
    rsrc = Puppet::Resource.new(type, name, :parameters => merged)
    result = Puppet::Resource.indirection.save(rsrc, resource_key)

    # TODO: Find a better way to log the results ???

    failed = result[1].resource_statuses[rsrc.to_s].events.any? do |event|
      event.status == "failure"
    end

    if failed
      events = result[1].resource_statuses[rsrc.to_s].events.map do |event|
        "#{event.property}: #{event.message}"
      end.join('; ')
      fail(events)
    end
  end

  def transition?
    # Retrieve each prior_to resource from the catalog.
    priors = [@resource['prior_to']].flatten.map do |item|
      resolve_resource(item)
    end

    # Determine if there are changes pending to any of the prior_to resources.
    pending_change = priors.any? do |resource|
      current_values = resource.retrieve_resource.to_hash
      resource.properties.any? do |property|
        current_value = current_values[property.name]
        if property.should && !property.safe_insync?(current_value)
          true
        else
          false
        end
      end
    end

    # If changes are pending, transition?() will return true.
    pending_change
  end

  # This method borrowed from the richardc/datacat module
  def resolve_resource(reference)
    if reference.is_a?(Puppet::Type)
      # Probably from a unit test, use the resource as-is
      return reference
    end

    if reference.is_a?(Puppet::Resource)
      # Already part resolved - puppet apply?
      # join it to the catalog where we live and ask it to resolve
      reference.catalog = resource.catalog
      return reference.resolve
    end

    if reference.is_a?(String)
      # 3.3.0 catalogs you need to resolve like so
      return resource.catalog.resource(reference)
    end

    # If we got here, panic
    raise "Don't know how to convert '#{reference.inspect}' of class #{reference.class} into a resource"
  end

end
