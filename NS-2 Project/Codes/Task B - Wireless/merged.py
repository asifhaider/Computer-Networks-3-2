# import libraries
import sys
import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd
sns.set_style('darkgrid')
sns.set_context('paper')

parameter_name = 'Node Speed'
metric_name = '_energy_'
metric = 'Energy Consumption'
filename1 = parameter_name + metric_name + 'before.csv'
filename2 = parameter_name + metric_name + 'after.csv'
# read csv and store to dataframe
df1 = pd.read_csv(filename1)
df2 = pd.read_csv(filename2)
fig, axes = plt.subplots(figsize=(12, 5))
# plot the data

sns.lineplot(x=parameter_name, y=metric, data=df1, label = 'before' , ax=axes)
sns.lineplot(x=parameter_name, y=metric, data=df2, label = 'after', ax=axes)
plt.title(metric + ' vs ' + parameter_name)
plt.xlabel(parameter_name) 
plt.ylabel(metric)



plt.show()