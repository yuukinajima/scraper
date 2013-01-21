#!/usr/bin/env coffee

jsdom = require("jsdom")
fs = require("fs")
async = require 'async'
jquery = fs.readFileSync("./src/jquery.js").toString()


domain = "b.hatena.ne.jp" # <- start point
wait   = 100
hop    = 3

Array::unique = ->
  output = {}
  output[@[key]] = @[key] for key in [0...@length]
  value for key, value of output

check  = new RegExp( "^http[s]*://#{domain}" );
pages  = {}
external = {}


fn = (errors, window, done)->
  arr = window.$("a").map( (i,e)-> e.href ).toArray()
  arr.__proto__.unique = Array::unique
  arr
  .unique()
  .sort()
  .forEach (e)->
    if check.test e
      pages[e]    || = false
    else
      external[e] || = false
  setTimeout done, wait

worker = (url,done)-> 
  jsdom.env 
    html: url
    src : jquery
    done: (err,window)->
      pages[url] = true
      console.log "getting #{url}..."
      fn(err, window, done )

run = (task)->
  async.forEachSeries task, worker
  #async.forEach task, worker  ## you can use this. 
  ,()-> 
    newtask = (url for url,v of pages when v == false)
    console.log "hop:#{hop}"
    console.log newtask
    if newtask.length == 0 || hop == 0
      console.log "pages", pages
      console.log "ex", external
    else
      hop--
      process.nextTick ()-> run newtask

run ["http://#{domain}"]