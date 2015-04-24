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

./system is where all the blog specific content and style-sheets are stored

./config.ru is the Rack config file

./config_templates contains, you guessed it, config file templates

./utils contains the scripts for setting up and maintaining the blog

Where's the On Switch?
======================

The application is meant to sit in a containing folder where the site content lives (this makes updating easier). To get started create a folder called `app` (or whatever you'd like...), and cd to it.

    mkdir ~/app
    cd ~/app

Next grab the application.

    git clone https://github.com/henrystanley/kdt

Now we'll set up the content directories and config files

    cd kdt
    ruby ./utils/setup.rb

Then install all the gems:

    bundler install

Then make sure you have redis installed, use your package manager of choice...
For debian:

    apt-get install redis-server

Now you're good to go, let's run this puppy:

    rackup

Don't forget to also start redis, typically you'd cd up from the repository and run:

    redis-server ./redis/redis.conf

Point your browser at `localhost:3301` to see an empty blog.

Ready to fill it up? Head over to `localhost:3301/admin` to access the admin panel (the default login is: username=(whatever you want), password='kittens'). The rest should be fairly obvious.

The only other thing to remember is to change the port to 80 and the password to something other than 'kittens' in config.ru before production.

After realizing how slow the site was by default I setup a (hopefully) simple way to use nginx with unicorn. The setup script *should* create config files for this, so all you *should* have to do is install nginx (`apt-get install nginx`) and run it like this:
 
    unicorn -c unicorn.rb -D
    nginx

If that doesn't work, good luck, you're on your own...


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
