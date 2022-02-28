require 'spec_helper_acceptance'

describe 'Test Transition Type' do
  context 'consume tranisition type in manifest' do
    it 'uses tranisition idempotently' do
      pp = <<-MANIFEST
      include testing

class testing()
 {

transition { 'stop puppet service':
  resource   => Service['puppet'],
  attributes => { ensure => stopped },
  prior_to   => File['/tmp/test.cfg'],
}

file { '/tmp/test.cfg':
  ensure  => file,
  content => 'enabled=1',
  notify  => Service['puppet'],
}

service { 'puppet':
  ensure => running,
  enable => true,
}




}#{'  '}
      MANIFEST

      idempotent_apply(pp)
    end
  end
end
