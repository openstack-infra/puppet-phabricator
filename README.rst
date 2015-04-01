puppet-phabricator
=================

A puppet module for installing and managing a phabricator instance. This is
derived greatly from  http://github.com/bloomberg/phabricator-tools

some notes for now:

This module should not manage a MySQL or a mail server itself - it should
assume that those have been set up by other modules.

We want to put all config customizations into local.json and not into the
database.

The initial.db file is from bloomberg, I'm not sure it's all that useful
to folks.

We still need to do this in my.cnf ::

    sql_mode=STRICT_ALL_TABLES
    ft_stopword_file=/phabricator/instances/dev/phabricator/resources/sql/stopwords.txt
    ft_min_word_len=3
    ft_boolean_syntax=' |-><()~*:""&^'
    innodb_buffer_pool_size=600M

then do::

  REPAIR TABLE phabricator_search.search_documentfield;

I did not do: https://secure.phabricator.com/book/phabricator/article/configuring_file_domain/ yet, or really think about it.

I also have not made puppet do anything with::

 sudo /phabricator/instances/dev/phabricator/bin/phd start

Which are the background daemons.

storyboard migration
--------------------

The data migration script assumes a storyboard schema in the same mysql server
as the phabricator schemas. It sets up users for everyone in storyboard
with a password of admin. We'll be doing openid/oauth eventually, so I didn't
spend a ton of time on that.

The apps that are disabled are disabled on purpose.
