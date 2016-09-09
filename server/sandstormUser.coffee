Url = Npm.require('url')

urlParts = Meteor.settings.sandstorm.userStatsUrl.split("#")
statsUrl = urlParts[0] + "/data"
token = urlParts[1]

@getSandstormUser = ->
  data = Meteor.http.get statsUrl, {headers: {Authorization: "Bearer " + token}}

  rows = data.data
  res = []
  for row in rows
    newRow = {}
    newRow._id = row._jd_id
    newRow.timestamp = Date.parse row._jd_timestamp
    newRow.dailyActiveUsers = row.daily.activeUsers
    newRow.dailyActiveGrains = row.daily.activeGrains
    newRow.monthlyActiveUsers = row.monthly.activeUsers
    newRow.monthlyActiveGrains = row.monthly.activeGrains
    newRow.serverAge = row.serverAge
    newRow.customerId = row.customerId
    res.push newRow

  return res

@startSandstormUserTimer = ->
  insert = ->
    try
      data = getSandstormUser()
      for row in data
        SandstormUserData.upsert({_id: row._id}, row)
    catch err
      console.error err

  Meteor.setInterval(insert, 300000)
  insert()
