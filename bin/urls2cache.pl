#!/usr/bin/env perl

# url2cache.pl - given a URL, cache the remote content in a "study carrel"

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# July 10, 2018 - first cut


# configure
use constant MIME    => ( 'application/xml' => 'xml', 'application/atom+xml' => 'xml', 'image/png' => 'png', 'application/rss+xml' => 'xml', 'text/xml' => 'xml', 'image/jpeg' => 'jpg', 'text/csv' => 'csv', 'text/plain' => 'txt', 'text/html' => 'html', 'image/gif' => 'gif', 'application/pdf' => 'pdf' );
use constant TIMEOUT => 10;
use constant CACHE   => './carrels/urls2carrel/cache';

# require
use LWP::UserAgent;
use strict;
require './lib/reader.pl';

# read input
my $url = $ARGV[ 0 ];

# validate input
if ( ! $url ) { die "Usage: $0 <url>\n" }

# initialize
my %mime   = MIME;
my $client = LWP::UserAgent->new;
$client->timeout( TIMEOUT );

# don't process particular types of urls
exit if ( $url =~ /^mailto/ );

# peek at the document
my $response = $client->head( $url );

# found something
if ( $response->is_success ) {

	# extract mime type and map it to a local extension
	my $type      = ( $response->content_type )[ 0 ];
	my $extension = $mime{ $type };
	
	# if found
	if ( $extension ) {
			
		# build file name
		my $filename = &make_filename( $url, CACHE, $extension );
		
		# check for html
		if ( $extension eq 'html' ) {
		
			# get html and convert relative urls to absolute
			my $html = &make_absolute( $response->decoded_content, $response->base );

			# save
			#open OUTPUT, " > $filename" or die "Can't open $filename ($!). Call Eric. \n";
			#binmode( OUTPUT, ":utf8" );
			#print OUTPUT $html;
			#close OUTPUT;
			
			# actually do the work but cheat with a more robust application; wget++
			`wget -k $url -O $filename`;
				
		}
		
		# process everything else
		else {
						
			# actually do the work but cheat with a more robust application; wget++
			`wget $url -O $filename`;

		}
								
	}
	
	else { warn "Warning: Unprocessed MIME-type($type) . Ignorning. Call Eric?\n"; }
	
}

else { die $response->status_line }