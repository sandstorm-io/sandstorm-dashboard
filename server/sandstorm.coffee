@getSandstorm = ->
  data = Meteor.http.get Meteor.settings.sandstorm.statsUrl

  rows = JSON.parse(data.content)
  res = []
  for row in rows
    newRow = {}
    newRow.timestamp = Date.parse row.timestamp
    newRow.dailyActiveUsers = row.daily.activeUsers
    newRow.dailyActiveGrains = row.daily.activeGrains
    res.push newRow

  return res

@startSandstormTimer = ->
  insert = ->
    try
      data = getSandstorm()
      for row in data
        SandstormData.upsert({timestamp: row.timestamp}, row)
    catch err
      console.error err

  Meteor.setInterval(insert, 300000)
  insert()
