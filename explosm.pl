#!/usr/bin/perl

use LWP::Simple;
use File::Path;

my $base_url = "http://www.explosm.net/comics/";

$next = 942;
$i = 802;
mkpath "explosm";

while($next) {
    my $content = get $base_url.$next or die "cannot access ".$base_url.$next;

    ($date, $author, $next, $img) = $content =~ /<nobr>(\d\d.\d\d.\d\d\d\d) <b>by (?:<a href=\"http:\/\/www.explosm.net\/comics\/author\/[^\"]+\/\">)?([^<]+)(?:<\/a>)?<\/b>.*?<\/nobr>.+?<a href=\"\/comics\/(\d+)\/\">Next ><\/a>.+?<img alt=\"Cyanide and Happiness, a daily webcomic\" src=\"(http:\/\/(?:www.)?explosm.net\/db\/files\/[^\"]+)\">/;
    
    print $i, " ", $next, " ", $date, "\n";
    my $content = get $img or die "cannot access ".$img;
    open FILE, ">explosm/$i-$date-$author";
    print FILE $content;
    close FILE;
    $i++;
    $|++;
}

