# Transition Module #

This module provides a Puppet type and provider for describing conditional
transition states. It allows users to describe a scenario where prior to
performing a change, a temporary state should be invoked.

## Example Use Case ##

Consider the following scenario.

The desired end state is that the `myapp` service is running, and that the
`myapp.cfg` file has some specific content. In Puppet this can be modeled with
the following code.

    file { '/etc/myapp/myapp.cfg':
      ensure  => file,
      content => 'enabled=1',
      notify  => Service['myapp'],
    }

    service { 'myapp':
      ensure => running,
      enable => true,
    }

The `myapp` service, however, is sensitive to the configuration file being
changed while it is running. In order to ensure consistency, its developers
recommend that the configuration file not be changed while the application is
running.

Puppet is designed to model end state, and by default it cannot model the
desired procedure of shutting down `myapp`, modifying `myapp.cfg`, and then
starting `myapp` back up.

The transition module provides a new type that can be used to express this
*intermediate state*. It is used as follows.

    transition { 'stop myapp service':
      resource   => Service['myapp'],
      attributes => { ensure => stopped },
      prior_to   => File['/etc/myapp/myapp.cfg'],
    }

    file { '/etc/myapp/myapp.cfg':
      ensure  => file,
      content => 'enabled=1',
      notify  => Service['myapp'],
    }

    service { 'myapp':
      ensure => running,
      enable => true,
    }

The transition type specifies two things. First, it specifies a desired
transition state in the form of a Puppet resource reference and parameters for
that resource. Second, it specifies an array of other resources in the catalog,
for which this temporary transition state should be invoked prior to changing.

The type also adds a `before` edge to each resource in the `prior_to`
parameter, and a `require` edge to the resource specified in the `resource`
parameter.

When evaluated, the transition provider will retrieve each resource specified
in the `prior_to` hash from the catalog, and invoke its `in_sync?` method. If
any of the resources are found to be out of sync, the transition resource will
apply the state defined by the resource and attribute parameters. This is
effectively a look-ahead refreshonly kind of behavior. The end-state will later
be applied when (in the example above) the `Service['myapp']` resource is
evaluated.
