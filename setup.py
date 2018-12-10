#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""The setup script."""

from setuptools import setup, find_packages

with open('README.rst') as readme_file:
    readme = readme_file.read()

with open('HISTORY.rst') as history_file:
    history = history_file.read()

requirements = ['Click>=6.0', 'requests', 'json', 'pypandoc', 'bs4', 'configparser']

setup_requirements = [ ]

test_requirements = [ ]

setup(
    author="Joey Dumont",
    author_email='joey.dumont@gmail.com',
    classifiers=[
        'Development Status :: 2 - Pre-Alpha',
        'Intended Audience :: Developers',
        'Natural Language :: English',
        'Programming Language :: Python :: 3',
        'Programming Language :: Python :: 3.4',
        'Programming Language :: Python :: 3.5',
        'Programming Language :: Python :: 3.6',
        'Programming Language :: Python :: 3.7',
    ],
    description="Interact with TWiki installations via the CGI scripts, in Python.",
    entry_points={
        'console_scripts': [
            'twiki_manager=twiki_manager.cli:main',
        ],
    },
    install_requires=requirements,
    long_description=readme + '\n\n' + history,
    include_package_data=True,
    keywords='twiki_manager',
    name='twiki_manager',
    packages=find_packages(),
    setup_requires=setup_requirements,
    test_suite='tests',
    tests_require=test_requirements,
    url='https://github.com/joeydumont/python-twikimanager',
    version='0.1.0',
    zip_safe=False,
)
