Url = Npm.require('url')

urlParts = Meteor.settings.sandstorm.userStatsUrl.split("#")
statsUrl = urlParts[0] + "/data"
token = urlParts[1]

@getSandstormUser = ->
  data = Meteor.http.get statsUrl, {headers: {Authorization: "Bearer " + token}}

  rows = data.data
  res = []
  for row in rows
    row._id = row._jd_id
    row.timestamp = Date.parse row._jd_timestamp
    delete row["_jd_id"]
    delete row["_jd_timestamp"]
    res.push row

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
