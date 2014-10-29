GA_VIEW_ID = Meteor.settings.google.view_id

jwt = new googleapis.auth.JWT(Meteor.settings.google.client_email, null, Meteor.settings.google.private_key, ["https://www.googleapis.com/auth/analytics.readonly"])

analytics = googleapis.analytics('v3')
jwt.authorize (err, result) ->
  if err
    console.log err
    return
wrappedGA = Meteor.wrapAsync((dimensions, func) ->
  analytics.data.ga.get
    auth: jwt
    dimensions: dimensions
    ids: "ga:#{GA_VIEW_ID}"
    "start-date": "today"
    "end-date": "today"
    metrics: "ga:sessions,ga:hits"
  , func
)

previous = null
previous_referrers = null
@getGoogle = ->
  data = wrappedGA(null)
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

  referrers = wrappedGA("ga:fullReferrer").rows
  if referrers?.length
    # TODO: clean this up
    data.referrers = referrers
  return data

@startGoogleTimer =  ->
  insert = ->
    data = getGoogle()
    data.timestamp = new Date()
    GoogleData.insert(data)

  Meteor.setInterval(insert, 300000)
  insert()
