#!/usr/bin/perl

use LWP::Simple;
use XML::LibXML;
use File::Path;

my $base_url = "http://www.giantitp.com";

$next = 1;
$i = 590;

mkpath "oots";

while($next) {
    my $content = get sprintf($base_url."/comics/oots%04d.html", $i) or die "cannot access ".$base_url."/".$url;

    my $parser = XML::LibXML->new();
    my $doc = $parser->parse_html_string($content); #we are lucky libxml can read html crap
    my $img = $doc->findvalue("//body/table/tr/td/table/tr/td/table/tr/td/table/tr[2]/td/img/\@src")."\n";
    my $content = get $base_url.$img or die "cannot access ".$img_url;
    open FILE, ">oots/$i.gif";
    print FILE $content;
    close FILE;
    if ($doc->findvalue("//body/table/tr/td/table/tr/td/table/tr/td/table/tr[1]/td/table/tr/td/a[6]/\@href") eq "#") {
        $next = 0;
    }
    $i++;
}

