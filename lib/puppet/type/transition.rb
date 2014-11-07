Puppet::Type.newtype(:transition) do
  @doc = "Define a transitional state."

  newproperty(:enable) do
    desc "Enable or disable this conditional state transition. Valid values
      are true or false."

    # If the transition should occur and the transition resource is enabled,
    # call the provider's transition() method.
    newvalue(:true) do
      @resource.transition
    end

    # If the transition is disabled (enable=false), the transition resource
    # should always be # considered insync. Therefore a sync method for the
    # property should never be called if enable=false.
    newvalue(:false) do
      raise "Improperly implemented insync?() method"
    end
  end

  newparam(:resource) do
    desc "The resource for which a transitional state is being defined. This
      should be a resource reference (e.g. Service['apache']). This resource
      will be made to autorequire the transitional state."

    validate do |value|
      # TODO: implement validation checking that the value is either a valid
      # resource reference, or a string that can be converted to a valid
      # resource reference.
      true
    end

    munge do |value|
      # TODO: if the value is not already a valid resource reference, convert
      # it into one.
      value
    end
  end

  newparam(:attributes) do
    desc "The hash of attributes to set on the resource when applying a
      transitional state. Each hash key must be a valid attribute for the
      resource being transitioned."

    validate do |value|
      # TODO: validate that this is a hash.
      true
    end
  end

  newparam(:prior_to, :array_matching => :all) do
    desc "An array of resources to check for synchronization. If any of these
      resources are out of sync (change pending), then this transitional state
      will be applied. These resources will each be made to autorequire the
      transitional state."

    validate do |value|
      # TODO: validate that each element is a valid resource reference.
      true
    end
  end

end
