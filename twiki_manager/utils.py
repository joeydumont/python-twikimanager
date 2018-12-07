# -*- coding: utf-8 -*-
# --------------------------------------------------------------------------- #
# Author:          Joey Dumont         <joey.dumont@gmail.com>                #
# Date created:    Dec. 6th, 2018                                             #
# Description:     Utility functions to manage a TWiki.                       #
# License:         CC BY-SA 4.0                                               #
#                  <http://creativecommons.org/licenses/by-sa/4.0>            #
# --------------------------------------------------------------------------- #

import configparser

def parse_config(config,verbose=0):
  """
  This function parses the config file and puts its contents in a dictionary.
  """
  cfg = configparser.ConfigParser()
  cfg.read(config)

  settings = {}
  for sections in cfg.sections():

    # -- Initialize empty dictionary within the dictionary.
    settings.update({sections : {}})

    # -- Set the values.
    for key, value in cfg.items(sections):
      settings[sections].update({key: value})
      #[sections][key] = value

      if (verbose >= 2):
        print(sections,key,value)

  if (verbose > 0):
    print(settings)

  return settings
