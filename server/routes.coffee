Meteor.methods
  generateApiToken: ->
    unless userIsAdmin(Meteor.user())
      throw new Meteor.Error(403, "Unauthorized", "Must be admin")

    token = Random.id(22)
    ApiTokens.upsert({_id: "stats"}, {$set: {token: token}})
    return token

Router.route('/fetchDemo', () ->
  req = this.request
  res = this.response

  token = ApiTokens.findOne({_id: "stats"}).token
  if req.headers['authorization'] != "Bearer " + token
    res.writeHead(403, { "Content-Type": "text/plain" })
    res.end("Unauthorized")
    return

  demoData = OasisSandstormData.find({}, {fields: {timestamp: 1, dailyDemoUsers: 1, dailyAppDemoUsers: 1}}).fetch()
  res.writeHead(200, { "Content-Type": "application/json" });
  res.end(JSON.stringify({result: demoData}));
, {where: 'server'})


Router.route('/fetchTrials', () ->
  req = this.request
  res = this.response

  token = ApiTokens.findOne({_id: "stats"}).token
  if req.headers['authorization'] != "Bearer " + token
    res.writeHead(403, { "Content-Type": "text/plain" })
    res.end("Unauthorized")
    return

  data = SandstormUserData.find({customerId: {$ne:null}}).fetch()
  res.writeHead(200, { "Content-Type": "application/json" });
  res.end(JSON.stringify({result: data}));
, {where: 'server'})
