use inc::Module::Install;


RTx 'RT-Action-MoveQueueBySubject';
all_from 'lib/RT/Action/MoveQueueBySubject.pm';
readme_from 'lib/RT/Action/MoveQueueBySubject.pm';
license  'gplv2';

sign;
manifest_skip;
auto_manifest;
WriteAll;
