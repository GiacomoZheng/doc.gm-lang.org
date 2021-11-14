#! python3
# coding:utf-8
# gmraw=/home/giacomo/docs/raw gmsrc=/home/giacomo/docs/src static=/home/giacomo/docs/static python3

# static=/mnt/c/Users/giaco/Documents/GitHub/doc.gm-lang.org/static gmraw=/mnt/c/Users/giaco/Documents/GitHub gmsrc=/mnt/c/Users/giaco/Documents/GitHub/doc.gm-lang.org/src

from tornado.ioloop import IOLoop
from tornado.web import RequestHandler, Application, StaticFileHandler

import os

def transparent(s):
	return s.startswith("_") and s.endswith("_")

with open(os.path.join(os.environ.get("static"), "index.html"), "r") as handle:
	pattern = handle.read()
	# print("pattern", pattern)

class Unimplement(Exception): pass
class NoSuchFile(Exception): pass

def analyze(full_name : str, directory = ".", root = ".", file = ".gm", ext = ".gm") -> str:
	"""
	"gm.h.group" ⇒ "./gm/h/_/group/.gm" \n
	"gm.Prolog" ⇒ "./gm/_/_interest_/Prolog"
	"""

	path = directory
	locations = full_name.split(".")
	location = locations[0]
	# print("location", location)

	if os.path.isfile(os.path.join(path, location + ext)):
		if len(locations) > 1:
			raise Unimplement("unimplement!")
		return os.path.join(path, location + ext)

	if os.path.isdir(os.path.join(path, location)):
		return analyze(".".join(locations[1:]), os.path.join(path, location), root)

	for item in filter(transparent, [filepath for filepath in os.listdir(directory)]):
		# print("transpart item: ", item)
		try:
			return analyze(full_name, os.path.join(path, item), root)
		except Unimplement as e:
			raise Unimplement(e)
		except NoSuchFile:
			pass
		except Exception as e:
			raise Exception(e)

	raise NoSuchFile("no such file")

def update_contents():
	os.system("python3 " + os.environ.get("static") + "/contents.py html > " + str(os.environ.get("gmsrc")) + "/contents.html")

def get_contents():
	with open(str(os.environ.get("gmsrc")) + "/contents.html", "r") as handle:
		return pattern\
			.replace("{%- title -%}", "Contents")\
			.replace("{%- content -%}", handle.read())

class IndexHandler(RequestHandler):
	def get(self):
		raw = str(os.environ.get("gmraw")) + "/gm"
		contents_path = str(os.environ.get("gmsrc")) + "/contents.html"

		print("raw: ", os.path.getmtime(raw))
		if not os.path.isfile(contents_path) or (os.path.getmtime(contents_path) < os.path.getmtime(raw)):
			print("update")
			update_contents()

		self.write(get_contents())

class RawHandler(RequestHandler):
	def get(self, title : str):
		try:
			with open(analyze(str(title), str(os.environ.get("gmraw"))), "r") as handle:
				self.write(handle.read())
		except Exception as e:
			self.write(str(e))

def update_src(path_raw, path_src):
	os.system("python3 -m pygments -x -o " + path_src + " -l " + os.environ.get("static") + "/gm.py:GMLexer " + path_raw)

class SrcHandler(RequestHandler):
	def get(self, title : str):
		try:
			path_raw = analyze(str(title), str(os.environ.get("gmraw")))
			path_src = str(os.environ.get("gmsrc")) + "/" + str(title) + ".html"
			print("path_raw", path_raw)
			print("path_src", path_src)

			# if there is no such a file or this file is too old
			if not os.path.isfile(path_src) or (os.path.getmtime(path_src) < os.path.getmtime(path_raw)):
				print("update")
				update_src(path_raw, path_src)
				# print("path_raw time", os.path.getmtime(path_raw))
				# print("path_src time", os.path.getmtime(path_src))

			with open(path_src, "r") as handle:
				html = pattern\
					.replace("{%- title -%}", title)\
					.replace("{%- content -%}", handle.read())

			self.write(html)
		except Exception as e:
			self.write(str(e))


def make_app():
	return Application(handlers=[
		(r"/", IndexHandler),
		(r"/src/([\w-][\.\w-]*)", SrcHandler),
		(r"/raw/([\w-][\.\w-]*)", RawHandler),
		(r"/static/(.*)", StaticFileHandler, {"path": os.environ.get("static")}),
	])

if __name__ == "__main__":
	# root = os.environ.get("gmraw")
	# print(analyze("gm.h.set", root, root))
	# print(analyze("gm.Prolog", root, root))

	app = make_app()
	app.listen(8888)
	IOLoop.current().start()
