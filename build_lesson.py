import base64, pathlib
d = pathlib.Path(__file__).parent
src = (d/'lesson.pre.html').read_text()
def uri(p, mime): return f"data:{mime};base64," + base64.b64encode((d/p).read_bytes()).decode()
out = (src
  .replace('__INSTRUCTOR_B64__', uri('lesson-assets/instructor.jpg', 'image/jpeg'))
  .replace('__CTA_B64__', uri('lesson-assets/cta-blank.png', 'image/png'))
  .replace('__FV_WIDE_B64__', uri('lesson-assets/fv-wide.jpg', 'image/jpeg'))
  .replace('__FV_SP_B64__', uri('lesson-assets/fv-sp.jpg', 'image/jpeg')))
assert '__' not in out.replace('__ed', ''), 'placeholder left'
(d/'lesson.html').write_text(out)
print('lesson.html', len(out))
