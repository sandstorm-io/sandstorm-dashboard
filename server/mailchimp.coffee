KEY = Meteor.settings.mailchimp.key
DATACENTER = KEY.substring(KEY.lastIndexOf("-") + 1)
URL = "https://#{DATACENTER}.api.mailchimp.com/2.0"

@getMailchimpList = ->
  data = Meteor.http.post "#{URL}/lists/list",
    data:
      apikey: KEY

  # TODO: check status code
  return JSON.parse(data.content).data[0]

@startMailchimpTimer = ->
  insert = ->
    data = getMailchimpList()
    data.timestamp = new Date()
    MailchimpData.insert(data)

  Meteor.setInterval(insert, 300000)
  insert()
