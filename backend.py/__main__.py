from pygments import highlight
from pygments.formatters import HtmlFormatter
from gm import GMLexer

from urllib.request import urlopen, Request
import os
import sys

headers = {'User-Agent':'Mozilla/5.0 (Windows NT 6.1; WOW64; rv:23.0) Gecko/20100101 Firefox/23.0'}
def url(site):
	return Request(url=site, headers=headers)
GMRAW = "https://raw.gm-lang.org/"

def update(title : str):
    path_src = "./src/" + str(title) + ".html"
    raw_time = float(urlopen(url(GMRAW + title + "/time")).read())
    if (not os.path.isfile(path_src)) or (os.path.getmtime(path_src) < raw_time):
        print("update")
        raw = urlopen(url(GMRAW + title)).read()
        with open(path_src, "w") as handle:
            handle.write(highlight(raw, GMLexer(), HtmlFormatter()))

    # if there is no such a file or this file is too old
        
def main():
    print("running")
    if os.getcwd().endswith("doc.gm-lang.org"):
        if os.path.isdir(os.path.join(os.getcwd(), "src")):
            update(sys.argv[1])
    else:
        raise Exception("wrong dir")

if __name__ == "__main__":
    main()