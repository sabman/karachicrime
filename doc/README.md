Use this README file to introduce your application and point to useful places in the API for learning more.
Run "rake doc:app" to generate API documentation for your models, controllers, helpers, and libraries.


    i=0 ; while [ $i -lt 10 ]; do RAILS_ENV=production rake crime:karachi:fake; i=`expr $i + 1`; done && RAILS_ENV=production rake crime:reports:weekly_crime_totals && RAILS_ENV=production rake crime:reports:ytd_offense_summaries && RAILS_ENV=production rake crime:reports:neighborhood_offense_totals && touch  tmp/restart.txt