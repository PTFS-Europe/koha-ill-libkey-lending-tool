package Koha::Plugin::Com::PTFSEurope::IncDocs::Lib::API;

# Copyright PTFS Europe 2022
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use strict;
use warnings;

use LWP::UserAgent;
use HTTP::Request;
use JSON qw( decode_json encode_json );
use CGI;
use URI;

use Koha::Logger;
use C4::Context;

=head1 NAME

IncDocs - Client interface to IncDocs API plugin (koha-plugin-IncDocs)

=cut

sub new {
    my ($class) = @_;

    my $cgi = new CGI;

    my $interface = C4::Context->interface;
    my $url =
        $interface eq "intranet"
        ? C4::Context->preference('staffClientBaseURL')
        : C4::Context->preference('OPACBaseURL');

    # We need a URL to continue, otherwise we can't make the API call to
    # the IncDocs API plugin
    if ( !$url ) {
        Koha::Logger->get->warn("Syspref staffClientBaseURL or OPACBaseURL not set!");
        die;
    }

    my $uri = URI->new($url);
    my $self = {
        ua      => LWP::UserAgent->new,
        cgi     => new CGI,
        logger => Koha::Logger->get( { category => 'Koha.Plugin.Com.PTFSEurope.IncDocs.Lib.API' } ),
        baseurl => $uri->scheme . "://" . $uri->host . ":" . $uri->port . "/api/v1/contrib/IncDocs"
    };

    bless $self, $class;
    return $self;
}

=head3 Libraries

Make a call to /libraries

=cut

sub Libraries {
    my ( $self ) = @_;

    my $request = HTTP::Request->new( 'GET', $self->{baseurl} . "/libraries" );
    return decode_json($self->{ua}->request($request)->decoded_content);
}

1;
