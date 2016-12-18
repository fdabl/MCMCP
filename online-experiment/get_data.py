import json
import pandas as pd
from sqlalchemy import create_engine, MetaData, Table


header = ['id', 'itemTime', 'trial', 'RT', 'number_chosen', 'number_not_chosen',
          'quantifier', 'clicked_left', 'language', 'comments', 'engagement', 'difficulty']
db_url = 'sqlite:///participants.db'
table_name = 'quantifier_MCMCP'
data_column_name = 'datastring'

# boilerplace sqlalchemy setup
engine = create_engine(db_url)
metadata = MetaData()
metadata.bind = engine
table = Table(table_name, metadata, autoload=True)

# make a query and loop through
s = table.select()
rows = s.execute()

data = []
#status codes of subjects who completed experiment
statuses = [3,4,5,7]
# if you have workers you wish to exclude, add them here
exclude = []
for row in rows:
    # only use subjects who completed experiment and aren't excluded
    if row['status'] in statuses and row['uniqueid'] not in exclude:
        data.append(row[data_column_name])

# Now we have all participant datastrings in a list.
# Let's make it a bit easier to work with:

# parse each participant's datastring as json object
# and take the 'data' sub-object
data = [json.loads(part)['data'] for part in data]


# insert a few things into the data array
for part in data:
    for record in part:
        trialdata = record['trialdata']
        try:
            trialdata.insert(0, record['dateTime'])
            trialdata.insert(0, record['uniqueid'])
        except AttributeError:
            continue 

# flatten nested list so we just have a list of the trialdata recorded
# each time psiturk.recordTrialData(trialdata) was called.
data = [record['trialdata'] for part in data for record in part
                       if isinstance(record['trialdata'], list)]

def addmeta(data):

    newdat = []
    ids = list(data[i][0] for i in range(len(data)))
    metadat = {id:[] for id in ids}
    ismeta = lambda ll: len(ll) <= 3

    # loop over all data points
    for i in range(len(data)):

        curdat = data[i]
        curid = curdat[0]

        if ismeta(curdat):
            meta = data[i][-1] or 'NA'
            metadat[curid].append(meta)

    # convert values of metadat to a list
    # 4 because it's about [language, difficulty, engagement, comments]
    metadat = {key:[val[i:i+4] for i in range(0, len(val), 4)]
               for key, val in metadat.items()}


    # check if anybody did the experiment more than once
    for key, val in metadat.items():
        if len(val) > 1:
            print('{0} did the experiment {1} times'.format(key, len(val)))


    # now insert the metadata to the newdat list
    # this assumes that there are unique participants
    # if there were not, the [language, difficulty, engagement, comments] columns
    # are those that are from the *first* time the participant has completed the experiment
    # all other data are untouched
    for i in range(len(data)):
        curdat = data[i]
        curid = curdat[0]
        curmeta = metadat.get(curid)
        line = curdat[:]

        if ismeta(line):
            continue

        line.extend(curmeta[0])
        newdat.append(line)

    return newdat


data = addmeta(data)

## Put all subjects' trial data into a dataframe object from the
## 'pandas' python library: one option among many for analysis
data_frame = pd.DataFrame(data)
data_frame.to_csv('data.csv', header = header, index = False)
