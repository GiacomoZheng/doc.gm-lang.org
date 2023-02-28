from pygments.formatters import HtmlFormatter

with open("./template/hi.css", "w") as hi:
	hi.write(HtmlFormatter(style='colorful').get_style_defs()) # get css