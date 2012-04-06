#! /usr/bin/perl

use strict;

use LWP::UserAgent;
  
# Create a user agent object

my $parsed_output_r;
my $output_string;
my $res;

my $ua = LWP::UserAgent->new;
$ua->agent("MyApp/0.1 ");

# Create a request
my $req = HTTP::Request->new(GET => 'http://admin:password@192.168.1.1/RST_stattbl.htm');
$req->content_type('text/html');

while (1)
{
	# Pass request to the user agent and get a response back
	$res = $ua->request($req);

	$output_string = "";

	# Check the outcome of the response
	if ($res->is_success) 
	{	
		$parsed_output_r = parse_router_response($res->content);
	
		$output_string .= "0:".($parsed_output_r->{'WAN'}{'Rx B/s'}/1e6)."\n";
		$output_string .= "1:".($parsed_output_r->{'WAN'}{'Tx B/s'}/1e6)."\n";
		$output_string .= "2:".($parsed_output_r->{'LAN'}{'Rx B/s'}/1e6)."\n";
		$output_string .= "3:".($parsed_output_r->{'LAN'}{'Tx B/s'}/1e6)."\n";	
		$output_string .= "4:".($parsed_output_r->{'WLAN'}{'Rx B/s'}/1e6)."\n";
		$output_string .= "5:".($parsed_output_r->{'WLAN'}{'Tx B/s'}/1e6)."\n";	
	
		print $output_string;
	}
	else
	{
		print STDERR $res->status_line, "\n";
	}
	
	# Can't seem to use internal sleep command so use system call instead
	
	system "sleep 5";
}

sub parse_router_response
{
	my $input_string = $_[0];
	
	my @split_line = split /[\cM\cI\cJ]+/o, $input_string;
	
	my $line;
	my $content;
	my %output_hash 	= ();
	my @header_fields	= ();
	my $header_flag 	= 1;
	my $i			= 0;
	my $portname;
	
	foreach $line (@split_line)
	{
		$line =~ s/^\s+//o;
		$line =~ s/\s+$//o;
	
		if ($line eq '<table border="1" cellpadding="0" cellspacing="0" width="99%">' .. $line eq '</table>')
		{
			if ($line eq '<tr>' .. $line eq '</tr>')
			{
				if ($line =~ /^<td/o)
				{
					$line =~ /.+span class.+>\s*(.+)<\/span.+/o;
					
					$content = $1;
				
					if ($header_flag)
					{
						push @header_fields, $content;
						
						$header_flag-- if (scalar(@header_fields) == 8);
					}
					elsif ($line =~ /thead/o)
					{
						$portname = $content;
						$i = 1;	
					}
					else
					{
						$output_hash{$portname}{$header_fields[$i++]} = $content;
					}
				}
			}
		}
	}
	
	return \%output_hash;
}
