#! python3
# coding:utf-8
# gmraw=/home/giacomo/doc.gm-lang.org/raw gmsrc=/home/giacomo/doc.gm-lang.org/src static=/home/giacomo/doc.gm-lang.org/static python3

from tornado.ioloop import IOLoop
from tornado.web import RequestHandler, Application, StaticFileHandler

import os

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
		(r"/([\w-][\.\w-]*)", SrcHandler),
	])

if __name__ == "__main__":
	# root = os.environ.get("gmraw")
	# print(analyze("gm.h.set", root, root))
	# print(analyze("gm.Prolog", root, root))

	app = make_app()
	app.listen(8889)
	IOLoop.current().start()
