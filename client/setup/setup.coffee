setupService = (serviceName) ->
  window[serviceName].requestCredential {requestOfflineToken: true}, (token) ->
    Meteor.call 'retrieveOauthCredential', token, OAuthRetrieveSecret(token), (err, data) ->
      options =
        accessToken: data.serviceData.accessToken
        accessTokenSecret: data.serviceData.accessTokenSecret
      Meteor.call "setup#{serviceName}", options, (err) ->
        if err
          console.log err

Template.setup.events
  'click #setupTwitter': ->
    setupService 'Twitter'
