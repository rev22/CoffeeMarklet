root = exports ? this

jsLoad = (s, c) ->
  x = document.createElement('script')
  x.type = 'text/javascript'
  x.src = s
  y = 1
  x.onload = x.onreadystatechange = () ->
    if y and not @readyState or @readyState is 'complete'
      y = !y
      c()
  document.getElementsByTagName('head')[0].appendChild x

class CoffeeMarklet
    compile: (cs, callback, add_jquery = true, jquery_version = '1.6.1') ->
        js = CoffeeScript.compile cs, {bare: true}

        $.post 'http://closure-compiler.appspot.com/compile',
            compilation_level: 'SIMPLE_OPTIMIZATIONS',
            output_format: 'text',
            output_info: 'compiled_code'
            js_code: js
            (compiled) =>
                bookmarklet = @makeURI($.trim(compiled), add_jquery, jquery_version)
                callback bookmarklet

    decompile: (src, callback) ->
      wraprx1 = /^\( *-> *\n/
      wraprx2 = /\n\) *\( *\)[ \n]*$/
      doit = (js2coffee) ->
        src = decodeURIComponent(src)
        src = js2coffee.build(src)
        if wraprx1.test(src) and wraprx2.test(src)
          x = src
          x = x.replace(wraprx1, "")
          x = x.replace(wraprx2, "")
          unless /\n[^ \t\n]/.test(x)
            src = x
        callback(src)
      if x = root?.Js2coffee
        doit(x)
      else
        jsLoad "http://js2coffee.org/scripts/underscore.min.js", ->
          jsLoad "http://js2coffee.org/scripts/ace/ace.js", ->
            jsLoad "http://js2coffee.org/scripts/js2coffee.js", ->
              # alert "loaded!!!!"
              doit(root.Js2coffee)
      # CoffeeScript.load "https://github.com/rstacruz/js2coffee/raw/master/lib/js2coffee.coffee", ->
      #   js2coffee = root.Js2coffee
      #   js2coffee.build(src)

    makeURI: (code, add_jquery, jquery_version) ->
        if add_jquery
            # From Ben Alman's jQuery Bookmarklet Generator http://benalman.com/projects/run-jquery-code-bookmarklet/
            """javascript:(function(e,a,g,h,f,c,b,d){if(!(f=e.jQuery)||g>f.fn.jquery||h(f)){c=a.createElement("script");c.type="text/javascript";c.src="http://ajax.googleapis.com/ajax/libs/jquery/"+g+"/jquery.min.js";c.onload=c.onreadystatechange=function(){if(!b&&(!(d=this.readyState)||d=="loaded"||d=="complete")){h((f=e.jQuery).noConflict(1),b=1);f(c).remove()}};a.documentElement.childNodes[0].appendChild(c)}})(window,document,"#{jquery_version}",function($,L){#{code}});"""
        else
            "javascript:(function(){#{code}})()"

root.coffeemarklet = new CoffeeMarklet
