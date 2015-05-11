GA_VIEW_ID = Meteor.settings.google.view_id

jwt = new googleapis.auth.JWT(Meteor.settings.google.client_email, null, Meteor.settings.google.private_key, ["https://www.googleapis.com/auth/analytics.readonly"])

analytics = googleapis.analytics('v3')
jwt.authorize (err, result) ->
  if err
    console.log err
    return
wrappedGA = Meteor.wrapAsync((dimensions, date, func) ->
  date = date || "today"
  analytics.data.ga.get
    auth: jwt
    dimensions: dimensions
    ids: "ga:#{GA_VIEW_ID}"
    "start-date": date
    "end-date": date
    metrics: "ga:sessions,ga:hits"
  , func
)

Meteor.startup ->
  if GoogleData.find().count() == 0
    startDate = new Date('2014-07-01')

isFirst = true
previous = null
previous_referrers = null
@getGoogle = (date) ->
  date = date || null
  data = wrappedGA(null, date)
  data = data.totalsForAllResults
  data['ga:sessions'] = +data['ga:sessions']
  data['ga:hits'] = +data['ga:hits']
  if not previous or data['ga:sessions'] < previous['ga:sessions']
    previous = data
  else
    newData = {}
    for key, val of data
      newData[key] = val - previous[key]
    previous = data
    data = newData

  referrers = wrappedGA("ga:fullReferrer", date).rows
  if referrers?.length
    # TODO: clean this up
    data.referrers = referrers
  return data

@startGoogleTimer =  ->
  insert = ->
    data = getGoogle()
    data.timestamp = new Date()
    if isFirst
      isFirst = false
      return
    GoogleData.insert(data)

  Meteor.setInterval(insert, 300000)
  insert()

@refreshGoogle = (start, end) ->
  d = startDate = new Date(start)

  d.setDate(d.getDate() + 1)
  d.setMinutes(d.getMinutes() - 1)
  endDate = new Date(end)

  while d < endDate
    console.log "inserting google data for #{d}"
    data = getGoogle(d.toISOString().slice(0, 10))
    data.timestamp = d
    GoogleData.insert(data)

    d.setDate(d.getDate() + 1)
