License
=======

Everything outside of the "Libraries" folder is MIT licensed, with one stipulation; you cannot use WVU's trademarks.

As a convenience, here is a copy of [WVU's official logo sheet](http://tls.wvu.edu/r/download/23909).

For items inside the "Libraries" folder, please check License.txt or the appropriate file header. They are all permissive open source licenses, though a few require attribution.

Requests
========

If you use my code to make an app, I would appreciate an email, tweet, or message on GitHub, but it is certainly not required.

Before You Build
================

If you try to build after downloading, you will receive an error

> PrivateKey.plist: No such file or directory

iWVU uses a private key when connecting to WVU's directory server. If you want the app to build, you can use a [dummy PrivateKey.plist file](http://JaredCrawford.org/Files/PrivateKey.plist). If you would like to add directory support to your application, an iOS compatible LDAP client was created by fellow WVU student Ricky Hussmann for use in early versions of iWVU. This project, [RHLDAPSearch](http://github.com/rhussmann/RHLDAPSearch) is also open source on GitHub.


Project Status
==============

[Available on the App Store](http://iTunes.com/apps/iWVU)

The main developer of iWVU is in law school, so iWVU is only receiving critical bug fixes at this time. 

If you are interested in contributing or taking over lead development, please contact me.


Other Universities Using iWVU
=============================

> * [St. Louis University](http://itunes.apple.com/us/app/saint-louis-university/id377399047?mt=8)
> * Marquette University
> * *More Coming Soon...*

Universities Using Portions of iWVU
=============================
> * [University of Central Lancashire](http://itunes.apple.com/us/app/uclan/id325930048?mt=8)
  * Calendar
  * Icon movement on main screen
  * Improved reachability
> * [New York University's Unofficial App](http://itunes.apple.com/us/app/nyumobile/id423799237?mt=8) 
  * [RHLDAPSearch](https://github.com/rhussmann/RHLDAPSearch)

Other Projects Using iWVU
=========================

> * [CelebriTweet](http://iTunes.com/apps/CelebriTweet) by John Cotant
> * [News Jam](http://itunes.apple.com/us/app/news-jam/id353897391?mt=8) by John Cotant
