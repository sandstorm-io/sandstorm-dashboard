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

@getDemoSandstorm = ->
  data = Meteor.http.get Meteor.settings.demoSandstorm.statsUrl

  rows = JSON.parse(data.content)
  res = []
  for row in rows
    newRow = {}
    newRow.timestamp = Date.parse row.timestamp
    newRow.dailyActiveUsers = row.daily.activeUsers
    newRow.dailyAppDemoUsers = row.daily.appDemoUsers
    newRow.dailyActiveGrains = row.daily.activeGrains
    res.push newRow

  return res

@startDemoSandstormTimer = ->
  insert = ->
    try
      data = getDemoSandstorm()
      for row in data
        DemoSandstormData.upsert({timestamp: row.timestamp}, row)
    catch err
      console.error err

  Meteor.setInterval(insert, 300000)
  insert()

@getOasisSandstorm = ->
  data = Meteor.http.get Meteor.settings.oasisSandstorm.statsUrl

  rows = JSON.parse(data.content)
  res = []
  for row in rows
    newRow = {}
    newRow.timestamp = Date.parse row.timestamp
    newRow.dailyActiveUsers = row.daily.activeUsers
    newRow.dailyDemoUsers = row.daily.demoUsers
    newRow.dailyAppDemoUsers = row.daily.appDemoUsers
    newRow.dailyActiveGrains = row.daily.activeGrains
    newRow.monthlyActiveUsers = row.monthly.activeUsers
    newRow.monthlyDemoUsers = row.monthly.demoUsers
    newRow.monthlyAppDemoUsers = row.monthly.appDemoUsers
    newRow.monthlyActiveGrains = row.monthly.activeGrains
    newRow.plans = row.plans
    res.push newRow

  return res

@startOasisSandstormTimer = ->
  insert = ->
    try
      data = getOasisSandstorm()
      for row in data
        OasisSandstormData.upsert({timestamp: row.timestamp}, row)
    catch err
      console.error err

  Meteor.setInterval(insert, 300000)
  insert()
