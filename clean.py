import pandas as pd
%matplotlib inline

import matplotlib.pyplot as plt
plt.style.use('fivethirtyeight')

# import the data
df = pd.read_csv('./data/out.csv')

# calculate scores
df['home_res'] = df.result.apply(lambda x: int(x.split('-')[0]))
df['away_res'] = df.result.apply(lambda x: int(x.split('-')[1]))

# calculate winners
df['home_win'] = df.apply(lambda x: 1 if x.home_res > x.away_res else 0, axis =1 )
df['away_win'] = df.apply(lambda x: 1 if x.away_res > x.home_res else 0, axis =1 )

# calculate lossers
df['home_loss'] = df.apply(lambda x: 1 if x.home_res < x.away_res else 0, axis =1 )
df['away_loss'] = df.apply(lambda x: 1 if x.away_res < x.home_res else 0, axis =1 )


# get match number
df['match'] = df.matchnum.apply(lambda x: int(x.replace('Match ', '')))

# calculate team stats for the tournament
def team_stats(df, col, new_col):
    victories = {}
    df['home_'+new_col] = 0
    df['away_'+new_col] = 0
    for i, row in df.sort_values(by=['cup', 'match']).iterrows():
        if victories.get(row.cup) is None:
            victories[row.cup] = {}
        if victories[row.cup].get(row.home) is None:
            victories[row.cup][row.home] = 0
        if victories[row.cup].get(row.away) is None:
            victories[row.cup][row.away] = 0
        df.loc[i, 'home_'+new_col] = victories[row.cup][row.home]
        df.loc[i, 'away_'+new_col] = victories[row.cup][row.away]
        if row['home_' + col] > 0:
            victories[row.cup][row.home] += row['home_'+col]
        if row['away_' + col] > 0:
            victories[row.cup][row.away] += row['away_'+col]
    return df

# winning stats
df = team_stats(df, 'win', 'victories')

# lossing stats
df = team_stats(df, 'loss', 'losses')

# goals in favor
df = team_stats(df, 'res', 'goals')


# calculate team goals against
def goals_against(df, col, new_col):
    victories = {}
    df['home_'+new_col] = 0
    df['away_'+new_col] = 0
    for i, row in df.sort_values(by=['cup', 'match']).iterrows():
        if victories.get(row.cup) is None:
            victories[row.cup] = {}
        if victories[row.cup].get(row.home) is None:
            victories[row.cup][row.home] = 0
        if victories[row.cup].get(row.away) is None:
            victories[row.cup][row.away] = 0
        df.loc[i, 'home_'+new_col] = victories[row.cup][row.home]
        df.loc[i, 'away_'+new_col] = victories[row.cup][row.away]
        if row['home_' + col] > 0:
            victories[row.cup][row.away] += row['away_'+col]
        if row['away_' + col] > 0:
            victories[row.cup][row.home] += row['home_'+col]
    return df

# calculate goals against
df = goals_against(df, 'res', 'goals_against')

df.to_csv('./data/worldcup_data.csv', index= False)


#df.groupby('cup').result.count().plot(kind='bar')
