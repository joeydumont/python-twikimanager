# -*- coding: utf-8 -*-
# --------------------------------------------------------------------------- #
# Author:          Joey Dumont         <joey.dumont@gmail.com>                #
# Date created:    Nov. 22nd, 2018                                            #
# Description:     Click interface to twiki_manager.                          #
# License:         CC BY-SA 4.0                                               #
#                  <http://creativecommons.org/licenses/by-sa/4.0>            #
# --------------------------------------------------------------------------- #

"""Console script for twiki_manager."""

import sys
import click
from twiki_manager import twiki_manager
from twiki_manager import utils

@click.group()
@click.option('-c', '--config', type=click.Path(exists=True))
@click.option('-v', '--verbose', count=True)
@click.pass_context
def main(ctx,config,verbose):
  """
  Main entry point for twiki_manager script.
  """
  ctx.ensure_object(dict)

  ctx.obj['config'] = config
  ctx.obj['verbose'] = verbose

  # -- Parse the config file
  settings = utils.parse_config(config,verbose)

  # -- Instantiate the TWiki object.
  ctx.obj['TWikiObject'] = twiki_manager.Twiki(settings)

@main.command()
@click.argument('topic_path', type=str)
@click.pass_context
def get_topic(ctx,topic_path):
  response = ctx.obj['TWikiObject'].get_topic(topic_path)

  with open("response.html", 'w') as write_file:
    write_file.write(response.text)


@main.command()
@click.argument('topic_path', type=str)
@click.pass_context
def set_topic(ctx,topic_path):
  response = ctx.obj['TWikiObject'].set_topic(topic_path)

if __name__ == "__main__":
    sys.exit(main())  # pragma: no cover
