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
    newRow.plansFree = (row.plans?.free or 0) + (row.plans?.undefined or 0)
    newRow.plansStandard = row.plans?.standard or 0
    newRow.plansBasic = row.plans?.basic or 0
    newRow.plansLarge = row.plans?.large or 0
    newRow.plansMega = row.plans?.mega or 0
    newRow.plansRevenue = if row.plans then newRow.plansStandard * 6 + newRow.plansBasic * 9 + newRow.plansLarge * 12 + newRow.plansMega * 24 else 0
    newRow.plansPaidUsers = newRow.plansStandard + newRow.plansBasic + newRow.plansLarge + newRow.plansMega
    newRow.totalUsers = row.forever?.activeUsers or 0
    newRow.dailySharedUsers = 0
    if row.daily.apps
      for key, val of row.daily.apps
        newRow.sharedUsers += val.sharedUsers or 0
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
