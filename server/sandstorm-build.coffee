escapeRegex = (s) ->
  return s.replace(/[-\/\\^$*+?.()|[\]{}]/g, '\\$&')

mainPageRegex = new RegExp(escapeRegex("Element <.start> was visible after ") + "(\\d+)")
testNewGrainRegex = new RegExp("Running:  Test new grain")
installRegex = new RegExp(escapeRegex("Element <#step-confirm> was visible after ") + "(\\d+)")
appListRegex = new RegExp(escapeRegex("Element <.app-action[data-app-id=\"nqmcqs9spcdpmqyuxemf0tsgwn8awfvswc58wgk375g4u25xv6yh\"]> was visible after ") + "(\\d+)")
appListButtonRegex = new RegExp(escapeRegex("Element <.app-action[data-app-id=\"nqmcqs9spcdpmqyuxemf0tsgwn8awfvswc58wgk375g4u25xv6yh\"]> was visible after ") + "(\\d+)")
grainTitleRegex = new RegExp(escapeRegex("Element <#grainTitle> was visible after ") + "(\\d+)")
grainFrameRegex = new RegExp(escapeRegex("Element <#publish> was present after ") + "(\\d+)")

@getOasisMonitor = ->
  project = JSON.parse(Meteor.http.get(Meteor.settings.oasisSandstorm.buildUrl + "/api/json").content)

  lastBuild = OasisMonitorData.findOne({}, {sort: {number: -1}})

  currentNum = ((lastBuild && lastBuild.number) || 0) + 1

  res = []
  while currentNum < project.nextBuildNumber
    build = JSON.parse(Meteor.http.get(Meteor.settings.oasisSandstorm.buildUrl + "/" + currentNum + "/api/json").content)
    newRow = {number: currentNum, result: build.result, timestamp: new Date(build.timestamp)}

    if build.result == "SUCCESS"
      try
        log = Meteor.http.get(Meteor.settings.oasisSandstorm.buildUrl + "/" + currentNum + "/consoleText").content
        newRow.grainTitleResponsMs = grainTitleRegex.exec(log)[1]
        newRow.grainFrameResponseMs = grainFrameRegex.exec(log)[1]
        log = log.slice(log.indexOf("Init cookie 1"));
        newRow.grainTitleResponsMs2 = grainTitleRegex.exec(log)[1]
        newRow.grainFrameResponseMs2 = grainFrameRegex.exec(log)[1]
        log = log.slice(log.indexOf("Init cookie 2"));
        newRow.grainTitleResponsMs3 = grainTitleRegex.exec(log)[1]
        newRow.grainFrameResponseMs3 = grainFrameRegex.exec(log)[1]
        log = log.slice(log.indexOf("Init cookie 3"));
        newRow.grainTitleResponsMs4 = grainTitleRegex.exec(log)[1]
        newRow.grainFrameResponseMs4 = grainFrameRegex.exec(log)[1]
      catch e
        console.error("Couldn't parse log for " + currentNum, e)
    res.push newRow

    currentNum++

  return res

@startOasisMonitorTimer = ->
  insert = ->
    try
      data = getOasisMonitor()
      for row in data
        OasisMonitorData.upsert({number: row.number}, row)
    catch err
      console.error err

  Meteor.setInterval(insert, 300000)
  insert()

