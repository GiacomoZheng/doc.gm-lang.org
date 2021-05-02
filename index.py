#! python3
# coding:utf-8
# gmraw=/home/giacomo/docs/raw gmsrc=/home/giacomo/docs/src static=/home/giacomo/docs/static python3

# static=/mnt/c/Users/giaco/Documents/GitHub/doc.gm-lang.org/static gmraw=/mnt/c/Users/giaco/Documents/GitHub/ gmsrc=/mnt/c/Users/giaco/Documents/GitHub/doc.gm-lang.org/src

from tornado.ioloop import IOLoop
from tornado.web import RequestHandler, Application, StaticFileHandler

import os

def analyze(s : str, loc : str = ".", file : str = ".gm", ext : str = ".gm") -> str:
	"""
	input: "gm.h.group"
	output: "./gm/h/_/group/.gm"
	"""
	path = loc
	ls = s.split(".")
	count = 0
	while count < len(ls):
		print(1, path)
		item = ls[count]
		if os.path.isfile(os.path.join(path, item + ext)):
			path = os.path.join(path, item + ext)
			break
		while not os.path.isdir(os.path.join(path, item)):
			print(2, os.path.join(path, item))
			if not os.path.isdir(os.path.join(path, "_")):
				print(3, os.path.join(path, "_"))
				raise Exception("no such file")
			path = os.path.join(path, "_")
		path = os.path.join(path, item)
		count += 1


	if count < len(ls) - 1:
		raise Exception("unimplement!")
	elif os.path.isdir(path):
		return path + "/" + file
	else:
		return path

class IndexHandler(RequestHandler):
	def get(self):
		# self.write(str(os.environ.get("gmsrc")))
		# self.write(str(os.environ.get("gmraw")))
		pass

class RawHandler(RequestHandler):
	def get(self, title : str):
		try:
			with open(analyze(str(title), str(os.environ.get("gmraw"))), "r") as handle:
				self.write(handle.read())
		except Exception as e:
			return str(e)

def update(path_raw, path_src):
	os.system("python3 -m pygments -x -o " + path_src + " -l " + os.environ.get("gmsrc") + "/gm.py:GMLexer " + path_raw)

class SrcHandler(RequestHandler):
	def get(self, title : str):
		try:
			# path_src = analyze(str(title), str(os.environ.get("gmsrc")), "index.html", ".html")
			path_raw = analyze(str(title), str(os.environ.get("gmraw")))
			path_src = str(os.environ.get("gmsrc")) + "/" + str(title) + ".html"
			print("path_raw", path_raw)
			print("path_src", path_src)

			with open(os.path.join(os.environ.get("gmsrc"), "index.html"), "r") as handle:
				pattern = handle.read()
			# print("pattern", pattern)
			
			# if there is no such a file or this file is too old
			# if not os.path.isfile(path_src) or (os.path.getmtime(path_src) < os.path.getmtime(path_raw)):

			if not os.path.isfile(path_src) or (os.path.getmtime(path_src) < os.path.getmtime(path_raw)):
				print("update")
				update(path_raw, path_src)
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
	app = make_app()
	app.listen(8888)
	IOLoop.current().start()


