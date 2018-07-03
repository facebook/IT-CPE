#
# Cookbook Name:: cpe_office
# Attributes:: default
#
# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
#
# Copyright 2017, Facebook
#
# All rights reserved - Do Not Redistribute
#

default['cpe_office']['win']['manage_reg'] = {
  '14.0' => {
    'Word' => {},
    'WordMail' => {},
    'Excel' => {},
  },
  '15.0' => {
    'Word' => {},
    'WordMail' => {},
    'Excel' => {},
  },
  '16.0' => {
    'Word' => {},
    'WordMail' => {},
    'Excel' => {},
  },
}

default['cpe_office']['mac'] = {
  'o365' => {
    'SendAllTelemetryEnabled' => nil,
  },
  'onenote' => {
    'FirstRunExperienceCompletedO15' => nil,
    'kSubUIAppCompletedFirstRunSetup1507' => nil,
    'SendAllTelemetryEnabled' => nil,
    'OUIWhatsNewLastShownLink' => nil,
  },
  'excel' => {
    'kSubUIAppCompletedFirstRunSetup1507' => nil,
    'SendAllTelemetryEnabled' => nil,
    'OUIWhatsNewLastShownLink' => nil,
  },
  'outlook' => {
    'AutomaitcallyDownloadExternalContent' => nil,
    'kSubUIAppCompletedFirstRunSetup1507' => nil,
    'SendAllTelemetryEnabled' => nil,
    'OUIWhatsNewLastShownLink' => nil,
    'TrustO365AutodiscoverRedirect' => nil,
  },
  'powerpoint' => {
    'kSubUIAppCompletedFirstRunSetup1507' => nil,
    'SendAllTelemetryEnabled' => nil,
    'OUIWhatsNewLastShownLink' => nil,
  },
  'word' => {
    'kSubUIAppCompletedFirstRunSetup1507' => nil,
    'SendAllTelemetryEnabled' => nil,
    'OUIWhatsNewLastShownLink' => nil,
  },
}
