KDT, a Blog About Syntax and Lens Flare
=======================================

This is the source of the obscure and barely read site, [kdt.io](http://kdt.io).

A Short Tour of the Facilities
==============================

Despite my hope that most of the code will be self explanatory, I recognize that the veritable smorgasbord of best practice infractions that is this site may require some kind of overview.

KDT rests upon the ever-clever framework, [Camping](https://github.com/camping/camping), however it deviates in some instances due to my own preferences. The main differences are:
  
1. It uses Redis to store posts instead of a sensible sql database
2. It uses HAML instead of Markaby for templating
3. It drops the 'M' in 'MVC', using only controllers and views
4. As apposed to the monolithic style the Camping Book recommends, the files here are bit more spread out  

Here's a short summary of the three main files' content and purpose:

blog.rb
-------

This is the front end of the back end, if you will. All the logic for the main site sits in here. It mainly deals with handling requests for specific posts or pages of tagged posts.

admin.rb
--------

This is the admin panel of the site. Despite being the least accessed part of the blog it contains the most code. Things it deals with include, uploading files, writing posts, and backing up the two aforementioned types of content.

persistence.rb
--------------

Unlike the previous two files which are Camping modules, persistence.rb is a small library for interfacing with the Redis server. It exports the database class used by the two sites to store, retrieve, search for, and remove posts (as well as file instances for the backup system).

other stuff
-----------

./views contains all the HAML templates

./static contains web accessible resources

./static/_system is where all the blog specific content and style-sheets are stored

./redis houses the redis config file and persistent database file (dump.rdb)

./config.ru is the Rack config file

./utils contains the lone script backup.rb, which can be used with the backup functionality in admin.rb to maintain a backup of the static files

Where's the On Switch?
======================

First install all the gems:

    bundler install

Then you're good to go, let's run this puppy:

    rackup

Point your browser at `localhost:3301` to see an empty blog.

Ready to fill it up? Head over to `localhost:3301/admin` to access the admin panel (the default login is: username=(whatever you want), password='kittens'). The rest should be fairly obvious.

The only other thing to remember is to change the port to 80 and the password to something other than 'kittens' in config.ru before production.

Can I Use This Project, In Part or in Whole?
============================================

This project is licensed with CC0, meaning that in all practicality it is in the public domain.
Do whatever you want with it...

I've made an effort to keep site specific urls and names to a minimum, in the hope that this will make adapting the code to another site easier. I'd also like to think that most of the codebase is fairly flexible (though this may be just a delusion).

Thanks
======

This site uses several projects worth mentioning and attributing:

[Redis](http://redis.io/)  
[Minimalist Online Markdown Editor](https://github.com/pioul/Minimalist-Online-Markdown-Editor)  
[Adapt](http://adapt.960.gs/)  
[Highlight.js](https://highlightjs.org/)  
[Processing.js](http://processingjs.org/)

I'd also like to thank the developers of the various gems this site uses.

Most of all however, I would like to thank why the lucky stiff, both for the Camping framework and his excellent [book](http://mislav.uniqpath.com/poignant-guide/), without which I would never have discovered programming.

Thanks _why.