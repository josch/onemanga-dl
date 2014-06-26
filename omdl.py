from urllib import urlretrieve
import urllib2
from lxml import etree
import os
from sys import argv

base_url = "http://www.onemanga.com"

manga = argv[1]

chapter = argv[2]

path = "%s/%s"%(manga, chapter)

if not os.path.exists(path):
	os.makedirs(path)

f = urllib2.urlopen("%s/%s/%s/"%(base_url, manga, chapter))
tree = etree.parse(f, etree.HTMLParser())

firstpage = "%s%s"%(base_url, tree.find(".//div[@id='chapter-cover']//ul/li/a").attrib['href'])

f = urllib2.urlopen(firstpage)
tree = etree.parse(f, etree.HTMLParser())
for page in [p.attrib['value'] for p in tree.findall(".//select[@id='id_page_select']/option")]:
	print manga, chapter, page
	tree2 = etree.parse(urllib2.urlopen("%s/%s/%s/%s"%(base_url, manga, chapter, page)), etree.HTMLParser())
	urlretrieve(tree2.find(".//div[@class='one-page']//img[@class='manga-page']").attrib['src'], "%s/%s.jpg"%(path,page))
