Puppet::Type.type(:transition).provide(:ruby) do
  desc "Ruby provider for transition type. This provider is not platform
    specific."

  def transition
  end

  def insync?(is)
    false
  end

end
