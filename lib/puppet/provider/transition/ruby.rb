Puppet::Type.type(:transition).provide(:ruby) do
  desc "Ruby provider for transition type. This provider is not platform
    specific."

  def transition
  end

  def transition?
    priors = [@resource['prior_to']].flatten.map do |item|
      resolve_resource(item)
    end

    # TODO: something useful, or finish the method

    insync_states.include?(:false)
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
