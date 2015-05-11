Future = Npm.require("fibers/future")

readAll = (stream) ->
  fut = new Future()
  buffers = []
  stream.on "data", (buf) ->
    buffers.push buf
    return

  stream.on "end", ->
    fut.return Buffer.concat(buffers)
    return

  stream.on "error", fut.throw

  return fut.wait()

@doSandcatsUpload = (request) ->
  data = request.body

  data.timestamp = new Date()
  Sandcats.insert(data)

  return
