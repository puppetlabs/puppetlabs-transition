Puppet::Type.newtype(:transition) do
  @doc = "Define a transitional state."

  # The enable property determines whether or not this transition state may be
  # applied. When enable=true, the property will call two methods in the
  # provider. It will call transition?() as its insync method. Therefore
  # transition?() should return true if the transitional state should be
  # implemented, and false if it should not. The transition() method should
  # implement the transitional state.
  newproperty(:enable) do
    desc "Enable or disable this conditional state transition. Valid values
      are true or false."

    newvalues :true, :false
    defaultto :true

    # If the transition should occur and the transition resource is enabled,
    # call the provider's transition() method.
    def sync
      @resource.provider.transition
    end

    # There is no getter method for this property as it is used only as a
    # decision point whether or not to realize the transition behavior if the
    # transition conditions exist. Therefore retrieve should just echo the
    # property value.
    def retrieve
      @resource["enable"]
    end

    # Whether or not the resource is insync is determined by the transition?()
    # method of the provider. To transition or not to transition, that is the
    # question.
    def insync?(is)
      case @resource["enable"]
      when :true
      require 'debug'; debugger
        # If a transition should occur, the resource is not insync.
        !@resource.provider.transition?
      else
        # Return true, since a disabled transition is always insync.
        true
      end
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

  # This resource does not need or use a namevar. However, it is far simpler to
  # define an unused name parameter and make it the namevar than it is to
  # convince Puppet that a namevar isn't needed.
  newparam(:name) do
    isnamevar
    desc "This parameter does not serve any function beyond setting the
      resource's name."
  end

end
