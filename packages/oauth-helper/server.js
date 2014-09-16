Meteor.methods({
  retrieveOauthCredential: function (credentialToken, credentialSecret) {
    return Oauth.retrieveCredential(credentialToken, credentialSecret);
  }
});

this.TwitterBinding = function (options) {
  binding = new OAuth1Binding(options, {
    requestToken: "https://api.twitter.com/oauth/request_token",
    authorize: "https://api.twitter.com/oauth/authorize",
    accessToken: "https://api.twitter.com/oauth/access_token",
    authenticate: "https://api.twitter.com/oauth/authenticate"
  });
  binding.accessToken = options.accessToken;
  binding.accessTokenSecret = options.accessTokenSecret;
  return binding;
}
