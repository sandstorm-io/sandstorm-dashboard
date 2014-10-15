Future = Npm.require("fibers/future")
url = Npm.require("url")

csv_parse = Meteor.wrapAsync csv.parse
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

@doLogUpload = (request) ->
  data = readAll(request).toString()

  data = data.replace(/^\[/gm, '"')
  data = data.replace(/(\+\d{4})]/gm, (str, group1) -> group1 + '"')
  data = data.replace(/(\/\d{4}):/gm, (str, group1) -> group1 + ' ')

  rows = csv_parse data,
    delimiter: ' '
    columns: ['timestamp', 'url', 'method', 'status_code', 'ip', 'unknown1', 'unknown2', 'client']

  for row in rows
    row.url = 'https://' + row.url
    row.timestamp = Date.parse row.timestamp
    parsed = url.parse row.url, true
    row.channel = parsed.pathname.substr(1)
    row.from = parsed.query.from
    row.type = parsed.query.type
    LogData.upsert _.pick(row, ['timestamp', 'ip']), row

  return
