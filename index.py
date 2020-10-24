#! /usr/bin/python3
#coding:utf-8

from tornado.ioloop import IOLoop
from tornado.web import RequestHandler, Application

import os

def analyze(s : str, loc : str = ".", file : str = ".gm", ext : str = ".gm") -> str:
	path = loc
	ls = s.split(".")
	count = 0
	while count < len(ls):
		print(1, path)
		item = ls[count]
		if os.path.isfile(path + "/" + item + ext):
			path += "/" + item + ext
			break
		while not os.path.isdir(path + "/" + item):
			print(2, path + "/" + item)
			if not os.path.isdir(path + "/_"):
				print(3, path + "/_")
				raise Exception("no such file")
			path += "/_"
		path += "/" + item
		count += 1
	

	if count < len(ls) - 1:
		raise Exception("unimplement!")
	elif os.path.isdir(path):
		return path + "/" + file
	else:
		return path

class IndexHandler(RequestHandler):
	pass

class SrcHandler(RequestHandler):
	def get(self, path):
		
		with open(analyze(path, os.environ.get("gmsrc"), "index.html", ".html"), "r") as handle:
			self.write(handle.read())

class RawHandler(RequestHandler):
	def get(self, path):
		with open(analyze(path, os.environ.get("gmraw"), ".gm", ".gm"), "r") as handle:
			self.write(handle.read())

def make_app():
	return Application(handlers=[
		(r"/", IndexHandler),
		(r"/src/([\w-][\.\w-]*)", SrcHandler),
		(r"/raw/([\w-][\.\w-]*)", RawHandler)
	])

if __name__ == "__main__":
	# print(analyze("gm.h.group"))
	# print(analyze("gm.h.group.theorem"))

	app = make_app()
	app.listen(8888)
	IOLoop.current().start()


