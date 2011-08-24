use strict;
use warnings;
package RT::Action::MoveQueueBySubject;
use base qw(RT::Action);

our $VERSION = '0.01';

=head1 NAME

RT-Action-MoveQueueBySubject - Move Tickets between queues based on Subject

=head1 INSTALLATION 

=over

=item perl Makefile.PL

=item make

=item make install

May need root permissions

=item make initdb

Only do this during the intial install.  Running it twice will result
in duplicate Scrip Actions.

=item Edit your /opt/rt4/etc/RT_SiteConfig.pm

Add this line:

    Set(@Plugins, qw(RT::Action::MoveQueueBySubject));

or add C<RT::Action::MoveQueueBySubject> to your existing C<@Plugins> line.

=item Clear your mason cache

    rm -rf /opt/rt4/var/mason_data/obj

=item Restart your webserver

=back

=head1 CONFIGURATION

To configure this scrip, set the C<@MoveQueueBySubjectConditions> configuration option.

It is a list of regular expressions and queues. Each regular expression
will be check in order, if it matches the ticket will be moved to that
queue and processing will stop.

    Set(@MoveQueueBySubjectConditions,
        '^begin', 'Start',
        'end$', 'Finale',
    );

You can defined these as qr// if you prefer. The module does not apply
any flags to your regular expression, so if you want case insensitivity
or something else, be sure to use the (?i) operator which you can read
more about in L<perlre>.

=head1 USAGE

Once you've configured the action, set up a Scrip to use it. At the
Global or Queue level, define a Scrip with your preferred Condition (On
Create is typical), this Action and a Blank Template.

=head1 AUTHOR

Kevin Falcone <falcone@bestpractical.com>

=head1 BUGS

All bugs should be reported via
L<http://rt.cpan.org/Public/Dist/Display.html?Name=RT-Action-MoveQueueBySubject>
or L<bug-RT-Action-MoveQueueBySubject@rt.cpan.org>.


=head1 LICENCE AND COPYRIGHT

This software is Copyright (c) 2011 by Best Practical Solutions.

This is free software, licensed under:

  The GNU General Public License, Version 2, June 1991

=cut

sub Prepare { return 1; }

sub Commit {
    my $self = shift;
    my @conditions = @{RT->Config->Get('MoveQueueBySubjectConditions')};

    my $subject = $self->TicketObj->Subject;
    while ( my ($regex, $queue) = splice(@conditions,0,2) ) {
        RT->Logger->debug("Comparing $regex to $subject for a move to $queue");
        if ( $subject =~ /$regex/ ) {
            RT->Logger->debug("Moving to queue $queue");
            my ($ok, $msg) = $self->TicketObj->SetQueue($queue);
            unless ($ok) {
                RT->Logger->error("Unable to move to queue $queue: $msg.  Aborting");
                return 0;
            }
            last;
        }
    }
    return 1;
}

1;
