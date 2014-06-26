#!/usr/bin/perl

use LWP::Simple;
use XML::LibXML;
use File::Path;

my $base_url = "http://www.onemanga.com";

$url = $ARGV[0];
if(not $url) {
    print "usage: ./scraper.pl Fairy_Tail\n";
    exit
}

my $content = get $base_url."/".$url or die "cannot access ".$base_url."/".$url;

$content =~ s/&/&amp;/g; #clean up this junk...

my $parser = XML::LibXML->new();
my $doc = $parser->parse_html_string($content, $parser->recover(2)); #we are lucky libxml can read html crap

#iterate through all chapters
@chapters = reverse($doc->findnodes("//body/div[\@id='wrap']/div[\@id='content']/div[\@id='content-main']/table[\@class='ch-table']/tr/td[\@class='ch-subject']/a/\@href"));
foreach my $node (@chapters) {
    print "doing ", $node->value, "\n";
    mkpath ".".$node->value;
    #get the first page's address
    $chapter1_url = $base_url.$node->value;
    $content = get $chapter1_url or die "cannot access ".$chapter1_url;
    $content =~ s/&/&amp;/g; #clean up this junk...
    $doc_chap = $parser->parse_html_string($content, $parser->recover(2)); #we are lucky libxml can read html crap
    $chapter1_url = $base_url.$doc_chap->findvalue("//body/div[\@id='wrap']/div[\@id='content']/div[\@id='content2']/div[\@id='chapter-cover']/ul/li[1]/a/\@href");
    #get all pages in this chapter
    $content = get $chapter1_url or die "cannot access ".$chapter1_url;
    $content =~ s/&/&amp;/g; #clean up this junk...
    $doc_chap = $parser->parse_html_string($content, $parser->recover(2)); #we are lucky libxml can read html crap
    #iterate throug all pages
    foreach $node_chap ($doc_chap->findnodes("//body/div[\@id='wrap2']/div[\@id='content']/div[\@id='content2']/div[\@class='chapter-navigation']/select[\@name='page']/option/\@value")) {
        if(-f ".".$node->value.$node_chap->value.".jpg") {
            print ".".$node->value.$node_chap->value.".jpg already there\n";
        } else {
            $page_url =  $base_url.$node->value.$node_chap->value."/";
            #get image url
            $content = get $page_url or die "cannot access ".$page_url;
            $content =~ s/&/&amp;/g; #clean up this junk...
            $doc_page = $parser->parse_html_string($content, $parser->recover(2)); #we are lucky libxml can read html crap
            $img_url = $doc_page->findvalue("//body/div[\@id='wrap2']/div[\@id='content']/div[\@id='content2']/div[\@class='one-page']/a/img[\@class='manga-page']/\@src");
            #download image
            print "saving image $img_url\n";
            $content = get $img_url or die "cannot access ".$img_url;
            open FILE, ">.".$node->value.$node_chap->value.".jpg";
            print FILE $content;
            close FILE;
        }
    }
}
