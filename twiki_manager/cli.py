# -*- coding: utf-8 -*-
# --------------------------------------------------------------------------- #
# Author:          Joey Dumont         <joey.dumont@gmail.com>                #
# Date created:    Nov. 22nd, 2018                                            #
# Description:     Click interface to twiki_manager.                          #
# License:         CC BY-SA 4.0                                               #
#                  <http://creativecommons.org/licenses/by-sa/4.0>            #
# --------------------------------------------------------------------------- #

"""Console script for twiki_manager."""

import os
import sys
import click
import pypandoc

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

  # -- Pass global arguments to context.
  ctx.obj['config'] = config
  ctx.obj['verbose'] = verbose

  # -- Parse the config file
  settings = utils.parse_config(config,verbose)

  # -- Instantiate the TWiki object.
  ctx.obj['TWikiObject'] = twiki_manager.Twiki(settings)

@main.command()
@click.argument('topic_path', type=str)
@click.argument('output_file', type=click.Path())
@click.pass_context
def get_topic(ctx,topic_path,output_file):
  """
  Simple wrapper to get the topic and save it to a file.
  """
  response = ctx.obj['TWikiObject'].get_topic(topic_path)

  with open(output_file, 'w') as write_file:
    write_file.write(response.text)

  return response

@main.command()
@click.argument('topic_path', type=str)
@click.pass_context
def set_topic(ctx,topic_path,input_file):
  """
  Simple wrapper to save a topic to a given path. Input file will be interpreted
  as TWiki markup.
  """
  with open(input_file, 'r') as twiki_input:
    topic_text = twiki_input.read()

  response = ctx.obj['TWikiObject'].set_topic(topic_path,)

  return response

@main.command()
@click.argument('topic_path', type=str)
@click.argument('markdown_file', type=click.Path())
@click.pass_context
def download_topic_md(ctx,topic_path,markdown_file):
  """
  Gets a topic, converts it to Markdown and saves it to a file.
  """
  twiki_markup = ctx.obj['TWikiObject'].get_topic(topic_path).text
  markdown     = pypandoc.convert_text(twiki_markup, 'md', format='twiki')

  with open(markdown_file, 'w') as output_file:
    output_file.write(markdown)

@main.command()
@click.argument('topic_path', type=str)
@click.argument('markdown_file', type=click.Path(exists=True))
@click.pass_context
def upload_topic_md(ctx,topic_path,markdown_file):
  """
  Converts a given Markdown file to TWiki markup with our custom Lua writer, and
  uploads it to the TWiki.
  """
  with open(markdown_file, 'r') as input_file:
    markdown_input = input_file.read()

  twiki_markup = pypandoc.convert_text(markdown_input, to=os.path.dirname(os.path.realpath(__file__)) + '/../tools/PandocTWikiWriter.lua', format='md')

  click.confirm("You are about to upload your document to the TWiki, \n" +
                "overwriting the current page. Make sure you have the\n" +
                "latest version of the page before proceeding.",
                default=False,
                abort=True)
  ctx.obj['TWikiObject'].set_topic(topic_path,twiki_markup)

if __name__ == "__main__":
    sys.exit(main())  # pragma: no cover
