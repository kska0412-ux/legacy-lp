import base64, pathlib
d = pathlib.Path(__file__).parent
src = (d/'soudan.pre.html').read_text()
def uri(p, mime): return f"data:{mime};base64," + base64.b64encode((d/p).read_bytes()).decode()
out = src.replace('__INSTRUCTOR_B64__', uri('soudan-assets/instructor.jpg','image/jpeg')).replace('__CTA_B64__', uri('soudan-assets/cta.png','image/png'))
(d/'soudan.html').write_text(out)
print('soudan.html', len(out))
