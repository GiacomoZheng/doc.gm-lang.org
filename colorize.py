import os

print(os.listdir())
ls = os.getcwd().split("/")
ls[-1] = "gm"
gm_dir = "/".join(ls)

sur_len = len(gm_dir + "/")

# print(gm_dir)
for path, subdirs, files in os.walk(gm_dir):
	for name in files:
		if name.endswith(".gm"):
			relative_name = os.path.join(path[sur_len:], name)[:-3]
			aim_path = os.path.join(os.getcwd(), "gm", relative_name)
			print(aim_path)
			try:
				os.makedirs(os.path.dirname(aim_path))
			except:
				pass
			# os.system("python3 -m pygments -x -o " + aim_path + ".bmp" + " -l ./gm.py:GMLexer " + os.path.join(path, name))
			if aim_path.endswith("/"):
				os.system("python3 -m pygments -x -o " + aim_path + "index.html" + " -l ./gm.py:GMLexer " + os.path.join(path, name))
			else:
				os.system("python3 -m pygments -x -o " + aim_path + ".html" + " -l ./gm.py:GMLexer " + os.path.join(path, name))


				# with open(os.path.join(path, name), "r") as handle:
				# with open(aim_path, "w") as writter:
				# 	highlight(handle.read(), lex, form, writter)