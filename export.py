#!/usr/bin/env python
import pandas as pd
import numpy
import shutil


def handleCumulativeData(filename):
  d = pd.read_csv('original/' + filename)
  d.timestamp = pd.to_datetime(d.timestamp, unit='ms')
  d.index = d.timestamp
  d.sort_index()
  d.resample('D', how='max').to_csv(filename, index=False)


def handleGoogleData(filename):
  t = '[' + ','.join(open("original/" + filename + ".json").readlines()) + ']'
  d = pd.read_json(t)
  d.timestamp = d.timestamp.apply(lambda x: x["$date"])
  d.timestamp = pd.to_datetime(d.timestamp, unit='ms')
  d.index = d.timestamp
  d.sort_index()
  d = d.resample('D', how=numpy.sum)
  d["timestamp"] = d.index
  d.to_csv(filename + ".csv", index=False)


def main():
  handleCumulativeData("alpha.csv")
  handleCumulativeData("oasis.csv")
  handleCumulativeData("demoSandstorm.csv")
  handleCumulativeData("github.csv")
  handleCumulativeData("twitter.csv")
  handleCumulativeData("mailchimp.csv")
  handleCumulativeData("preorders.csv")
  handleGoogleData("googleAnalytics")
  shutil.copyfile("original/logData.csv", "logData.csv")

if __name__ == '__main__':
  main()
