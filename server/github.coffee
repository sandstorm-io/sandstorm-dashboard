@getGithub = ->
  data = Meteor.http.get "https://api.github.com/repos/sandstorm-io/sandstorm",
    headers:
      "User-Agent": "Sandstorm Dashboard"

  return JSON.parse(data.content)

@startGithubTimer = ->
  insert = ->
    try
      data = getGithub()
      data.timestamp = new Date()
      GithubData.insert(data)
    catch err
      console.error err

  Meteor.setInterval(insert, 300000)
  insert()
