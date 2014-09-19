setupService = (serviceName) ->
  window[serviceName].requestCredential {requestOfflineToken: true}, (token) ->
    Meteor.call "setup#{serviceName}", token, OAuthRetrieveSecret(token), (err) ->
      if err
        console.log err

Template.setup.events
  'click #setupTwitter': ->
    setupService 'Twitter'
