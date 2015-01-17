@getPreorder = ->
  data = Meteor.http.get Meteor.settings.preorders.statsUrl

  return {
    count: +data.content
    timestamp: new Date()
  }

@startPreordersTimer = ->
  insert = ->
    try
      data = getPreorder()
      Preorders.insert(data)
    catch err
      console.error err

  Meteor.setInterval(insert, 300000)
  insert()
