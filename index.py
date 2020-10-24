#! python3
#coding:utf-8
# gmraw=/home/giacomo/docs/raw gmsrc=/home/giacomo/docs/src

# static=/mnt/c/Users/giaco/Documents/GitHub/doc.gm-lang.org/static
# gmraw=/mnt/c/Users/giaco/Documents/GitHub/

from tornado.ioloop import IOLoop
from tornado.web import RequestHandler, Application, StaticFileHandler

import os

def analyze(s : str, loc : str = ".", file : str = ".gm", ext : str = ".gm") -> str:
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
		self.write(str(os.environ.get("gmsrc")))
		self.write(str(os.environ.get("gmraw")))

class SrcHandler(RequestHandler):
	def get(self, title : str):
		try:
			with open(os.path.join(os.environ.get("gmsrc"), "index.html"), "r") as pattern:
				path = analyze(str(title), str(os.environ.get("gmsrc")), "index.html", ".html")
				with open(path, "r") as content:
					html = pattern.read()\
						.replace("{%- title -%}", title)\
						.replace("{%- content -%}", content.read())
					self.write(html)
		except Exception as e:
			self.write(str(e))

class RawHandler(RequestHandler):
	def get(self, path : str):
		try:
			with open(analyze(str(path), str(os.environ.get("gmraw")), ".gm", ".gm"), "r") as content:
				self.write(content.read())
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
	# print(analyze("gm.h.group"))
	# print(analyze("gm.h.group.theorem"))

	app = make_app()
	app.listen(8888)
	IOLoop.current().start()


