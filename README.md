## Setup

Assets use Jammit (http://documentcloud.github.com/jammit).  If you can't get this in time you can 
set `package_assets: off` in config/assets.yml

rake db:seed - Loads the Offense names and descriptions
rake pp:import - Imports new crimes (probably around 59k on first import)

## KarachiCrime Development Setup

Seed the offense names

    rake db:seed

Import the town boundaries:

    rake migrations:karachi_neighborhood_names && rake migrations:one_normalize_neighborhood_names

Create some fake crime data. All fake data is flagged as such:

    rake crime:karachi:fake

For even more fake crime run the following:

    i=0 ; while [ $i -lt 20 ]; do  rake crime:karachi:fake; i=`expr $i + 1`; done

Next we run the reports:

    rake crime:reports:weekly_crime_totals && rake crime:reports:ytd_offense_summaries && rake crime:reports:neighborhood_offense_totals

The corresponding map-reduce functions:

    rake crime:reports:weekly_crime_totals
    Crime.weekly_totals_between

    rake crime:reports:ytd_offense_summaries
    Offence.summaries_for_the_past

    rake crime:reports:neighborhood_offense_totals
    Neighborhood.offense_totals_between
