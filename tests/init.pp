node default {
  notify { 'alpha': }
  ->
  class  { 'java':
    distribution => 'jdk',
    version      => 'latest',
  }
  ->
  class  { 'intelie_activemq':
    webconsole => true,
  }
  ->
  notify { 'omega': }
}
