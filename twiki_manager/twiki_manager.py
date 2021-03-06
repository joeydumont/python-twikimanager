# -*- coding: utf-8 -*-
# --------------------------------------------------------------------------- #
# Author:          Joey Dumont         <joey.dumont@gmail.com>                #
# Date created:    Nov. 29th, 2018                                            #
# Description:     TWiki object to manage a TWiki.                            #
# License:         CC BY-SA 4.0                                               #
#                  <http://creativecommons.org/licenses/by-sa/4.0>            #
# --------------------------------------------------------------------------- #
import requests
import urllib3
import json
import pypandoc
from bs4 import BeautifulSoup

class Twiki():
  def __init__(self,settings):

    # -- Initialize variables.
    self.settings = settings
    self.auth     = (settings['auth']['username'], settings['auth']['password'])
    self.url      = settings['global']['url']

    # -- Open requests.Session().
    self.session        = requests.Session()
    self.session.auth   = self.auth
    self.session.verify = False if self.settings['auth']['verify'] == "False" else True

    if self.settings['auth']['warnings'] == "Off":
      urllib3.disable_warnings()

  def get_topic(self,topic_path):
    """
    Gets the raw Twiki markup from a specific topic.
    """
    twiki_cgi = "{:s}/bin/view/{:s}".format(self.url,topic_path)

    params    = {'username': self.settings['auth']['username'],
                 'password': self.settings['auth']['password'],
                 'raw': 'text'}
    response  = self.session.get(twiki_cgi, params=params)

    return response

  def set_topic(self,topic_path,topic_text):
    """
    Sets a given topic to the given raw Twiki markup.
    """
    params    = {'username': self.settings['auth']['username'],
                 'password': self.settings['auth']['password']}

    # -- Grab the crypttoken by editing the page but doing nothing.
    twiki_cgi = "{:s}/bin/edit/{:s}".format(self.url,topic_path)
    response  = self.session.get(twiki_cgi,params=params)

    # -- Parse the HTML to get the crypttoken value.
    soup = BeautifulSoup(response.text, 'html.parser')
    crypttoken = soup.find(attrs={"name": "crypttoken"})['value']
    params['crypttoken'] = crypttoken

    twiki_cgi = "{:s}/bin/save/{:s}".format(self.url,topic_path)
    data      = {'username': self.settings['auth']['username'],
                 'password': self.settings['auth']['password'],
                 'text': topic_text,
                 'crypttoken': crypttoken}
    response  = self.session.post(twiki_cgi, data=data)

    return response
